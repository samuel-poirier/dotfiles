local M = {}

--- Root of the dotnet installation: $DOTNET_ROOT, else the directory holding
--- the `dotnet` on $PATH (resolving the symlink distros usually put in /usr/bin).
---@return string?
function M.root()
  local env = vim.env.DOTNET_ROOT
  if env and env ~= "" and vim.uv.fs_stat(env) then
    return vim.fs.normalize(env)
  end

  local exe = vim.fn.exepath("dotnet")
  if exe == "" then
    return nil
  end

  return vim.fs.dirname(vim.fs.normalize(vim.uv.fs_realpath(exe) or exe))
end

local function newest(versions)
  table.sort(versions, function(a, b)
    local va = vim.version.parse(a, { strict = false })
    local vb = vim.version.parse(b, { strict = false })
    if va and vb then
      return vim.version.gt(va, vb)
    end
    return a > b
  end)
  return versions[1]
end

--- Ask the cli where its sdks live. Locale independent, unlike `dotnet --info`,
--- because the path is bracketed: "9.0.317 [/usr/share/dotnet/sdk]".
---@return string?
local function sdk_dir_from_cli()
  if vim.fn.executable("dotnet") == 0 then
    return nil
  end

  local obj = vim.system({ "dotnet", "--list-sdks" }, { text = true }):wait(5000)
  if obj.code ~= 0 or not obj.stdout then
    return nil
  end

  for _, line in ipairs(vim.split(obj.stdout, "\n", { trimempty = true })) do
    local dir = line:match("^%S+%s+%[(.+)%]%s*$")
    if dir then
      return vim.fs.normalize(dir)
    end
  end
end

--- Versioned sdk directory that actually contains vstest.console.dll, newest first.
---
--- neotest-vstest finds this by grepping `dotnet --info` for "Base Path:", which
--- only matches when the cli is running in English, and otherwise falls back to
--- the macOS install path. Resolving it from the filesystem avoids both traps.
---@return string?
function M.vstest_path()
  local roots = {}

  local root = M.root()
  if root then
    table.insert(roots, vim.fs.joinpath(root, "sdk"))
  end

  local from_cli = sdk_dir_from_cli()
  if from_cli and from_cli ~= roots[1] then
    table.insert(roots, from_cli)
  end

  for _, sdk_dir in ipairs(roots) do
    local stat = vim.uv.fs_stat(sdk_dir)
    if stat and stat.type == "directory" then
      local versions = {}
      for name, type_ in vim.fs.dir(sdk_dir) do
        if
          type_ == "directory"
          and vim.uv.fs_stat(vim.fs.joinpath(sdk_dir, name, "vstest.console.dll"))
        then
          table.insert(versions, name)
        end
      end
      local version = newest(versions)
      if version then
        return vim.fs.joinpath(sdk_dir, version)
      end
    end
  end
end

return M
