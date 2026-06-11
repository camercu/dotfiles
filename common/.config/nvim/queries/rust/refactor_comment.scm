; Comment nodes — used by the debug print cleanup to find the
; __PRINT_*_START/__PRINT_*_END marker comments. Rust has no generic
; (comment) node, only these two kinds.
[
  (line_comment)
  (block_comment)
] @comment
