return {
  "ThePrimeagen/refactoring.nvim",
  opts = {
    refactor = {
      extract_var = {
        code_generation = {
          variable_declaration = {
            rust = function(opts)
              return ("let %s = %s;"):format(opts.name, opts.value)
            end,
          },
        },
      },
    },
  },
}
