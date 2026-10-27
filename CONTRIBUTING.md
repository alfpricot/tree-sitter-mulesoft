# Contributing to tree-sitter-mulesoft

Two tree-sitter grammars, DataWeave and RAML, with Rust and Node.js bindings.

## Before you start

1. Branch from **`dev`**. `main` is the production branch and only receives release pull requests.
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) for how the two grammars and the release automation fit together.
3. There is no local configuration file to create; the repository reads no environment variables or secrets.

## Local setup

You need Rust 1.85 or later, a C compiler (`gcc` or `clang`), and Node.js 24. From the repository root, install the dev dependencies and the tree-sitter CLI version CI uses, without changing `package.json`:

```bash
npm install --no-save tree-sitter-cli@0.27.0
```

Each package's `install` script (`node-gyp-build`) uses a prebuilt native addon when one exists and otherwise compiles the addon with `node-gyp`, which needs a C++ toolchain; an install on a machine without one fails at that step.

The generated parser files (`src/parser.c`, `src/grammar.json`, and `src/node-types.json`) are committed for each grammar. Regenerate and commit their diffs after changing either `grammar.js`. A failed generation leaves the previous parser in place, so verify that the command succeeds before trusting a test result.

```bash
cd dataweave && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter generate
cd ../raml && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter generate
```

## Validation before a pull request

`Verify` (`.github/workflows/verify.yml`) runs these checks on every pull request.

Rust formatting, lints, and tests:

```bash
CC=gcc CXX=g++ cargo fmt --check
CC=gcc CXX=g++ cargo clippy --all-targets -- -D warnings
CC=gcc CXX=g++ cargo test
```

Corpus suites, plus a refresh of each node-kind snapshot after a grammar change:

```bash
cd dataweave && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter test && node test/generate-node-kinds.mjs
cd ../raml && npx --yes --package=tree-sitter-cli@0.27.0 -- tree-sitter test && node test/generate-node-kinds.mjs
```

`dataweave/test/corpus/` and `raml/test/corpus/` contain focused tree assertions. The fixtures in each `test/fixtures/` are larger real-shaped samples and must parse without `ERROR` or `MISSING` nodes.

JavaScript lint and format (each package's `grammar.js`, `test/*.mjs`, and `bindings/node/*.js`). ESLint and Prettier are installed once at the repository root, and the Prettier settings live under the `prettier` key of the root `package.json`. The root scripts run the matching script in each package, and each package also has its own `lint`, `format`, and `format:check` scripts that can be run from inside `dataweave/` or `raml/`. Each package carries its own copy of `eslint.config.js` so a package lints the same way standalone as it does from the root.

```bash
npm run lint
npm run format:check
npm run format
```

CI also builds and tests the Node.js bindings on Linux and Windows, which a local run on another platform does not cover.

## Pull requests

- Open pull requests against **`dev`**.
- Use a Conventional Commit title (`feat:`, `fix:`, `docs:`, `chore:`, `test:`, ...).
- Regenerate and commit parser artifacts and node-kind snapshots with every grammar change.
- Add a corpus case or fixture coverage for each new construct.
- Keep Rust formatting and clippy clean.
- Link the issue the pull request resolves in its description.

## Documentation

| Document | Covers |
| --- | --- |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Components, build and release automation, and where things live |
| [docs/RELEASING.md](docs/RELEASING.md) | How a release is cut and published |
| [SECURITY.md](SECURITY.md) | Reporting a vulnerability |
