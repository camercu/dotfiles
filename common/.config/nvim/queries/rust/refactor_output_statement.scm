; _statement:
[
    (expression_statement)

    ; _declaration_statement:
    (const_item)
    (macro_invocation)
    (macro_definition)
    (empty_statement)
    (attribute_item)
    (inner_attribute_item)
    (mod_item)
    (foreign_mod_item)
    (struct_item)
    (union_item)
    (enum_item)
    (type_item)
    (function_item)
    (function_signature_item)
    (impl_item)
    (trait_item)
    (associated_type)
    (let_declaration)
    (use_declaration)
    (extern_crate_declaration)
    (static_item)
] @output_statement
