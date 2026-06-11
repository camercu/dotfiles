; Identifier references with read/write + declaration metadata. Used by
; inline_var (definition/use matching), extract_func (args/returns analysis),
; print_var, and the treesitter LSP-fallback in extend-refactor.lua.
; Node kinds reviewed against tree-sitter-rust grammar.js (_expression,
; _pattern, _declaration_statement choices).

; ============================================================
; declarations: typed binding positions (type recorded for codegen)
; ============================================================

; fn foo(bar: i32) {}
(parameter
  pattern: (identifier) @reference.identifier
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; fn foo(mut bar: i32) {}
(parameter
  pattern: (mut_pattern
    (identifier) @reference.identifier)
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; let foo: &str = "foo";
(let_declaration
  pattern: (identifier) @reference.identifier
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; let mut foo: i32 = 1;
(let_declaration
  pattern: (mut_pattern
    (identifier) @reference.identifier)
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; let foo = "foo"; — type inferred from literal values
(let_declaration
  pattern: (identifier) @reference.identifier
  !type
  value: (_) @_value
  (#infer-type-rust! @_value)
  (#set! reference_type write)
  (#set! declaration))

; let mut foo = 1; — type inferred from literal values
(let_declaration
  pattern: (mut_pattern
    (identifier) @reference.identifier)
  !type
  value: (_) @_value
  (#infer-type-rust! @_value)
  (#set! reference_type write)
  (#set! declaration))

; const MAX: i32 = 10;
(const_item
  name: (identifier) @reference.identifier
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; static GLOBAL: i32 = 10;
(static_item
  name: (identifier) @reference.identifier
  type: (_) @_type
  (#set-type-rust! @_type @reference.identifier)
  (#set! reference_type write)
  (#set! declaration))

; ============================================================
; declarations: other binding positions (no type info available).
; In rust, identifiers inside patterns always bind, so these rules are safe
; without further context.
; ============================================================

; let (foo, bar) = ...; / for (i, j) in ... / fn f((a, b): (i32, i32))
(tuple_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; Some(x) => ... / let Ok(v) = ... else / if let Some(x) = ...
(tuple_struct_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; Point { x, y } => ... — shorthand struct field binding
(field_pattern
  name: (shorthand_field_identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; Point { x: a } => ... — renamed struct field binding
(field_pattern
  pattern: (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; [first, rest] => ...
(slice_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; let ref foo = ...;
(ref_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; &foo / &mut foo in patterns
(reference_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; mut foo in nested pattern positions (let mut is handled above with types)
(mut_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; A | B => ... with bindings: Some(x) | None
(or_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; whole @ pattern — `n @ 1..=5 => ...`
(captured_pattern
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; |x| ... — closure parameters
(closure_parameters
  (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; if let foo = ... / while let foo = ...
(let_condition
  pattern: (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; for i in 0..10 {}
(for_expression
  pattern: (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; fn foo() {} — the function name itself is a declaration
(function_item
  name: (identifier) @reference.identifier
  (#set! reference_type write)
  (#set! declaration))

; ============================================================
; writes
; ============================================================

; foo = 1;
(assignment_expression
  left: (identifier) @reference.identifier
  (#set! reference_type write))

; foo.bar = 1; / foo[0] = 1;
(assignment_expression
  left: [
    (field_expression)
    (index_expression)
  ] @reference.identifier
  (#set! reference_type write)
  (#set! field))

; foo += 1;
(compound_assignment_expr
  left: (identifier) @reference.identifier
  (#set! reference_type write))

; foo.bar += 1; / foo[0] += 1;
(compound_assignment_expr
  left: [
    (field_expression)
    (index_expression)
  ] @reference.identifier
  (#set! reference_type write)
  (#set! field))

; ============================================================
; reads
; ============================================================

; let a = b;
(let_declaration
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; a = b;
(assignment_expression
  right: (identifier) @reference.identifier
  (#set! reference_type read))

; a += b;
(compound_assignment_expr
  right: (identifier) @reference.identifier
  (#set! reference_type read))

; a + b
(binary_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; a.b + c / a[0] + c
(binary_expression
  [
    (field_expression)
    (index_expression)
  ] @reference.identifier
  (#set! reference_type read)
  (#set! field))

; -a / !a
(unary_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; &a / &mut a
(reference_expression
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; (a)
(parenthesized_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; foo(a, b) — call arguments
(arguments
  (identifier) @reference.identifier
  (#set! reference_type read))

; foo(a.b, c[0]) — field/index call arguments
(arguments
  [
    (field_expression)
    (index_expression)
  ] @reference.identifier
  (#set! reference_type read)
  (#set! field))

; foo.bar — the base of a field access
(field_expression
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; foo[bar] — both base and index
(index_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; return a;
(return_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; a? — try operator
(try_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; a as i64
(type_cast_expression
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; a.await
(await_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; yield a;
(yield_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; if a { ... }
(if_expression
  condition: (identifier) @reference.identifier
  (#set! reference_type read))

; while a { ... }
(while_expression
  condition: (identifier) @reference.identifier
  (#set! reference_type read))

; if let P = a { ... } / while let P = a { ... }
(let_condition
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; match a { ... }
(match_expression
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; _ => a — match arm result value
(match_arm
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; for x in a { ... }
(for_expression
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; a..b
(range_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; (a, b)
(tuple_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; [a, b]
(array_expression
  (identifier) @reference.identifier
  (#set! reference_type read))

; || a — expression-body closure
(closure_expression
  body: (identifier) @reference.identifier
  (#set! reference_type read))

; println!("{}", a) — macro arguments are raw tokens; every identifier token
; inside is treated as a read
(token_tree
  (identifier) @reference.identifier
  (#set! reference_type read))

; Foo { bar: a }
(field_initializer
  value: (identifier) @reference.identifier
  (#set! reference_type read))

; Foo { bar }
(shorthand_field_initializer
  (identifier) @reference.identifier
  (#set! reference_type read))

; ============================================================
; function calls
; ============================================================

; foo(...)
(call_expression
  function: (identifier) @reference.identifier
  (#set! reference_type read)
  (#set! function_call_identifier))

; foo.bar(...) / foo::<T>(...) is left to LSP
(call_expression
  function: (field_expression) @reference.identifier
  (#set! reference_type read)
  (#set! field)
  (#set! function_call_identifier))
