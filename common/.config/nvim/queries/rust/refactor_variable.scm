; let foo = "foo";
(let_declaration
    pattern: (identifier) @variable.identifier
    value: (_) @variable.value) @variable.declaration


; let (foo, bar) = ("foo", "bar");
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


; No idea how to hanlde these:
; for i in (1..10) { /* do stuff */ }
; for (i, j) in (1..10).zip(1..10) { /* do stuff */ }
