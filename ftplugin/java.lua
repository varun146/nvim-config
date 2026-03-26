-- ftplugin/java.lua
-- Loaded automatically by Neovim whenever a Java file is opened

-- ── Indentation ──────────────────────────────────────────────────────────────
-- smartindent is reliable and simple — no cindent double-indent issues
-- google-java-format handles all cosmetic formatting on save anyway
vim.bo.tabstop = 4

vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.smartindent = true

-- ── jdtls paths ──────────────────────────────────────────────────────────────

local jdtls = require 'jdtls'
local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

local os_config = 'linux'
if vim.fn.has 'mac' == 1 then
  os_config = 'mac'
end

if vim.fn.has 'win32' == 1 then
  os_config = 'win'
end

-- Unique workspace per project (avoids jdtls state bleed between projects)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

-- ── DAP bundles (debug + test) ────────────────────────────────────────────────
local bundles = {}

local debug_jar = vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true)
if debug_jar ~= '' then
  vim.list_extend(bundles, { debug_jar })
end

local test_jars = vim.split(vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-test/extension/server/*.jar', true), '\n', { trimempty = true })
vim.list_extend(bundles, test_jars)

-- ── jdtls config ─────────────────────────────────────────────────────────────
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx2g', -- 2g is more stable than 1g for large projects
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    launcher,
    '-configuration',
    jdtls_path .. '/config_' .. os_config,
    '-data',
    workspace,
  },

  root_dir = jdtls.setup.find_root { 'pom.xml', 'build.gradle', '.git', 'mvnw', 'gradlew' },

  settings = {
    java = {
      -- ── Compiler ─────────────────────────────────────────────────────────
      configuration = {
        updateBuildConfiguration = 'interactive',
      },
      -- ── Completion ───────────────────────────────────────────────────────
      completion = {
        favoriteStaticMembers = {
          'org.junit.jupiter.api.Assertions.*',
          'org.junit.Assert.*',
          'org.testng.Assert.*',
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',

          'org.mockito.Mockito.*',
          'io.restassured.RestAssured.*',
        },
        filteredTypes = { -- suppresses noisy sun.*/awt.* import suggestions
          'com.sun.*',
          'java.awt.*',
          'jdk.*',
          'sun.*',
        },
        importOrder = { 'java', 'javax', 'org', 'com' },
        guessMethodArguments = true,
      },

      -- ── Imports ──────────────────────────────────────────────────────────
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      -- ── Diagnostics — only show things that matter ────────────────────────

      -- Checkstyle-style warnings (missing Javadoc, indentation) are suppressed
      -- Real errors (type mismatch, undefined method) still show
      errors = {
        incompleteClasspath = { severity = 'warning' },
      },
      -- ── Misc ─────────────────────────────────────────────────────────────
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      inlayHints = {
        parameterNames = { enabled = 'literals' }, -- only for literal args, not variables
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  -- ── on_attach: runs once per buffer when jdtls connects ──────────────────

  vim.api.nvim_create_autocmd('BufWritePost', {

    pattern = 'pom.xml',
    group = vim.api.nvim_create_augroup('MavenAutoResolve', { clear = true }),
    callback = function()
      vim.notify('pom.xml saved — resolving dependencies...', vim.log.levels.INFO)
      vim.fn.jobstart({ 'mvn', 'dependency:resolve', '-q' }, {
        cwd = vim.fn.getcwd(),
        on_exit = function(_, code)
          if code == 0 then
            vim.notify('Dependencies resolved. Reloading jdtls...', vim.log.levels.INFO)
            vim.lsp.buf.execute_command {
              command = 'java.projectConfiguration.update',
              arguments = { vim.uri_from_bufnr(0) },
            }
          else
            vim.notify('mvn dependency:resolve failed', vim.log.levels.ERROR)
          end
        end,
      })
    end,
  }),

  on_attach = function(_, bufnr)
    jdtls.setup_dap { hotcodereplace = 'auto' }
    jdtls.setup.add_commands()

    local opts = function(desc)
      return { buffer = bufnr, desc = desc }
    end

    -- Refactoring

    vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, opts 'Java: Organize Imports')
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, opts 'Java: Extract Variable')
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, opts 'Java: Extract Constant')
    vim.keymap.set('v', '<leader>jm', function()
      jdtls.extract_method(true)
    end, opts 'Java: Extract Method')

    -- Running tests directly via jdtls (alternative to neotest)
    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, opts 'Java: Run Nearest Test')
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, opts 'Java: Run Test Class')
    vim.keymap.set('n', '<leader>jR', function()
      vim.lsp.buf.execute_command {
        command = 'java.projectConfiguration.update',
        arguments = { vim.uri_from_bufnr(0) },
      }
    end, { desc = 'Java: Reload Project / Sync pom.xml' })
    vim.keymap.set('n', '<leader>jd', function()
      vim.notify('Resolving Maven dependencies...', vim.log.levels.INFO)
      vim.fn.jobstart({ 'mvn', 'dependency:resolve', '-q' }, {
        cwd = vim.fn.getcwd(),
        on_exit = function(_, code)
          if code == 0 then
            vim.notify('Dependencies resolved. Reloading project...', vim.log.levels.INFO)
            vim.lsp.buf.execute_command {

              command = 'java.projectConfiguration.update',
              arguments = { vim.uri_from_bufnr(0) },
            }
          else
            vim.notify('mvn dependency:resolve failed (exit ' .. code .. ')', vim.log.levels.ERROR)
          end
        end,
      })
    end, opts 'Java: Resolve Maven Dependencies')
  end,
}

jdtls.start_or_attach(config)
