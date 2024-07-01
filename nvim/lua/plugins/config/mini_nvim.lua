local M = {}

M.surround = {}

M.files = {
    windows = { preview = false, width_focus = 25, width_preview = 40, height_focus = 20, border = "solid" },
    use_as_default_explorer = true,
    mappings = {
        close = "<Esc>",
    },
}

M.hipatterns = {}

M.bufremove = {
    silent = true,
}

vim.b.miniindentscope_disable = true

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Disable 'mini.indentscope' in terminal buffer",
    callback = function(data)
    vim.b[data.buf].miniindentscope_disable = true
    end,
})
M.completion = {
    window = {
        info = { border = "rounded" },
        signature = { border = "rounded" },
    },
}

M.ai = {}

return M
