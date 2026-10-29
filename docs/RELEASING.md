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
2. Each push to `main` runs `Gala release` (`gala-release.yml`). gala (configured in `.gala.toml`) reads the Conventional Commits since the latest `v*` tag. When a release is due it bumps the root `Cargo.toml`'s `[workspace.package]` version, which both crates inherit, writes the same version into the root and grammar `package.json` files and every `tree-sitter.json`, regenerates both parsers with `npm run build` (they embed the `tree-sitter.json` version), writes `CHANGELOG.md`, commits `chore(release): vX.Y.Z`, tags the commit, pushes the branch and tag atomically over the `RELEASE_DEPLOY_KEY` deploy key, and fast-forwards `dev` to the release commit. When nothing is due it changes nothing.
3. The release commit carries a skip-ci marker that can also suppress the tag-push trigger of `release.yml`, so `gala-release.yml` dispatches `Release` on the new tag itself. If both triggers fire, the second run finds every version already published and skips it.

Both grammar packages release together, so gala sees one app whose version is the workspace version. Every file that states the version is written in the release commit, so the tag carries exactly what `Release` publishes, and the regenerated parsers keep the Verify drift check passing on the release commit. `tools/release-versions.mjs` fails a pull request that lets any of those files drift from the workspace version.

A release publishes both packages. A published version number cannot be reused on crates.io or npm, so check the plan before promoting: `go run github.com/alfpricot/gala/cmd/gala@v0.3.1 plan` is read-only.

## What the Release workflow does

The workflow starts on a pushed `v*` tag, or manually with an existing tag as input:

```bash
gh workflow run release.yml --ref <tag> -f tag=<tag>
```

It then runs these stages in order:

1. **Verify before publishing.** Checks that the tag matches `vMAJOR.MINOR.PATCH` and, with `tools/release-versions.mjs`, that the workspace version, every `package.json`, and every `tree-sitter.json` equal the tag's version, regenerates both parsers and fails on any difference from the committed files, runs the corpus tests, parses every fixture and rejects `ERROR` or `MISSING` nodes, and runs formatting, lints, tests, and `cargo package` for the Rust workspace.
2. **Prebuild.** Builds the native Node.js addon for each grammar on Linux and Windows.
3. **Publish.** Publishes each crate to crates.io and each npm package to npmjs and GitHub Packages. The published versions are the ones committed at the tag; the workflow edits no version. Each registry skips a version that is already published, so a rerun after a partial failure only publishes what is missing.
4. **GitHub Release.** Creates the GitHub Release after every package has succeeded.

## Secrets

Repository secrets `CARGO_REGISTRY_TOKEN` (crates.io) and `NPM_TOKEN` (npmjs) must be set. `RELEASE_DEPLOY_KEY` must hold the private half of a write-access deploy key, and the repository rulesets must let that key push `main` and `dev` and create `v*` tags. GitHub Packages uses the workflow's own `GITHUB_TOKEN`.
