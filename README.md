# tree-sitter-mulesoft

[![Verify](https://github.com/alfpricot/tree-sitter-mulesoft/actions/workflows/verify.yml/badge.svg?branch=dev)](https://github.com/alfpricot/tree-sitter-mulesoft/actions/workflows/verify.yml)
[![crates.io: tree-sitter-dataweave](https://img.shields.io/crates/v/tree-sitter-dataweave?label=tree-sitter-dataweave)](https://crates.io/crates/tree-sitter-dataweave)
[![crates.io: tree-sitter-raml](https://img.shields.io/crates/v/tree-sitter-raml?label=tree-sitter-raml)](https://crates.io/crates/tree-sitter-raml)

Two [tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammars for MuleSoft file formats, kept in one repository and released together: DataWeave (`.dwl`), the transformation and mapping language, and RAML (`.raml`), the RESTful API Modeling Language. Each grammar ships as a Rust crate and a Node.js package with the generated C parser, so an editor, linter, or code-analysis tool can parse these files without MuleSoft's own tooling.

| Grammar | Directory | C symbol | npm package | Rust crate |
| --- | --- | --- | --- | --- |
| DataWeave | [`dataweave/`](dataweave/) | `tree_sitter_dataweave` | `tree-sitter-dataweave` | `tree-sitter-dataweave` |
| RAML | [`raml/`](raml/) | `tree_sitter_raml` | `tree-sitter-raml` | `tree-sitter-raml` |

## Installation

Rust:

```bash
cargo add tree-sitter-dataweave tree-sitter-raml
```

Node.js:

```bash
npm install tree-sitter-dataweave tree-sitter-raml
```

### Requirements

- Rust 1.85 or later (the `rust-version` in each crate's `Cargo.toml`).
- Node.js with the `tree-sitter` package version 0.25 or later, which each npm package lists as an optional peer dependency.
- The npm packages ship prebuilt native addons for Linux and Windows. On another platform, installation compiles the addon from source with `node-gyp`, which needs a C toolchain.

## Usage

Rust:

```rust
use tree_sitter::Parser;

let mut parser = Parser::new();
parser.set_language(&tree_sitter_dataweave::LANGUAGE.into())?;
let tree = parser.parse("%dw 2.0\noutput application/json\n---\n{ key: 'value' }", None)?;
```

Node.js:

```javascript
import Parser from "tree-sitter";
import DataWeave from "tree-sitter-dataweave";

const parser = new Parser();
parser.setLanguage(DataWeave);
```

The RAML grammar loads the same way from `tree-sitter-raml` and `tree_sitter_raml`. Each directory's own README lists the syntax that grammar covers.

## How to contribute

Branch from `dev`, regenerate and commit the parser files after any `grammar.js` change, and run the Rust, corpus, and lint checks before opening a pull request against `dev`. [CONTRIBUTING.md](CONTRIBUTING.md) has the commands, [ARCHITECTURE.md](ARCHITECTURE.md) explains how the repository is laid out, and [docs/RELEASING.md](docs/RELEASING.md) covers how a release is published.

## License

MIT (see [LICENSE](LICENSE) and [NOTICE](NOTICE)).
