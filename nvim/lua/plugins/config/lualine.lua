require('lualine').setup{
    options = {
        theme = 'catppuccin',
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000
        }
    },
    tabline  = {
        lualine_a = {{
                'tabs',
                max_length = vim.o.columns,
                mode = 1,
            }
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    winbar = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },
}
