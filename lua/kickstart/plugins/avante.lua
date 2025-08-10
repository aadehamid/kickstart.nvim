-- AI-powered coding assistant plugin
-- Provides intelligent code suggestions and assistance using various LLM providers

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- The provider used for AI assistance
      provider = "claude", -- can be "claude", "openai", "azure", "gemini", "cohere", "copilot"
      
      -- The default mode for interaction
      -- "agentic" uses tools to automatically generate code
      -- "legacy" uses the old planning method
      mode = "agentic",
      
      -- Provider for auto-suggestions (be careful with high-frequency operations)
      auto_suggestions_provider = "claude",
      
      -- Provider configurations
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          extra = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o",
          extra = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        azure = {
          endpoint = "https://api.cognitive.microsoft.com",
          deployment = "gpt-4o",
          api_version = "2024-06-01",
          extra = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "gpt-4o-2024-05-13",
          proxy = nil,
          allow_insecure = false,
          timeout = 30000,
        },
      },
      
      -- Behavior settings
      behaviour = {
        auto_suggestions = true, -- Enable auto-suggestions
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
      
      -- Mappings (key bindings)
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>", -- Alt+l to accept suggestion
          next = "<M-]>",   -- Alt+] for next suggestion
          prev = "<M-[>",   -- Alt+[ for previous suggestion
          dismiss = "<C-]>", -- Ctrl+] to dismiss
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
      
      -- Hints configuration
      hints = {
        enabled = true,
      },
      
      -- Windows configuration
      windows = {
        position = "right", -- can be "right", "left", "top", "bottom"
        wrap = true,
        width = 30, -- % based on available width
        sidebar_header = {
          align = "center", -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = "> ",
          height = 8, -- Height of the input window in lines
        },
        edit = {
          border = "rounded",
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window
          border = "rounded",
          ---@type "ours" | "theirs"
          focus_on_apply = "ours", -- which diff to focus after applying
        },
      },
      
      -- Highlights
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      
      -- Suggestion settings
      suggestion = {
        enabled = true,
        auto_trigger = false,
        debounce = 400, -- debounce time in milliseconds
      },
      
      -- File exclusions
      file_selector = {
        provider = "native", -- native, fzf, telescope
        provider_opts = {},
      },
    },
    
    -- Build function for installation
    build = function()
      require("avante.repo_map").setup()
    end,
    
    -- Dependencies
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and system prompts
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    
    -- Key mappings
    keys = {
      {
        "<leader>aa",
        function()
          require("avante.api").ask()
        end,
        desc = "avante: ask",
        mode = { "n", "v" },
      },
      {
        "<leader>ar",
        function()
          require("avante.api").refresh()
        end,
        desc = "avante: refresh",
        mode = "v",
      },
      {
        "<leader>ae",
        function()
          require("avante.api").edit()
        end,
        desc = "avante: edit",
        mode = "v",
      },
    },
  },
}
