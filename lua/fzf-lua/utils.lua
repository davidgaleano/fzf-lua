-- help to inspect results, e.g.:
-- ':lua _G.dump(vim.fn.getwininfo())'
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
end

local M = {}

M._if = function(bool, a, b)
    if bool then
        return a
    else
        return b
    end
end

function M._echo_multiline(msg)
  for _, s in ipairs(vim.fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''").."'")
  end
end

function M.info(msg)
  vim.cmd('echohl Directory')
  M._echo_multiline("[Fzf-lua] " .. msg)
  vim.cmd('echohl None')
end

function M.warn(msg)
  vim.cmd('echohl WarningMsg')
  M._echo_multiline("[Fzf-lua] " .. msg)
  vim.cmd('echohl None')
end

function M.err(msg)
  vim.cmd('echohl ErrorMsg')
  M._echo_multiline("[Fzf-lua] " .. msg)
  vim.cmd('echohl None')
end

function M.shell_error()
  return vim.v.shell_error ~= 0
end

function M.is_git_repo()
  vim.fn.system("git status")
  return M._if(M.shell_error(), false, true)
end

M.read_file = function(filepath)
  local fd = vim.loop.fs_open(filepath, "r", 438)
  if fd == nil then return '' end
  local stat = assert(vim.loop.fs_fstat(fd))
  if stat.type ~= 'file' then return '' end
  local data = assert(vim.loop.fs_read(fd, stat.size, 0))
  assert(vim.loop.fs_close(fd))
  return data
end

M.read_file_async = function(filepath, callback)
  vim.loop.fs_open(filepath, "r", 438, function(err_open, fd)
    if err_open then
      print("We tried to open this file but couldn't. We failed with following error message: " .. err_open)
      return
    end
    vim.loop.fs_fstat(fd, function(err_fstat, stat)
      assert(not err_fstat, err_fstat)
      if stat.type ~= 'file' then return callback('') end
      vim.loop.fs_read(fd, stat.size, 0, function(err_read, data)
        assert(not err_read, err_read)
        vim.loop.fs_close(fd, function(err_close)
          assert(not err_close, err_close)
          return callback(data)
        end)
      end)
    end)
  end)
end


function M.tbl_deep_clone(t)
  if not t then return end
  local clone = {}

  for k, v in pairs(t) do
    if type(v) == "table" then
      clone[k] = M.tbl_deep_clone(v)
    else
      clone[k] = v
    end
  end

  return clone
end

function M.tbl_length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function M.tbl_has(table, key)
  return table[key] ~= nil
end

function M.tbl_or(key, tbl1, tbl2)
  if tbl1[key] ~= nil then return tbl1[key]
  else return tbl2[key] end
end

function M.tbl_concat(...)
  local result = {}
  local n = 0

  for _, t in ipairs({...}) do
    for i, v in ipairs(t) do
      result[n + i] = v
    end
    n = n + #t
  end

  return result
end

function M.tbl_pack(...)
  return {n=select('#',...); ...}
end

function M.tbl_unpack(t, i, j)
  return unpack(t, i or 1, j or t.n or #t)
end

M.ansi_codes = {}
M.ansi_colors = {
    clear       = "\x1b[0m",
    bold        = "\x1b[1m",
    black       = "\x1b[0;30m",
    red         = "\x1b[0;31m",
    green       = "\x1b[0;32m",
    yellow      = "\x1b[0;33m",
    blue        = "\x1b[0;34m",
    magenta     = "\x1b[0;35m",
    cyan        = "\x1b[0;36m",
    grey        = "\x1b[0;90m",
    dark_grey   = "\x1b[0;97m",
    white       = "\x1b[0;98m",
}

for color, escseq in pairs(M.ansi_colors) do
    M.ansi_codes[color] = function(string)
        if string == nil or #string == 0 then return '' end
        return escseq .. string .. M.ansi_colors.clear
    end
end

function M.get_visual_selection()
    -- must exit visual mode or program croaks
    -- :visual leaves ex-mode back to normal mode
    -- use 'gv' to reselect the text
    vim.cmd[[visual]]
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
    local lines = vim.fn.getline(csrow, cerow)
    -- local n = cerow-csrow+1
    local n = M.tbl_length(lines)
    if n <= 0 then return '' end
    lines[n] = string.sub(lines[n], 1, cecol)
    lines[1] = string.sub(lines[1], cscol)
    print(n, csrow, cscol, cerow, cecol, table.concat(lines, "\n"))
    return table.concat(lines, "\n")
end

return M
