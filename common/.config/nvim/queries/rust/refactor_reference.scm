; let foo = "foo";
(let_declaration
    pattern: (identifier) @reference.identifier
    value: (_) @_type
    (#set! declaration)
    (#set! reference_type write))

; let foo: &str = "foo";
(let_declaration
    pattern: (identifier) @reference.identifier
    type: (_) @_type
    (#set! declaration)
    (#set! reference_type write)
    (#set-type! rust @_type @reference.identifier))

; ; let (foo, bar) = ("foo", "bar");
; (let_declaration
;     pattern: (tuple_pattern
;         (identifier) @reference.identifier


; TODO:
; for i in (1..10) { /* do stuff */ }
