# tree-sitter-dataweave

Tree-sitter grammar for MuleSoft DataWeave (`.dwl`).

## Features

- Full support for DataWeave headers and directives (`%dw`, `%output`, `%input`, `%var`, `%fun`, `%type`, `%ns`, `%import`).
- Object literals with dynamic keys `(key): value`, conditional pairs `(key: value) if (cond)`, and spread `{(...)}`.
- Field and range selectors (`.`, `..`, `..*`, `.*`, `.@`, `.^`, `.#`, `.&`, `.?`, `[0 to 2]`, `[?(...)]`).
- Operators (`++`, `--`, `~=`, `default`, `as`, `is`, `and`, `or`, `not`).
- Control expressions (`if/else`, `unless/else`, `match/case` with value, type, array (`[head ~ tail]`) and object patterns, `do`).
- Lambda literals `(x) -> expr`, anonymous parameters (`$`, `$$`), and infix calls.
- Structural types (`%type`, object types, union/intersection types), type annotations on `var`, and type parameters on `fun` and `type` (`fun id<T>(x: T): T`).

## License

MIT
