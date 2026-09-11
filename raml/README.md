# tree-sitter-raml

Tree-sitter grammar for RESTful API Modeling Language (RAML, `.raml`).

## Features

- Support for RAML 1.0 and 0.8 specifications.
- Root properties (`title`, `version`, `baseUri`, `protocols`, `mediaType`, `documentation`).
- Resource path trees (`/resource/{id}`), URI parameters, and nested resources.
- HTTP method blocks (`get`, `post`, `put`, `delete`, `patch`) with headers, query parameters, bodies, and responses.
- RAML custom tags (`!include`).
- Types, schemas, resourceTypes, traits, and securitySchemes.

## License

MIT
