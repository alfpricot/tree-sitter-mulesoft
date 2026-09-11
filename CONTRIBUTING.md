# Contributing

## Build

```sh
CC=gcc CXX=g++ cargo build
```

The generated parser files (`src/parser.c`, `src/grammar.json`, and
`src/node-types.json`) are committed for each grammar. Regenerate and commit their diffs after
changing either `grammar.js`. A failed generation leaves the previous parser in place, so verify
that the command succeeds before trusting a test result.

```sh
cd dataweave && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter generate
cd ../raml && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter generate
```

## Test

```sh
CC=gcc CXX=g++ cargo fmt --check
CC=gcc CXX=g++ cargo clippy --all-targets -- -D warnings
CC=gcc CXX=g++ cargo test
```

Run the corpus suites and refresh each node-kind snapshot after a grammar change:

```sh
cd dataweave && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter test && node test/generate-node-kinds.mjs
cd ../raml && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter test && node test/generate-node-kinds.mjs
```

`dataweave/test/corpus/` and `raml/test/corpus/` contain focused tree assertions. The fixtures
are larger real-shaped samples and must parse without `ERROR` or `MISSING` nodes.

## Pull requests

- Use a Conventional Commit title.
- Regenerate and commit parser artifacts and node-kind snapshots with every grammar change.
- Add a corpus case or fixture coverage for each new construct.
- Keep Rust formatting and clippy clean.
