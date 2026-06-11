; foo(a, b); — call as a whole statement; capture the expression_statement as
; @function_call.outside so the trailing `;` is replaced along with the call
(expression_statement
  (call_expression
    function: (identifier) @function_call.name
    arguments: (arguments
      .
      (_) @function_call.arg
      .
      ("," (_) @function_call.arg)*)?) @function_call) @function_call.outside

; foo(a, b) — embedded in a larger expression (e.g. `foo(a) + 1`); not bound
; by a let and not a whole statement (those have their own patterns above)
((call_expression
  function: (identifier) @function_call.name
  arguments: (arguments
    .
    (_) @function_call.arg
    .
    ("," (_) @function_call.arg)*)?) @function_call
  (#not-has-parent? @function_call let_declaration expression_statement))

; let x = foo(a, b);
(let_declaration
  pattern: (identifier) @function_call.return_value
  value: (call_expression
    function: (identifier) @function_call.name
    arguments: (arguments
      .
      (_) @function_call.arg
      .
      ("," (_) @function_call.arg)*)?) @function_call) @function_call.outside

; let (x, y) = foo(a, b);
(let_declaration
  pattern: (tuple_pattern
    .
    (identifier) @function_call.return_value
    .
    ("," (identifier) @function_call.return_value)*)
  value: (call_expression
    function: (identifier) @function_call.name
    arguments: (arguments
      .
      (_) @function_call.arg
      .
      ("," (_) @function_call.arg)*)?) @function_call) @function_call.outside
