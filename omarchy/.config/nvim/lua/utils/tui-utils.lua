local M = {}

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

function M.open_spinner_win(text)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = #text + 4
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "SE",
    row = vim.o.lines - 3,
    col = vim.o.columns - 2,
    width = width,
    height = 1,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
  })
  vim.wo[win].winhl = "Normal:NormalFloat"
  return buf, win
end

function M.start_spinner(text)
  local buf, win = M.open_spinner_win(text .. "  " .. spinner_frames[1])
  local frame = 1
  local timer = assert(vim.loop.new_timer())

  timer:start(0, 80, function()
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        timer:stop()
        timer:close()
        return
      end
      frame = (frame % #spinner_frames) + 1
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  " .. text .. "  " .. spinner_frames[frame] })
    end)
  end)

  return {
    stop = function()
      timer:stop()
      timer:close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  }
end

return M
