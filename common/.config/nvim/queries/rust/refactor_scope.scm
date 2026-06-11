; Scopes used for declaration/visibility analysis (extract_var, extract_func,
; print_var) — @scope nodes bound a declaration's reach, @scope.inside marks
; where statements can be inserted.

; whole file is the top-level scope
(source_file) @scope.inside @scope

; any block that is not a function body: if/else/match/loop arms, bare blocks,
; and the inner block of unsafe/async/try/const blocks (the wrapper is the
; parent, so these still match)
((block) @scope.inside @scope
  (#not-has-parent? @scope function_item closure_expression))

; fn foo(a: i32) { ... } — parameters belong to the function scope, so the
; scope is the [parameters, block] pair
(function_item
  parameters: (parameters) @scope
  body: (block) @scope.inside @scope)

; |a| { ... } — like functions, closure parameters join the body scope.
; NOTE: restricted to block bodies on purpose: an expression body (e.g.
; `|x| x + 1`) contains no statements, and treating it as a scope makes
; extract_var crash looking for an insertion point inside it
(closure_expression
  parameters: (closure_parameters) @scope
  body: (block) @scope.inside @scope)
