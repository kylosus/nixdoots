{
  params,
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    colorschemes.oxocarbon.enable = true;

    globals = {
      mapleader = " ";
    };

    options = {
      number = true; # Show line numbers
      shiftwidth = 2; # Tab width should be 2
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      smartcase = true;
      smartindent = true;
      hidden = true;
      wrap = false;
      termguicolors = true;
      autowrite = true;
      wildmode = "longest,list";
      wildmenu = true;
      undofile = true;

      foldmethod = "marker";

      splitbelow = true;
      splitright = true;
      textwidth = 120;
      winwidth = 120;
      timeoutlen = 500;
      laststatus = 0;
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    plugins = {
      luasnip.enable = true;
      telescope.enable = true;
      lsp = {
        keymaps = {
          silent = true;
          diagnostic = {
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            "<leader>gd" = "definition";
            "<leader>h" = "hover";
            "<leader>f" = "format";
          };
        };

        enable = true;
        servers = {
          rnix-lsp.enable = true;
          pylsp.enable = true;
          lua-ls.enable = true;
        };
      };
      which-key.enable = true;
      treesitter.enable = true;
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];

        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expandable() then
                  luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif check_backspace() then
                  fallback()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };
    };

    keymaps = [
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<leader>tg";
      }

      {
        action = "<cmd>lua require('telescope.builtin').find_files({search_dirs = {'~/docs/todo/'}})<CR>";
        key = "<leader>et";
      }
    ];
  };
}
