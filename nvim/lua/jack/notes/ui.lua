local M = {}

M.input_prompt = function(callback_func)
  vim.ui.input({
    prompt = "File name (without the extension): ",
  }, function(choice)
    callback_func(choice)
  end)
end

M.history_list = function(history_table, callback_func)
  local table_empty = true
  local recent_notes_list = {}
  for key, _ in pairs(history_table) do
    table_empty = false
    table.insert(recent_notes_list, key)
  end
  if table_empty then
    print("Notes: no recent notes to show")
    return
  end
  vim.ui.select(recent_notes_list, {
    prompt = "Pick a recent note:",
  }, function(choice)
    callback_func(choice)
  end)
end

return M
