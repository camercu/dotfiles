return {
  'echasnovski/mini.files',
  opts = {
    options = {
      use_as_default_explorer = true,
      permanent_delete = false,
    },
  },
  lazy = false, -- must eager load for it to replace netrw
}
