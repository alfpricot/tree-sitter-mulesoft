# tree-sitter-raml

Tree-sitter grammar for RESTful API Modeling Language (RAML, `.raml`).

## Scope

This is a YAML 1.2 grammar for files in RAML's YAML syntax. It has no RAML-specific rules, so RAML constructs parse as ordinary YAML:

- The `#%RAML 1.0` header is a comment.
- Resource paths (`/resource/{id}`), HTTP methods, `types`, `traits`, `resourceTypes`, and `securitySchemes` are block mappings.
- `!include` is a generic tag.

Tools that need RAML meaning, such as recognizing a resource or a method, interpret the mapping keys on top of the syntax tree.

## License

MIT
