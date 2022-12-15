local plugins = require("jack.plugins")
M = {}

M.init = function()
	return require("packer").startup(function(use)
		plugins.load_plugins(use)
	end)
end
return M
