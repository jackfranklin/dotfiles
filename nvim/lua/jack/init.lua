local plugins = require("jack.plugins")
M = {}

M.packer = function()
	return require("packer").startup(function(use)
		plugins.load_plugins(use)
	end)
end
return M
