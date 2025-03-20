local has_telescope, telescope = pcall(require, "telescope")
local has_treesitter, _ = pcall(require, "nvim-treesitter")
local treesitter_info = require("treesitter_info")

if not has_telescope then
	error("This extension requires 'telescope.nvim'. (https://github.com/nvim-telescope/telescope.nvim)")
end

if not has_treesitter then
	error("This extension requires 'nvim-treesitter'. (https://github.com/nvim-treesitter/nvim-treesitter)")
end

return telescope.register_extension({
	exports = {
		treesitter_info = treesitter_info.info,
	},
})
