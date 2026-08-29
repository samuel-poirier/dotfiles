local tui = require("utils/tui-utils")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name ~= "roslyn_ls" then
      return
    end
    local roslyn = require("utils.roslyn-solution")
    vim.api.nvim_create_user_command("RoslynTarget", function(o)
      roslyn.pick({ persist = not o.bang })
    end, { bang = true, desc = "Pick roslyn_ls target (! = session only)" })

    vim.api.nvim_create_user_command("RoslynTargetClear", function()
      roslyn.clear()
    end, { desc = "Forget this repo's default target" })

    vim.keymap.set("n", "<leader>cs", function()
      roslyn.pick()
    end, { desc = "Roslyn: pick target (default)" })

    vim.keymap.set("n", "<leader>cS", function()
      roslyn.pick({ persist = false })
    end, { desc = "Roslyn: pick target (session)" })

    local dotnetModule = require("utils/dotnet-module")

    local dotnet_build_ns = vim.api.nvim_create_namespace("dotnet_build")

    -- Keep a reference to the output buffer so we can reuse/update it
    local build_output_bufnr = nil

    local function get_or_create_output_buf()
      if build_output_bufnr and vim.api.nvim_buf_is_valid(build_output_bufnr) then
        return build_output_bufnr
      end
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].buftype = "nofile"
      vim.bo[buf].bufhidden = "hide"
      vim.bo[buf].swapfile = false
      vim.bo[buf].filetype = "dotnet-build-output"
      build_output_bufnr = buf
      return buf
    end

    local function set_output_lines(lines)
      local buf = get_or_create_output_buf()
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
    end
    vim.keymap.set("n", "<Leader>cb", function()
      local sln = roslyn.resolve()
      if not sln then
        return vim.notify("No roslyn_ls target selected", vim.log.levels.WARN)
      end

      -- Clear previous build diagnostics from all buffers
      vim.diagnostic.reset(dotnet_build_ns)

      local output_lines = {}
      local spinner = tui.start_spinner("Building solution")

      vim.fn.jobstart(
        "dotnet build /property:GenerateFullPaths=true /v:q /clp:NoSummary /clp:ErrorsOnly " .. vim.fn.shellescape(sln),
        {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data then
              for _, line in ipairs(data) do
                if line ~= "" then
                  table.insert(output_lines, line)
                end
              end
            end
          end,
          on_exit = function(_, code)
            vim.schedule(function()
              spinner.stop()
              set_output_lines(output_lines)

              -- Pattern for: /full/path/File.cs(12,34): error CS1002: message [Proj.csproj]
              local pattern = "^(.-)%((%d+),(%d+)%)%s*:%s*error%s+([%w]+)%s*:%s*(.*)$"

              local diagnostics_by_file = {}

              for _, line in ipairs(output_lines) do
                local file, lnum, col, code_id, message = line:match(pattern)
                if file then
                  message = message:gsub("%s*%[.-%]%s*$", "")

                  diagnostics_by_file[file] = diagnostics_by_file[file] or {}
                  table.insert(diagnostics_by_file[file], {
                    lnum = tonumber(lnum) - 1,
                    col = tonumber(col) - 1,
                    severity = vim.diagnostic.severity.ERROR,
                    message = string.format("[%s] %s", code_id, message),
                    source = "dotnet build",
                  })
                end
              end

              local total = 0
              for file, diags in pairs(diagnostics_by_file) do
                local bufnr = vim.fn.bufadd(file)
                vim.fn.bufload(bufnr)
                vim.diagnostic.set(dotnet_build_ns, bufnr, diags)
                total = total + #diags
              end

              if code ~= 0 then
                vim.notify(string.format("Build failed: %d error(s) found", total), vim.log.levels.ERROR)
              else
                vim.notify("Build succeeded", vim.log.levels.INFO)
              end
            end)
          end,
        }
      )
    end, { desc = "Dotnet build" })

    vim.keymap.set("n", "<Leader>do", function()
      local buf = get_or_create_output_buf()
      vim.cmd("botright split")
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_win_set_height(0, 15)
    end, { desc = "Dotnet build output" })

    vim.keymap.set("n", "<Leader>dr", function()
      local sln = roslyn.resolve()
      if not sln then
        return vim.notify("No roslyn_ls target selected", vim.log.levels.WARN)
      end
      dotnetModule.run_in_terminal(
        "dotnet clean " .. vim.fn.shellescape(sln) .. " && dotnet build " .. vim.fn.shellescape(sln)
      )
    end, { desc = "Dotnet rebuild" })

    vim.keymap.set("n", "<Leader>dt", function()
      local sln = roslyn.resolve()
      if not sln then
        return vim.notify("No roslyn_ls target selected", vim.log.levels.WARN)
      end
      local test_name = dotnetModule.get_qualified_test_name()
      if test_name then
        dotnetModule.run_in_terminal(
          "dotnet test " .. vim.fn.shellescape(sln) .. ' --filter "FullyQualifiedName~' .. test_name .. '"'
        )
      end
    end, { desc = "Dotnet test (focused test)" })

    local efm = table.concat({
      "%f(%l\\,%c): %trror %m",
      "%f(%l\\,%c): %tarning %m",
      "%f(%l): %trror %m",
      "%f(%l): %tarning %m",
      "%-G%.%#", -- discard everything else
    }, ",")

    local function dotnet_diagnostics(target)
      target = target or roslyn.resolve()
      if not target then
        return vim.notify("No Roslyn target selected", vim.log.levels.ERROR)
      end

      local spinner = tui.start_spinner("Building solution" .. vim.fs.basename(target))

      vim.system({
        "dotnet",
        "build",
        target,
        "-nologo",
        "-tl:off", -- terminal logger mangles parseable output
        "-v:m", -- minimal: errors + warnings, no noise
        "-clp:NoSummary",
        "-p:GenerateFullPaths=true", -- critical, or quickfix can't resolve paths
        "-p:EnforceCodeStyleInBuild=true", -- include IDExxxx style analyzers
        "-m",
      }, { text = true, cwd = vim.fs.dirname(target) }, function(obj)
        vim.schedule(function()
          local out = vim.split((obj.stdout or "") .. (obj.stderr or ""), "\n", { trimempty = true })
          vim.fn.setqflist({}, " ", { title = "dotnet build", lines = out, efm = efm })

          -- multi-targeted projects report each diagnostic once per TFM
          local seen, items = {}, {}
          for _, it in ipairs(vim.fn.getqflist()) do
            local key = ("%d:%d:%d:%s"):format(it.bufnr, it.lnum, it.col, it.text)
            if not seen[key] then
              seen[key] = true
              items[#items + 1] = it
            end
          end
          vim.fn.setqflist({}, "r", { title = "dotnet build", items = items })

          if #items > 0 then
            vim.cmd("botright copen")
            vim.notify(("%d diagnostics"):format(#items), vim.log.levels.WARN)
          else
            vim.cmd("cclose")
            vim.notify("Build clean")
          end
          spinner.stop()
        end)
      end)
    end

    vim.api.nvim_create_user_command("DotnetDiagnostics", function(o)
      dotnet_diagnostics(o.args ~= "" and o.args or nil)
    end, {
      nargs = "?",
      complete = "file",
      desc = "Build target and load diagnostics into quickfix",
    })

    vim.keymap.set("n", "<leader>cD", dotnet_diagnostics, { desc = "Dotnet: solution diagnostics" })
  end,
})
