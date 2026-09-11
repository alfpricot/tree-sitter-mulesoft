# tree-sitter-mulesoft

Tree-sitter grammars for MuleSoft integration file formats:
- **DataWeave** (`.dwl`) — Transformation and mapping language (`tree-sitter-dataweave`).
- **RAML** (`.raml`) — RESTful API Modeling Language specification format (`tree-sitter-raml`).

## Architecture

This repository holds two independent tree-sitter grammars:

| Grammar | Subdirectory | C Symbol | NPM Package | Rust Crate |
|---|---|---|---|---|
| DataWeave | `dataweave/` | `tree_sitter_dataweave` | `tree-sitter-dataweave` | `tree-sitter-dataweave` |
| RAML | `raml/` | `tree_sitter_raml` | `tree-sitter-raml` | `tree-sitter-raml` |

## Usage

### Rust

Add the respective grammar crate to your `Cargo.toml`:

```toml
[dependencies]
tree-sitter-dataweave = "0.1"
tree-sitter-raml = "0.1"
```

```rust
use tree_sitter::Parser;

let mut parser = Parser::new();
parser.set_language(&tree_sitter_dataweave::LANGUAGE.into())?;
let tree = parser.parse("%dw 2.0\noutput application/json\n---\n{ key: 'value' }", None)?;
```

### Node.js

Install the packages:

```bash
npm install tree-sitter-dataweave tree-sitter-raml
```

```javascript
import Parser from "tree-sitter";
import DataWeave from "tree-sitter-dataweave";

const parser = new Parser();
parser.setLanguage(DataWeave);
```

## License

MIT (see [LICENSE](LICENSE) and [NOTICE](NOTICE)).
