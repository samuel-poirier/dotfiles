local tui = require("utils/tui-utils")

local M = {}

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

-- root -> last project the user picked, so the next launch defaults to it
local last_pick = {}

local function root()
  return require("utils.roslyn-solution").root()
end

local function project_name(project)
  return vim.fn.fnamemodify(project, ":t:r")
end

local function mtime(path)
  local st = vim.uv.fs_stat(path)
  return st and st.mtime.sec or 0
end

------------------------------------------------------------------ discovery

--- Every *.csproj / *.fsproj under the repo root.
function M.scan_projects(r)
  r = r or root()
  local out = {}
  for name, type_ in
    vim.fs.dir(r, {
      depth = 6,
      skip = function(dir)
        return not SKIP[dir]
      end,
    })
  do
    if type_ == "file" and name:match("%.[cf]sproj$") then
      table.insert(out, vim.fs.joinpath(r, name))
    end
  end
  return out
end

--- Newest build output for a project. Debug wins over Release at equal age, and
--- the `ref/` and `refint/` reference assemblies are never runnable.
function M.find_dll(project)
  local dir = vim.fs.dirname(project)
  local name = project_name(project)
  local found = {}

  for _, conf in ipairs({ "Debug", "Release" }) do
    for _, pattern in ipairs({ conf .. "/" .. name .. ".dll", conf .. "/**/" .. name .. ".dll" }) do
      for _, dll in ipairs(vim.fn.glob(vim.fs.joinpath(dir, "bin", pattern), false, true)) do
        if not (dll:match("/ref/") or dll:match("/refint/")) then
          found[dll] = conf
        end
      end
    end
  end

  local candidates = vim.tbl_keys(found)
  table.sort(candidates, function(a, b)
    local ma, mb = mtime(a), mtime(b)
    if ma ~= mb then
      return ma > mb
    end
    return found[a] == "Debug"
  end)

  return candidates[1]
end

------------------------------------------------------------------ building

--- @param project string
--- @param on_done fun(ok: boolean)
function M.build(project, on_done)
  local spinner = tui.start_spinner("Building " .. project_name(project))

  vim.system({
    "dotnet",
    "build",
    project,
    "-nologo",
    "-tl:off",
    "-v:m",
    "-clp:NoSummary",
    "-p:GenerateFullPaths=true",
  }, { text = true, cwd = vim.fs.dirname(project) }, function(obj)
    vim.schedule(function()
      spinner.stop()
      if obj.code ~= 0 then
        vim.notify(
          "dotnet build failed:\n" .. ((obj.stdout or "") .. (obj.stderr or "")),
          vim.log.levels.ERROR
        )
        return on_done(false)
      end
      on_done(true)
    end)
  end)
end

------------------------------------------------------------------ picking

--- @param cb fun(project: string|nil) always called, nil when nothing was picked
function M.pick_project(cb)
  local r = root()
  local projects = M.scan_projects(r)

  if #projects == 0 then
    vim.notify("No .csproj/.fsproj under " .. r, vim.log.levels.WARN)
    return cb(nil)
  end

  local saved = last_pick[r]
  table.sort(projects, function(a, b)
    if a == saved or b == saved then
      return a == saved
    end
    return a < b
  end)

  vim.ui.select(projects, {
    prompt = "Debug which project?",
    format_item = function(item)
      return ((item == saved) and "● " or "  ") .. (vim.fs.relpath(r, item) or item)
    end,
  }, function(choice)
    if not choice then
      return cb(nil)
    end
    last_pick[r] = choice
    cb(choice)
  end)
end

--- Pick a project, build it, resolve its dll. Returns a coroutine so it can be
--- used as a `program` field inside a dap configuration.
function M.pick_dll()
  return coroutine.create(function(dap_co)
    local dap = require("dap")

    -- vim.ui.select may answer synchronously (the builtin one does), in which
    -- case dap_co has not yielded yet and resuming it would error. Defer.
    local function finish(value)
      vim.schedule(function()
        coroutine.resume(dap_co, value)
      end)
    end

    M.pick_project(function(project)
      if not project then
        return finish(dap.ABORT)
      end
      M.build(project, function(ok)
        if not ok then
          return finish(dap.ABORT)
        end
        local dll = M.find_dll(project)
        if not dll then
          vim.notify("No build output found for " .. project_name(project), vim.log.levels.ERROR)
        end
        finish(dll or dap.ABORT)
      end)
    end)
  end)
end

------------------------------------------------------------------ launching

--- Pick a project, build it and start a coreclr session against its dll. Unlike
--- the `dap.configurations.cs` entry this can set `cwd` to the project folder,
--- because nothing has to be resolved by nvim-dap.
function M.launch()
  M.pick_project(function(project)
    if not project then
      return
    end
    M.build(project, function(ok)
      if not ok then
        return
      end
      local dll = M.find_dll(project)
      if not dll then
        return vim.notify("No build output found for " .. project_name(project), vim.log.levels.ERROR)
      end
      require("dap").run({
        type = "coreclr",
        name = project_name(project),
        request = "launch",
        program = dll,
        cwd = vim.fs.dirname(project),
        stopAtEntry = false,
        justMyCode = false,
        env = {
          ASPNETCORE_ENVIRONMENT = "Development",
          DOTNET_ENVIRONMENT = "Development",
        },
      })
    end)
  end)
end

function M.attach()
  require("dap").run({
    type = "coreclr",
    name = "Attach to process",
    request = "attach",
    processId = require("dap.utils").pick_process,
  })
end

return M
