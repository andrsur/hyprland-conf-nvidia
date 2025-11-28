-- ~/.config/nvim/init.lua

-- Базовые настройки
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Прозрачность - отключаем фон Neovim
vim.opt.termguicolors = true
vim.cmd[[highlight Normal guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight NonText guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight LineNr guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight Folded guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight EndOfBuffer guibg=NONE ctermbg=NONE]]
vim.cmd[[highlight SignColumn guibg=NONE ctermbg=NONE]]

-- Отключаем автоудаление пробелов
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function() end
})

-- Плагины
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Файловый менеджер
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
    end
  },

  -- Подсветка синтаксиса
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "rust" },
        highlight = { enable = true },
      })
    end
  },

  -- LSP и автодополнение
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      -- Настройка автодополнения
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        })
      })

      -- Базовые LSP привязки клавиш
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {desc = "Go to definition"})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {desc = "Hover documentation"})
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, {desc = "Find references"})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {desc = "Rename symbol"})
    end
  },
})

-- Горячие клавиши для файлового менеджера
vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<CR>')

-- Автокоманды для запуска LSP только для соответствующих файлов
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"rust"},
  callback = function(args)
    local bufnr = args.buf
    
    -- Запускаем rust-analyzer только для Rust файлов
    require('vim.lsp').start({
      name = 'rust-analyzer',
      cmd = {'rust-analyzer'},
      bufnr = bufnr,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        }
      }
    })
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp"},
  callback = function(args)
    local bufnr = args.buf
    
    -- Запускаем clangd только для C/C++ файлов
    require('vim.lsp').start({
      name = 'clangd',
      cmd = {'clangd'},
      bufnr = bufnr,
    })
  end
})

-- Дополнительные настройки для прозрачности плавающих окон
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Убираем фон у различных элементов интерфейса
    vim.cmd[[highlight NormalFloat guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight FloatBorder guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight TelescopeNormal guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight TelescopeBorder guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight NvimTreeNormal guibg=NONE ctermbg=NONE]]
  end
})
