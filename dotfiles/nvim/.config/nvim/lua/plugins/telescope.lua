return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local builtin = require("telescope.builtin")
		--vim.keymap.set("n", "<C-f>", builtin.find_files, {
		--	hidden = true,
		--})

		vim.keymap.set("n", "<C-f>", function()
			builtin.find_files({
				hidden = true,
				--no_ignore = true
			})
		end)

		vim.keymap.set("n", "<leader>ff", function()
			builtin.live_grep({
				--hidden = true,
				additional_args = function()
					return { "--hidden", "--no-ignore" }
				end,
			})
		end)
	end,
}
