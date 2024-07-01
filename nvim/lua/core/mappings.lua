local opts = { noremap = true, silent = true }
local utils = require "core.utils"
local M = {}

local map = function(mode, lhs, rhs, options)
  vim.keymap.set(mode, lhs, rhs, options)
end

M.general = function()
    map("n", "<Esc>", "<cmd>noh<CR>")
    map("n", "<C-i>", "<C-y>")
    map("t", "<C-e>", "<C-\\><C-n>")

    map("n", "<C-k>", "<C-w>h", opts)
    map("n", "<C-j>", "<C-w>l", opts)
    map("n", "<C-Left>", "<C-w>h", opts)
    map("n", "<C-Right>", "<C-w>l", opts)
    map("n", "<C-Up>", "<C-w>k", opts)
    map("n", "<C-Down>", "<C-w>j", opts)
    map("n", "<C-\\>", "<cmd>vs<CR>", opts)

    map("n", "<s-h>", "<cmd>tabprev<CR>", opts)
    map("n", "<s-l>", "<cmd>tabnext<CR>", opts)
    map("n", "<s-Left>", "<cmd>tabprev<CR>", opts)
    map("n", "<s-Right>", "<cmd>tabnext<CR>", opts)
    map("n", "<s-Down>", "<cmd>bnext<CR>", opts)
    map("n", "<s-Up>", "<cmd>bprev<CR>", opts)
    map("n", "<C-d>", "<C-d>zz", opts)
    map("n", "<C-u>", "<C-u>zz", opts)
    map("v", "//", 'y/<C-R>"<cr>', opts)
end

M.terminal = function()
    map({ "n", "t" }, "<A-t>", function()
        require("nvterm.terminal").toggle "float"
    end, opts)

    map({ "n", "t" }, "<A-h>", function()
        require("nvterm.terminal").toggle "horizontal"
    end, opts)

    map({ "n", "t" }, "<A-H>", function()
        require("nvterm.terminal").toggle "vertical"
    end, opts)

    map({ "n", "t" }, "<A-R>", function()
        utils.run_command()
    end, opts)
end

M.silicon = function ()
    map("v", "<C-s>", "<cmd>Silicon<CR>", opts)
end

M.spark = function ()
    local spark = require("spark")
    if spark.check_spark() then
        vim.api.nvim_set_keymap('n', 'gn', ':lua require("spark").follow_reference(vim.v.count1)<CR>', { noremap = true })
        map("n", "gan", function ()
            spark.add_reference("notes")
        end, opts)
        map("n", "gas", function ()
            spark.add_reference("sources")
        end, opts)
        map("n", "<C-o>", function ()
            spark.open_note()
        end, opts)
    end
end

M.telescope = function()
    local builtin = require("telescope.builtin")
    map({ "n" }, "<C-o>", function()
        builtin.find_files()
    end, opts)

    map({ "n" }, "<C-g>", function()
        builtin.live_grep()
    end, opts)
end

M.mini = function()
    local MiniPick = require "mini.pick"
    local builtin = MiniPick.builtin
    vim.b[0].miniindentscope_disable = true

    map({ "n" }, "<C-q>", function()
        require("mini.bufremove").delete()
    end, opts)
end

M.tree = function ()
    map("n", "<C-f>", "<cmd>Neotree toggle<CR>", opts)
end

M.harpoon = function ()

    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")
    local term = require("harpoon.term")

    local toggle_terminals = function()
        if vim.bo.filetype == '' then
            if not pcall(ui.nav_file, CURRENT_ID) then
                ui.nav_prev()
            end
            local count = mark.get_length()

            if count ~= COUNT then
                mark.rm_file(count)
            end
        else
            COUNT = mark.get_length()
            mark.add_file()
            CURRENT_ID = mark.get_current_index()
            term.gotoTerminal(1)
            vim.cmd('startinsert')
        end
    end

    map("n", "<C-space>", mark.add_file, opts)
    map("n", "<C-h>", ui.toggle_quick_menu, opts)
    map("n", "<C-n>", ui.nav_next, opts)
    map("n", "<C-p>", ui.nav_prev, opts)
    map("n", "<C-1>", function() ui.nav_file(1) end, opts)
    map("n", "<C-2>", function() ui.nav_file(2) end, opts)
    map("n", "<C-3>", function() ui.nav_file(3) end, opts)
    map("n", "<C-4>", function() ui.nav_file(4) end, opts)
    map("n", "<C-t>", toggle_terminals)
    map("t", "<C-t>", toggle_terminals)
end

M.lsp = function()
  -- map the following keys on lsp attach only
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        map("n", "<space>d", vim.diagnostic.open_float, opts)
        map("n", "[d", vim.diagnostic.goto_prev, opts)
        map("n", "]d", vim.diagnostic.goto_next, opts)
        map("n", "<space>sd", vim.diagnostic.setloclist, opts)
        map("n", "<leader>hi", function()
            utils.toggle_inlay_hint() -- toggle inlay hint
        end, opts)

        map("n", "gi", vim.lsp.buf.hover, opts)
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "<leader>it", vim.lsp.buf.type_definition, opts)
        map("n", "<leader>ii", vim.lsp.buf.implementation, opts)
        map("n", "<leader>ir", vim.lsp.buf.references, opts)
        map({ "n", "v" }, "<leader>ia", vim.lsp.buf.code_action, opts)
        map("n", "<leader>if", vim.lsp.buf.format, opts)
        map("n", "<leader>ic", vim.lsp.buf.rename, opts)
        -- map({ "i", "s" }, "<c-space>", vim.lsp.buf.signature_help, opts)
    end,
  })
end

M.cmp = function()
    -- local cmp = require("cmp")
    -- map("i", "<C-i>", cmp.mapping.select_prev_item())
    -- map("i", "<C-e>", cmp.mapping.select_next_item())
end

return M
