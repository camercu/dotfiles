; Variable declarations consumed by inline_var: maps each bound identifier to
; its value so the definition can be deleted and the value substituted at the
; use sites. Separator captures let inline_var remove a single element from a
; tuple binding.

; let foo = "foo"; / let mut foo = 1;
(let_declaration
  pattern: [
    (identifier) @variable.identifier
    (mut_pattern
      (identifier) @variable.identifier)
  ]
  value: (_) @variable.value) @variable.declaration

; let (foo, bar) = ("foo", "bar"); — element-wise pairing of identifiers and
; values, with the separating commas captured for partial removal
(let_declaration
  pattern: (tuple_pattern
    .
    (identifier) @variable.identifier
    .
    ("," @variable.identifier_separator
      (identifier) @variable.identifier)*)
  value: (tuple_expression
    .
    (_) @variable.value
    .
    ("," @variable.value_separator
      (_) @variable.value)*)) @variable.declaration
