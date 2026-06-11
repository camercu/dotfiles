; fn foo(a: i32, mut b: i32) { ... } — function definition for inline_func.
; Captures the name-bearing parameter identifiers (plain or `mut`) and every
; statement of the body.
; NOTE: sequence-with-anchor style (not bare quantifiers) is required so all
; args/body nodes land in a single query match
((line_comment)* @function.comment
  .
  (function_item
    parameters: (parameters
      .
      (parameter
        pattern: [
          (identifier) @function.arg
          (mut_pattern
            (identifier) @function.arg)
        ])
      .
      (","
        (parameter
          pattern: [
            (identifier) @function.arg
            (mut_pattern
              (identifier) @function.arg)
          ]))*)?
    body: (block
      .
      (_) @function.body
      ((_) @function.body)*)) @function)

; return x; — explicit return (value optional: bare `return;`)
(return_expression
  (_)? @return.value) @return

; tail expression as implicit return (value-producing kinds only — block-like
; expressions in tail position are ambiguous with statements)
(block
  [
    (identifier)
    (integer_literal)
    (float_literal)
    (string_literal)
    (raw_string_literal)
    (boolean_literal)
    (char_literal)
    (binary_expression)
    (unary_expression)
    (call_expression)
    (field_expression)
    (index_expression)
    (parenthesized_expression)
    (tuple_expression)
    (array_expression)
    (struct_expression)
    (reference_expression)
    (range_expression)
    (await_expression)
    (macro_invocation)
  ] @return @return.value .)
