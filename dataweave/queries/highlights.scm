; DataWeave Highlights

; Comments
(line_comment) @comment
(block_comment) @comment

; Directives
[
  "%dw"
  "dw"
  "%output"
  "output"
  "%input"
  "input"
  "%var"
  "var"
  "%fun"
  "%function"
  "fun"
  "%type"
  "type"
  "%ns"
  "%namespace"
  "ns"
  "namespace"
  "%import"
  "import"
] @keyword.directive

; Keywords
[
  "if"
  "else"
  "match"
  "case"
  "matches"
  "do"
  "default"
  "as"
  "is"
  "and"
  "or"
  "not"
  "to"
  "from"
] @keyword

; Constants & Literals
(boolean) @boolean
(null) @constant.builtin
(number) @number
(date_time) @string.special
(regex) @string.regex

; Strings
(string) @string
(escape_sequence) @string.escape
(interpolation ["$(" ")"] @punctuation.special)

; Types
(type_name) @type.builtin
(type_directive name: (identifier) @type)
(namespace_uri) @string.special
(qualified_name namespace: (identifier) @module)
(qualified_name name: (identifier) @property)

; Functions & Calls
(fun_directive name: (identifier) @function)
(call_expression function: (identifier) @function.call)
(call_expression function: (module_path (identifier) @function.call))

; Properties & Keys
(pair key: (identifier) @property)
(member_expression property: (identifier) @property)
(descendant_expression property: (identifier) @property)
(multi_value_expression property: (identifier) @property)

; Parameters & Variables
(parameter name: (identifier) @variable.parameter)
(anonymous_parameter) @variable.builtin
(var_directive name: (identifier) @variable)

; Operators
[
  "+"
  "-"
  "*"
  "/"
  "++"
  "--"
  "<<"
  ">>"
  "#"
  "=="
  "!="
  "~="
  "<"
  "<="
  ">"
  ">="
  "->"
  "?:"
  "::"
  "---"
] @operator

; Punctuation
[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  ":"
  "."
] @punctuation.delimiter
