# tree-sitter-mulesoft architecture

This repository holds two tree-sitter grammars for MuleSoft file formats, DataWeave (`.dwl`) and RAML (`.raml`). Each grammar is a self-contained package with its own `grammar.js`, generated C parser, highlight queries, tests, and Rust and Node.js bindings. The root ties them together as a Cargo workspace and an npm workspace, and releases them as one unit under a single version.

The design choice that shapes the rest is that the generated parser files are committed. Consumers install a crate or package that already contains `src/parser.c`, so nobody needs the tree-sitter CLI to use a grammar, and continuous integration fails when a committed parser differs from what `tree-sitter generate` produces from the current `grammar.js`.

## What tree-sitter-mulesoft is not

- It is not a MuleSoft runtime, validator, or linter. It produces syntax trees only; interpreting them is left to the consuming tool.
- It is not a single combined grammar. DataWeave and RAML do not share rules and can change independently, although they are versioned and released together.
- The workspace root is not a published package. Only the two child packages go to a registry.

## Major components

### [dataweave](dataweave/)

The DataWeave grammar, written from scratch in JavaScript (`grammar.js`) with no external scanner. It owns the generated parser in `src/`, highlight queries in `queries/`, corpus tests and sample `.dwl` fixtures in `test/`, and the Rust crate and Node.js addon under `bindings/`. It publishes as the `tree-sitter-dataweave` crate and npm package.

### [raml](raml/)

The RAML grammar, built on YAML syntax. In addition to the generated parser it carries a hand-maintained C external scanner (`src/scanner.c`) and the YAML schema files (`src/schema.core.c`, `src/schema.json.c`, `src/schema.legacy.c`); the scanner is adapted from the `tree-sitter-yaml` scanner, as [NOTICE](NOTICE) records. `test/scanner_test.c` exercises the scanner directly. Its layout otherwise mirrors `dataweave/`, and it publishes as the `tree-sitter-raml` crate and npm package.

### [tools](tools/)

`release-versions.mjs` and its test. It checks that the root `Cargo.toml`'s `[workspace.package]` version, which both crates inherit, matches the root and grammar `package.json` files and every `tree-sitter.json`, and, given a tag, that they all carry the tag's version. `Verify` runs it on every pull request and `release.yml` runs it before publishing.

### [.github/workflows](.github/workflows/)

The automation described in the next sections.

### Root files

`tree-sitter.json` declares both grammars to the tree-sitter CLI (name, scope, file types, highlight query). `Cargo.toml` is the Rust workspace with members `dataweave` and `raml`; its `[workspace.package]` version is the one both crates inherit. `package.json` is the private npm workspace root that holds the shared oxlint, oxfmt, and tree-sitter CLI dev dependencies and its version, which gala keeps equal to the workspace version; `.oxlintrc.json` and `.oxfmtrc.json` configure the lint and format tools for both grammars. `.gala.toml` configures version and changelog calculation.

## External systems and data flow

The grammars read no external system at run time. A consumer hands source text to the generated parser through the Rust crate or the Node.js addon and receives a syntax tree; highlight queries in `queries/highlights.scm` map nodes to highlight names.

At build and release time the repository talks to three services:

- **GitHub Actions** runs verification and the release pipeline.
- **crates.io** and **npmjs** receive the published packages, and **GitHub Packages** receives a copy of the npm packages scoped to the repository owner.

## Build, test, release, and deploy

The `Verify` workflow (`verify.yml`) runs on every pull request and on pushes to `dev` and `main`. It checks the pull request title, scans the working tree and the Git history for secrets, regenerates both parsers and fails on drift in `parser.c`, `grammar.json`, `node-types.json`, and the node-kind snapshots, runs the corpus tests, parses every fixture and rejects `ERROR` or `MISSING` nodes, runs `cargo fmt`, `clippy`, and `cargo test`, builds the Rust crates against tree-sitter 0.26 as well, builds and tests the Node.js binding on Linux and Windows, and lints the workflow files. A pull request that touches only the root `README.md`, `CONTRIBUTING.md`, or `SECURITY.md` skips the heavy jobs.

`dev` is the default branch and `main` is the production branch. After each push to `main`, `gala-release.yml` runs gala, which bumps the `[workspace.package]` version and writes it into every `package.json` and `tree-sitter.json`, regenerates both parsers (they embed the `tree-sitter.json` version), writes `CHANGELOG.md`, commits, tags `vMAJOR.MINOR.PATCH`, pushes over a deploy key, and fast-forwards `dev`; the workflow then dispatches `release.yml` on the tag, which verifies it, builds native addons, and publishes both packages to crates.io, npmjs, and GitHub Packages. `cache-cleanup.yml` deletes stale Actions caches on a daily schedule. [docs/RELEASING.md](docs/RELEASING.md) has the step-by-step release procedure.

Nothing in this repository is deployed to a server; the output is the published packages.

## Where things live

| Path | Holds |
| --- | --- |
| `dataweave/grammar.js`, `raml/grammar.js` | Grammar definitions, the source of truth for each parser |
| `dataweave/src/`, `raml/src/` | Generated parser files (committed) and, for RAML, the external scanner |
| `*/queries/` | Highlight queries |
| `*/test/corpus/` | Tree assertions in tree-sitter's corpus format |
| `*/test/fixtures/` | Larger real-shaped sample files that must parse without error |
| `*/test/node-kinds.txt` | Snapshot of node kinds, regenerated by `generate-node-kinds.mjs` |
| `*/bindings/rust/`, `*/bindings/node/` | Rust crate source and Node.js addon |
| `tools/` | Release version check script and tests |
| `.github/workflows/` | Verification, release, and maintenance workflows |
