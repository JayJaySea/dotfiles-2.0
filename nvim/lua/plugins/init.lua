local conf_path = vim.fn.stdpath("config")

local plugins = {
    {
        "catppuccin/nvim",
        lazy = true,
        priority = 1000,
        name = "catppuccin",
        init = function()
        vim.cmd.colorscheme("catppuccin")
        end,
        config = function()
        require("catppuccin").setup(require("plugins.config.colorscheme"))
        end,
    },
    {
        name = "spark",
        dir = "/home/xxxx/projects/rust/spark-nvim",
        lazy = false,
        dependencies = {
            'nvim-telescope/telescope.nvim'
        },
        config = function()
            require("core.mappings").spark()
            require("spark").set_autosave_note()
        end,
    },
    {
        "okuuva/auto-save.nvim",
        config = require("plugins.config.autosave")
    },
    {
        "michaelrommel/nvim-silicon",
	lazy = false,
	cmd = "Silicon",
	config = function()
            require("core.mappings").silicon()
            require("silicon").setup({
                font = "JetBrainsMono Nerd Font=34;Noto Color Emoji=34",
                theme = "OneHalfDark",
                to_clipboard = true,
                output = function()
                    return "/home/xxxx/pictures/code/" .. os.date("!%Y-%m-%dT%H-%M-%S") .. ".png"
                end,
                background = "#87cefa"
            })
	end
    },
    {
        "echasnovski/mini.nvim",
        name = "mini",
        lazy = false,
        version = false,
        event = { "InsertEnter" },
        config = function()
            local mini_config = require "plugins.config.mini_nvim"
            local mini_modules = {
                "ai",
                "comment",
                "hipatterns",
                "bufremove",
                "move",
                "extra",
            }
            require("core.mappings").mini()
            for _, module in ipairs(mini_modules) do
                require("mini." .. module).setup(mini_config[module])
            end
        end,
    },
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function ()

            local actions = require "telescope.actions"
            require("core.mappings").telescope()
            require('telescope').setup {
                defaults = {
                    mappings = {
                        i = {
                          ["<C-e>"] = actions.move_selection_next,
                          ["<C-i>"] = actions.move_selection_previous,
                        },
                        n = {
                          ["<C-e>"] = actions.move_selection_next,
                          ["<C-i>"] = actions.move_selection_previous,
                        }
                    }
                }
            }
        end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        name = "tree",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
          -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        config = function ()
            require("core.mappings").tree()
            local opts = require("plugins.config.tree").tree
            require("neo-tree").setup(opts)
        end
    },
    {
        "windwp/nvim-autopairs",
        init = function ()
            require("plugins.config.autopairs")
        end,
        config = {

        }
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        name = "treesitter",
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        build = ":TSUpdate",
        event = {
            "BufReadPre",
            "BufNewFile",
        },
        config = function()
            local opts = require("plugins.config.fancy").treesitter
            require("nvim-treesitter").setup(opts)
            vim.api.nvim_command([[autocmd VimEnter * TSEnable highlight]])
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        name = "cmp",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "L3MON4D3/LuaSnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        event = { "LspAttach", "InsertCharPre" },
        config = function()
            require "plugins.config.cmp"
            require("core.mappings").cmp()
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    {
        "ThePrimeagen/harpoon",

        config = function ()
            require("core.mappings").harpoon()
        end
    },
    {
        "ggandor/leap.nvim",
        lazy = false,
        init = function ()
            require('leap').add_default_mappings()
        end
    },
    --- lsp stuffs
    {
        "neovim/nvim-lspconfig",
        name = "lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        event = {
            "LspAttach",
        },
        init = function()
            require("core.utils").lazy_load "lspconfig"
        end,
        config = function()
            require "plugins.config.lsp"
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'kyazdani42/nvim-web-devicons',
        },
        config = function ()
            require("plugins.config.lualine")
        end
    },
    {
        name = "options",
        event = "VeryLazy",
        dir = conf_path,
        config = function()
            require("core.opts").final()
            require("core.mappings").general()
            pcall(vim.cmd.rshada, { bang = true })
        end,
    },
}



require("lazy").setup(plugins, require("plugins.config.lazy_nvim"))
require("plugins.config.servers")
