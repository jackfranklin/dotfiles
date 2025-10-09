vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  update_in_insert = false,
  float = {
    border = "rounded",
  },
})
vim.o.winborder = "single"

-- Disable formatexpr to allow Vim's built in gq to work.
-- See: https://github.com/neovim/neovim/pull/19677 &&
-- https://vi.stackexchange.com/questions/39200/wrapping-comment-in-visual-mode-not-working-with-gq
-- In theory this idea works great but the TS language server doesn't wrap comments.
-- vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].formatexpr = nil
  end,
})

-- vim.lsp.handlers["$/typescriptVersion"] = function(_, result)
--   vim.notify("TypeScript loaded: " .. vim.inspect(result))
-- end

local M = {}
M.typescript = function(config)
  local setup_opts = {}
  if config.cmd ~= nil then
    setup_opts.cmd = config.cmd
  end
  if config.custom_tsserver_path ~= nil then
    setup_opts.init_opts = {
      tsserver = config.custom_tsserver_path,
    }
  end

  vim.lsp.config("ts_ls", setup_opts)
  vim.lsp.enable("ts_ls")
end

M.css = function()
  -- We do have snippet support
  local css_capabilities = vim.lsp.protocol.make_client_capabilities()
  css_capabilities.textDocument.completion.completionItem.snippetSupport = true
  vim.lsp.config("cssls", {
    capabilities = css_capabilities,
  })
  vim.lsp.enable("cssls")
end

M.eslint = function(config)
  local eslint_setup = {
    settings = {
      run = "onSave",
    },
    -- TODO: do these actually work?
    -- Or they might work but only once I swap to the Neovim 0.11 setup
    -- https://neovim.io/doc/user/lsp.html#lsp-client
    flags = {
      debounce_text_changes = 250,
      allow_incremental_sync = false,
    },
    -- root_dir = function(name)
    --   return util.root_pattern("package.json")(name)
    -- end,
  }

  local final_setup = vim.tbl_deep_extend("force", eslint_setup, config or {})
  vim.lsp.config("eslint", final_setup)
  vim.lsp.enable("eslint")
end

M.lua = function()
  vim.lsp.config("lua_ls", {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            -- Depending on the usage, you might want to add additional paths
            -- here.
            -- '${3rd}/luv/library'
            -- '${3rd}/busted/library'
          },
        },
      })
    end,
    settings = {
      Lua = {},
    },
  })
  vim.lsp.enable("lua_ls")
end

return M
