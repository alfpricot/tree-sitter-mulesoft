# Releasing

How a release of `tree-sitter-dataweave` and `tree-sitter-raml` is cut and published. Both grammars always release together under one `vMAJOR.MINOR.PATCH` tag. The workspace root is private and is never published.

## What gets published

The `Release` workflow (`.github/workflows/release.yml`) publishes:

- both crates to crates.io;
- both npm packages (`tree-sitter-dataweave`, `tree-sitter-raml`) to npmjs;
- the same npm packages to GitHub Packages, scoped to the repository owner (currently `@alfpricot/tree-sitter-dataweave` and `@alfpricot/tree-sitter-raml`).

The npm packages ship prebuilt native addons for Linux and Windows and the generated C parsers. On a platform without a prebuilt addon, installation compiles one from source.

## Automated release path

1. Changes land on `dev` through pull requests, and `dev` is promoted to `main` by pull request.
2. Each push to `main` runs `Release-plz` (`release-plz.yml`). When there are unreleased changes it opens or updates a `chore(release)` pull request from the `release-plz/release` branch with the next version and changelog entry. `tools/release-lockstep.mjs` takes the higher of the two crates' proposed versions and writes it to both crates, both `package.json` files, every `tree-sitter.json`, and the root, then both parsers are regenerated because they embed the version.
3. Merging that pull request runs `Release tag` (`release-tag.yml`). It creates the `vMAJOR.MINOR.PATCH` tag from `dataweave/Cargo.toml` and dispatches the `Release` workflow on the tag.
4. `Sync dev from main` (`sync-dev-from-main.yml`) opens a pull request that merges `main` back into `dev`.

Merging a release pull request publishes both packages. A published version number cannot be reused on crates.io or npm, so check the version in the pull request before merging.

## What the Release workflow does

The workflow starts on a pushed `v*` tag, or manually with an existing tag as input:

```bash
gh workflow run release.yml --ref <tag> -f tag=<tag>
```

It then runs these stages in order:

1. **Verify before publishing.** Checks that the tag matches `vMAJOR.MINOR.PATCH` and that both grammar `Cargo.toml` versions equal the tag's version, regenerates both parsers and fails on any difference from the committed files, runs the corpus tests, parses every fixture and rejects `ERROR` or `MISSING` nodes, and runs formatting, lints, tests, and `cargo package` for the Rust workspace.
2. **Prebuild.** Builds the native Node.js addon for each grammar on Linux and Windows.
3. **Publish.** Publishes each crate to crates.io and each npm package to npmjs and GitHub Packages. npm versions are set from the tag in the publishing checkouts only; the committed `package.json` versions are not edited by the workflow. Each registry skips a version that is already published, so a rerun after a partial failure only publishes what is missing.
4. **GitHub Release.** Creates the GitHub Release after every package has succeeded.

## Secrets

Repository secrets `CARGO_REGISTRY_TOKEN` (crates.io) and `NPM_TOKEN` (npmjs) must be set. GitHub Packages uses the workflow's own `GITHUB_TOKEN`.
