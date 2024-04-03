vim.api.nvim_exec(
  -- Disable the emmet C-y default, else every C-y has a wait. It has to be set to something that I never use.
  -- And then sent C-e to expand emmet
  [[
  let g:user_emmet_leader_key='<C-9>'
  let g:user_emmet_expandabbr_key = '<C-e>'
]],
  false
)
