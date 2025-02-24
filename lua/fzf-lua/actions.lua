local M = {}

-- return fzf '--expect=' string from actions keyval tbl
M.expect = function(actions)
  if not actions then return '' end
  local keys = {}
  for k, v in pairs(actions) do
    if k ~= "default" and v ~= false then
      table.insert(keys, k)
    end
  end
  if #keys > 0 then
    return table.concat(keys, ',')
  end
  return nil
end

M.act = function(actions, action, selected)
  if not actions or not action then return end
  if #action == 0 then action = "default" end
  if actions[action] then
    actions[action](selected)
  end
end

M.vimcmd = function(vimcmd, selected)
  if not selected or #selected < 2 then return end
  for i = 2, #selected do
    vim.cmd(vimcmd .. " " .. vim.fn.fnameescape(selected[i]))
  end
end

M.vimcmd_file = function(vimcmd, selected)
  if not selected or #selected < 2 then return end
  for i = 2, #selected do
    -- check if the file contains line
    local file, line = selected[i]:match("^([^ :]+):(%d+)")
    if file and line then
      vim.cmd(string.format("%s +%s %s", vimcmd, line, vim.fn.fnameescape(file)))
    else
      vim.cmd(vimcmd .. " " .. vim.fn.fnameescape(selected[i]))
    end
  end
end

-- file actions
M.file_edit = function(selected)
  local vimcmd = "e"
  M.vimcmd_file(vimcmd, selected)
end

M.file_split = function(selected)
  local vimcmd = "new"
  M.vimcmd_file(vimcmd, selected)
end

M.file_vsplit = function(selected)
  local vimcmd = "vnew"
  M.vimcmd_file(vimcmd, selected)
end

M.file_tabedit = function(selected)
  local vimcmd = "tanbew"
  M.vimcmd_file(vimcmd, selected)
end

M.file_sel_to_qf = function(selected)
  if not selected or #selected < 2 then return end
  local qf_list = {}
  for i = 2, #selected do
    -- check if the file contains line
    local file, line, col, text = selected[i]:match("^([^ :]+):(%d+):(%d+):(.*)")
    if file and line and col then
      table.insert(qf_list, {filename = file, lnum = line, col = col, text = text})
    else
      table.insert(qf_list, {filename = selected[i], lnum = 1, col = 1})
    end
  end
  vim.fn.setqflist(qf_list)
  vim.cmd 'copen'
end

-- buffer actions
M.buf_edit = function(selected)
  local vimcmd = "b"
  M.vimcmd(vimcmd, selected)
end

M.buf_split = function(selected)
  local vimcmd = "split | b"
  M.vimcmd(vimcmd, selected)
end

M.buf_vsplit = function(selected)
  local vimcmd = "vertical split | b"
  M.vimcmd(vimcmd, selected)
end

M.buf_tabedit = function(selected)
  local vimcmd = "tab split | b"
  M.vimcmd(vimcmd, selected)
end

M.buf_del = function(selected)
  local vimcmd = "bd"
  M.vimcmd(vimcmd, selected)
end

M.colorscheme = function(selected)
  if not selected or #selected < 2 then return end
  vim.cmd("colorscheme " .. selected[2])
end

M.help = function(selected)
  local vimcmd = "help"
  M.vimcmd(vimcmd, selected)
end

M.help_vert = function(selected)
  local vimcmd = "vert help"
  M.vimcmd(vimcmd, selected)
end

M.help_tab = function(selected)
  local vimcmd = "tab help"
  M.vimcmd(vimcmd, selected)
end

M.man = function(selected)
  local vimcmd = "Man"
  M.vimcmd(vimcmd, selected)
end

M.man_vert = function(selected)
  local vimcmd = "vert Man"
  M.vimcmd(vimcmd, selected)
end

M.man_tab = function(selected)
  local vimcmd = "tab Man"
  M.vimcmd(vimcmd, selected)
end

return M
