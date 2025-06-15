vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.wo.number = true
vim.wo.relativenumber = true
-- 기본 설정
vim.g.mapleader = " "

-- vim.nnoremap("<C-d>", "<C-d>zz")
-- vim.nnoremap("<C-u>", "<C-u>zz")
-- vim.nnoremap("n", "nzzzv")
-- vim.nnoremap("N", "Nzzzv")

vim.diagnostic.config({
  virtual_text = {
    prefix = '■',  -- or '■', '▶', etc.
    spacing = 6,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
