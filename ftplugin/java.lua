local jdtls = require 'jdtls'
local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
local equinox_launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

-- OS-specific configuration path
local os_config = 'linux'
if vim.fn.has 'mac' == 1 then
  os_config = 'mac'
elseif vim.fn.has 'win32' == 1 then
  os_config = 'win'
end

local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- Bundles for java-debug-adapter and java-test (enables DAP + test running)
local bundles = {}
local java_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter'
local java_debug_bundle = vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true)
if java_debug_bundle ~= '' then
  vim.list_extend(bundles, { java_debug_bundle })
end

local java_test_path = vim.fn.stdpath 'data' .. '/mason/packages/java-test'
local java_test_bundles = vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar', true), '\n', { trimempty = true })
vim.list_extend(bundles, java_test_bundles)

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    equinox_launcher,
    '-configuration',
    jdtls_path .. '/config_' .. os_config,
    '-data',
    workspace_dir,
  },

  root_dir = jdtls.setup.find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          'org.junit.Assert.*',
          'org.junit.jupiter.api.Assertions.*',
          'org.testng.Assert.*',
          'io.restassured.RestAssured.*',
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(_, bufnr)
    -- Enable java-debug and java-test
    jdtls.setup_dap { hotcodereplace = 'auto' }
    jdtls.setup.add_commands()

    -- Keymaps specific to Java
    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Java: Organize Imports' }))
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Java: Extract Variable' }))
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, vim.tbl_extend('force', opts, { desc = 'Java: Extract Constant' }))
    vim.keymap.set('v', '<leader>jm', function()
      jdtls.extract_method(true)
    end, vim.tbl_extend('force', opts, { desc = 'Java: Extract Method' }))
    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, vim.tbl_extend('force', opts, { desc = 'Java: Run Nearest Test' }))
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, vim.tbl_extend('force', opts, { desc = 'Java: Run Test Class' }))
  end,
}

jdtls.start_or_attach(config)
