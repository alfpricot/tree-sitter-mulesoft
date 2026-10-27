# Security policy

## Reporting a vulnerability

Found a parser crash or hang on some input? Open a normal GitHub issue and include the input (or a minimized version) and the binding you used (Rust, Node, or the C API).

If the input could cause trouble for a downstream consumer before a fix ships, do not post it publicly. Open an issue that says you have a security-sensitive report and leaves out the input, tagging the maintainer, `@alfpricot`, who will arrange a private way to receive it.

## Scope

This policy covers the `tree-sitter-dataweave` and `tree-sitter-raml` grammars in this repository: the generated C parsers, the RAML external scanner, and the Rust and Node.js bindings. It does not cover the tree-sitter runtime or the tools that embed these grammars.

## Practices

- No credentials in the repository: pull request checks scan the working tree for secrets, and publishing tokens live only in the repository's Actions secrets.
- Parser files are generated from `grammar.js` and checked in CI, so a committed parser always matches its grammar source.
- Dependabot proposes dependency updates (`.github/dependabot.yml`).
