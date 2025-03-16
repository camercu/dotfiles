return {
  {
    'saghen/blink.cmp',
    opts = {
      keymap = {
        preset = 'super-tab',
      },
      sources = {
        default = { 'emoji' },
        providers = {
          emoji = {
            name = 'emoji',
            module = 'blink.compat.source',
            -- overwrite kind of suggestion
            transform_items = function(ctx, items)
              local kind = require('blink.cmp.types').CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
        },
      },
    },
    dependencies = { 'allaman/emoji.nvim', 'saghen/blink.compat' },
  },
}
