return {
	'ahmedkhalf/project.nvim',
	opts = {},
	config = function ()
		require("project_nvim").setup{
			patterns = {
				".git",
				"package.json",
				"root",
			}
		}
	end
}
