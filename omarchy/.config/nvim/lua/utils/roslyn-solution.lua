local M = {}

local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "roslyn_targets.json")

local SKIP = {
	bin = true,
	obj = true,
	[".git"] = true,
	[".vs"] = true,
	node_modules = true,
	artifacts = true,
	packages = true,
	TestResults = true,
}

------------------------------------------------------------------ persistence

local function read_store()
	local fd = io.open(state_file, "r")
	if not fd then
		return {}
	end
	local raw = fd:read("*a")
	fd:close()
	local ok, t = pcall(vim.json.decode, raw)
	return (ok and type(t) == "table") and t or {}
end

local function write_store(t)
	vim.fn.mkdir(vim.fn.stdpath("state"), "p")
	local fd = io.open(state_file, "w")
	if not fd then
		return
	end
	fd:write(vim.json.encode(t))
	fd:close()
end

------------------------------------------------------------------ discovery

function M.initRoot(root)
	vim.g.roslyn_ls_root = root
end

function M.root(bufnr)
	if vim.g.roslyn_ls_root ~= nil then
		return vim.g.roslyn_ls_root
	end
	local name = vim.api.nvim_buf_get_name(bufnr or 0)
	local start = name ~= "" and vim.fs.dirname(name) or assert(vim.uv.cwd())
	local git = vim.fs.find(".git", { upward = true, path = start })[1]
	return git and vim.fs.dirname(git) or assert(vim.uv.cwd())
end

function M.scan(root)
	local out = {}
	for name, type_ in
		vim.fs.dir(root, {
			depth = 5,
			skip = function(dir)
				return not SKIP[dir]
			end,
		})
	do
		if type_ == "file" and name:match("%.sln[fx]?$") then
			table.insert(out, vim.fs.joinpath(root, name))
		end
	end
	return out
end

--- Saved default for a repo; nil if the file no longer exists.
function M.saved(root)
	local t = read_store()[root or M.root()]
	return (t and vim.uv.fs_stat(t)) and t or nil
end

--- Effective target: session override, else saved default.
function M.resolve(bufnr)
	return vim.g.roslyn_ls_target or M.saved(M.root(bufnr))
end
---
------------------------------------------------------------------ starting

-- vim.lsp.config allows on_init/on_attach/on_exit to be lists; vim.lsp.start
-- wants a single function. Collapse them before handing the config over.
local function as_fn(v)
	if type(v) == "function" then
		return v
	end
	if type(v) == "table" then
		return function(...)
			for _, f in ipairs(v) do
				f(...)
			end
		end
	end
end

local function client_config(root)
	local base = vim.lsp.config["roslyn_ls"]
	if not base then
		error("roslyn_ls is not configured - is nvim-lspconfig on your rtp?")
	end

	local cfg = vim.deepcopy(base)
	cfg.name = "roslyn_ls"
	cfg.root_dir = root -- concrete path; the resolver fn is for auto-start only
	cfg.root_markers = nil
	cfg.filetypes = nil -- meaningless to vim.lsp.start
	cfg.on_init = as_fn(cfg.on_init)
	cfg.on_attach = as_fn(cfg.on_attach)
	cfg.on_exit = as_fn(cfg.on_exit)
	return cfg
end

local function cs_buffers()
	return vim.tbl_filter(function(b)
		return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == "cs"
	end, vim.api.nvim_list_bufs())
end

--- Start roslyn_ls for the current target and attach every C# buffer.
---@return integer? client_id
function M.start()
	local t = M.resolve()
	if not t then
		return vim.notify("No roslyn_ls target selected", vim.log.levels.WARN)
	end

	local cfg = client_config(M.root())
	local bufs = cs_buffers()

	if #bufs == 0 then
		-- Nothing to attach to. vim.lsp.enable will pick the target up via on_init
		-- as soon as a C# buffer appears.
		return vim.notify(("roslyn_ls target set to %s (loads on next C# buffer)"):format(vim.fs.basename(t)))
	end

	-- The first call starts the server; the rest reuse it, since reuse_client
	-- matches on name + root_dir and both are identical across the loop.
	local id
	for _, buf in ipairs(bufs) do
		vim.notify(("roslyn_ls starting %s"):format(vim.fs.basename(t)))
		id = vim.lsp.start(cfg, { bufnr = buf })
	end

	if id ~= nil then
		local client = assert(vim.lsp.get_client_by_id(id))
		vim.notify(("roslyn_ls notifying lsp client to open %s"):format(vim.uri_from_fname(t)))
		client:notify("solution/open", {
			solution = vim.uri_from_fname(t),
		})
	end

	return id
end

--- Stop, then wait for actual process exit before starting the replacement.
local function restart(cb, tries)
	tries = tries or 100
	if tries == 0 or #vim.lsp.get_clients({ name = "roslyn_ls" }) == 0 then
		return cb()
	end
	vim.defer_fn(function()
		restart(cb, tries - 1)
	end, 100)
end

------------------------------------------------------------------ loading

local function slnf_projects(path)
	local fd = io.open(path, "r")
	if not fd then
		return nil
	end
	local raw = fd:read("*a")
	fd:close()
	local ok, data = pcall(vim.json.decode, raw)
	if not ok or type(data) ~= "table" or type(data.solution) ~= "table" then
		return nil
	end
	local base = vim.fs.dirname(path)
	return vim.tbl_map(function(p)
		return vim.fs.normalize(vim.fs.joinpath(base, (p:gsub("\\", "/"))))
	end, data.solution.projects or {})
end

--- Tell a freshly initialised client what to load.
function M.open(client, t)
	vim.notify(("roslyn_ls preparing to open %s"):format(vim.uri_from_fname(t)))
	if t:match("%.slnf$") then
		-- Expand the filter ourselves and use project/open, rather than
		-- handing the .slnf to solution/open and hoping the server parses it.
		local projects = slnf_projects(t)
		if not projects or #projects == 0 then
			return vim.notify("No projects readable from " .. t, vim.log.levels.ERROR)
		end
		vim.notify(("roslyn_ls opening %s"):format(vim.uri_from_fname(t)))
		client:notify("project/open", {
			projects = vim.tbl_map(vim.uri_from_fname, projects),
		})
	else
		client:notify("solution/open", { solution = vim.uri_from_fname(t) })
	end
end

------------------------------------------------------------------ switching

-- Poll rather than vim.wait(): shutting down a large workspace can take
-- seconds, and vim.wait would block the UI for all of it.
local function when_stopped(cb, tries)
	tries = tries or 100
	if tries == 0 or #vim.lsp.get_clients({ name = "roslyn_ls" }) == 0 then
		return cb()
	end
	vim.defer_fn(function()
		when_stopped(cb, tries - 1)
	end, 100)
end

function M.set(t, persist)
	vim.g.roslyn_ls_target = t

	-- neotest-vstest reads this global to decide which solution to load. It has
	-- no .slnf support, so only hand it real solutions.
	if t:match("%.slnx?$") then
		vim.g.roslyn_nvim_selected_solution = t
	end

	if persist then
		local store = read_store()
		store[M.root()] = t
		write_store(store)
	end

	vim.notify(
		("roslyn_ls → %s%s  (loading…)"):format(vim.fs.basename(t), persist and "  [default]" or "  [session]")
	)

	restart(function()
		M.start()
	end)
end

---@param opts? { persist?: boolean }
function M.pick(opts)
	opts = opts or {}
	local persist = opts.persist ~= false
	local root = M.root()
	local saved = M.saved(root)
	local targets = M.scan(root)

	if #targets == 0 then
		return vim.notify("No .sln/.slnx/.slnf under " .. root, vim.log.levels.WARN)
	end

	table.sort(targets, function(a, b)
		if a == saved or b == saved then
			return a == saved
		end
		local af, bf = a:match("%.slnf$") ~= nil, b:match("%.slnf$") ~= nil
		if af ~= bf then
			return af
		end -- filters before full solutions
		return a < b
	end)

	vim.ui.select(targets, {
		prompt = persist and "roslyn_ls target (save as default)" or "roslyn_ls target (session only)",
		format_item = function(item)
			return ((item == saved) and "●" or " ")
				.. ((item == vim.g.roslyn_ls_target) and "→" or " ")
				.. " "
				.. (vim.fs.relpath(root, item) or item)
		end,
	}, function(choice)
		if choice then
			M.set(choice, persist)
		end
	end)
end

function M.clear()
	local store = read_store()
	store[M.root()] = nil
	write_store(store)
	vim.g.roslyn_ls_target = nil
	vim.notify("Cleared default roslyn_ls target for this repo")
end

function M.statusline()
	local t = M.resolve()
	return t and vim.fs.basename(t) or ""
end

return M
