local M = {}

M.generate_potential_alternatives = function(active_file, config)
  local alternative_files = {}

  for file_ext, possible_other_ext in pairs(config) do
    local ext_length = #file_ext * -1
    local file_matches_ext = string.sub(active_file, ext_length) == file_ext
    if file_matches_ext then
      for _, possible_alternative_ext in ipairs(possible_other_ext) do
        local active_file_without_ext = string.sub(active_file, 1, #active_file - #file_ext)
        local possible_path = active_file_without_ext .. possible_alternative_ext
        table.insert(alternative_files, possible_path)
      end
    end
  end
  return alternative_files
end

-- local alternates = generate_potential_alternatives("/route-costs-breakdown/foo.ts", {
--   [".test.ts"] = { ".ts" },
--   [".ts"] = { ".test.ts", ".css" },
--   [".css"] = { ".ts" },
-- })

M.get_alternative_files = function(config)
  local current_file = vim.api.nvim_buf_get_name(0)
  local possibles = M.generate_potential_alternatives(current_file, config.patterns)

  local filtered_possibles = {}
  for _, potential_file in ipairs(possibles) do
    if config.filter then
      if config.filter(potential_file) then
        table.insert(filtered_possibles, potential_file)
      end
    else
      table.insert(filtered_possibles, potential_file)
    end
  end

  return filtered_possibles
end

return M
