; top-level functions (with any doc comments) anchor where extracted
; functions are inserted
(source_file
  _*
  [
    (line_comment)
    (block_comment)
  ]* @output_function.comment
  .
  (function_item) @output_function)

; methods inside impl blocks
(declaration_list
  [
    (line_comment)
    (block_comment)
  ]* @output_function.comment
  .
  (function_item
    parameters: (parameters
      (self_parameter))) @output_function)

; functions inside mod blocks (e.g. #[cfg(test)] mod tests)
(mod_item
  body: (declaration_list
    [
      (line_comment)
      (block_comment)
    ]* @output_function.comment
    .
    (function_item) @output_function))
