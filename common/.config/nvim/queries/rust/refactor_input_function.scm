; free function at top level
(source_file
  (function_item) @input_function)

; function inside a mod block (e.g. #[cfg(test)] mod tests)
(mod_item
  body: (declaration_list
    (function_item) @input_function))

; method (takes self) inside an impl block
(impl_item
  type: (_) @_struct_name
  body: (declaration_list
    (function_item
      parameters: (parameters
        (self_parameter))) @input_function)
  (#set! method)
  (#set! struct_name @_struct_name))
