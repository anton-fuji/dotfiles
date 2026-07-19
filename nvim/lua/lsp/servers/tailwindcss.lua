local function has_tailwind_dependency(package_json)
  local ok, lines = pcall(vim.fn.readfile, package_json)
  if not ok then
    return false
  end

  local parsed_ok, package = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not parsed_ok or type(package) ~= "table" then
    return false
  end

  for _, key in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
    if type(package[key]) == "table" and package[key].tailwindcss ~= nil then
      return true
    end
  end

  return false
end

vim.lsp.config['tailwindcss'] = {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'html',
    'javascript',
    'javascriptreact',
    'less',
    'markdown',
    'mdx',
    'postcss',
    'sass',
    'scss',
    'svelte',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_dir = function(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local root_files = {
      'tailwind.config.js',
      'tailwind.config.cjs',
      'tailwind.config.mjs',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.cjs',
      'postcss.config.mjs',
      'postcss.config.ts',
      'package.json',
    }

    for _, match in ipairs(vim.fs.find(root_files, { path = filename, upward = true })) do
      if vim.fs.basename(match) ~= 'package.json' or has_tailwind_dependency(match) then
        on_dir(vim.fs.dirname(match))
        return
      end
    end
  end,
  settings = {
    tailwindCSS = {
      validate = true,
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidScreen = 'error',
        invalidVariant = 'error',
        invalidConfigPath = 'error',
        invalidTailwindDirective = 'error',
        recommendedVariantOrder = 'warning',
      },
      classAttributes = {
        'class',
        'className',
        'class:list',
        'classList',
        'ngClass',
      },
    },
  },
}
