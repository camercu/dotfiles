; Path segments for debug prints: each construct enclosing the print location
; contributes its text, joined with `#` — e.g. a print inside an if inside
; fn main() gets the path `main#if`.

; if cond { <print here> }
((if_expression
  (#set! text if)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((else_clause
  (#set! text else)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((for_expression
  (#set! text for)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((while_expression
  (#set! text while)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((loop_expression
  (#set! text loop)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((match_expression
  (#set! text match)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

((closure_expression
  (#set! text closure)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))

; fn foo() { <print here> } — contributes the function's name
((function_item
  name: (_) @_name
  (#set! text @_name)) @debug_path_segment
  (#offset! @debug_path_segment 0 -1 0 1))
