require("auto-session").setup({
	-- Configure the plugin to autosave a session, but not auto-restore it.
	auto_session_enabled = true,
	auto_save_enabled = true,
	auto_restore_enabled = false,
})

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
