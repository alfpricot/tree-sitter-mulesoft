import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

// Both grammars release in lockstep under one vMAJOR.MINOR.PATCH tag. gala
// bumps the root Cargo.toml's [workspace.package] version, which both crates
// inherit, and writes the same version into every package.json and
// tree-sitter.json in the release commit, then regenerates the parsers, which
// embed the tree-sitter.json version. This check fails when any of them
// drifts, so a pull request cannot leave gala a mismatch to refuse at release
// time.

export const GRAMMARS = ['dataweave', 'raml'];
const STABLE = /^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/;

export function tomlSection(manifest, name) {
  const header = new RegExp(`^\\[${name.replace(/\./g, '\\.')}\\]\\s*$`, 'm');
  return manifest.split(header)[1]?.split(/^\[/m)[0];
}

export function workspaceVersion(manifest) {
  return tomlSection(manifest, 'workspace.package')?.match(/^version\s*=\s*"([^"]+)"\s*$/m)?.[1];
}

export function inheritsVersion(manifest) {
  return /^version\.workspace\s*=\s*true\s*$/m.test(tomlSection(manifest, 'package') ?? '');
}

export function collectVersions(root = '.') {
  const read = (path) => readFileSync(join(root, path), 'utf8');
  const json = (path) => JSON.parse(read(path));
  const found = {
    'Cargo.toml [workspace.package]': workspaceVersion(read('Cargo.toml')),
    'package.json': json('package.json').version,
    'tree-sitter.json': json('tree-sitter.json').metadata?.version,
  };
  for (const grammar of GRAMMARS) {
    assert(
      inheritsVersion(read(`${grammar}/Cargo.toml`)),
      `${grammar}/Cargo.toml must set version.workspace = true`,
    );
    found[`${grammar}/package.json`] = json(`${grammar}/package.json`).version;
    found[`${grammar}/tree-sitter.json`] = json(`${grammar}/tree-sitter.json`).metadata?.version;
  }
  return found;
}

export function checkVersions(found, tag) {
  if (tag !== undefined) assert(STABLE.test(tag), 'Release tags must use vMAJOR.MINOR.PATCH');
  const expected = tag === undefined ? found['Cargo.toml [workspace.package]'] : tag.slice(1);
  assert(expected, 'Cargo.toml has no [workspace.package] version');
  const wrong = Object.entries(found)
    .filter(([, version]) => version !== expected)
    .map(([file, version]) => `${file} has ${version}`);
  assert.deepEqual(wrong, [], `Every version must be ${expected}: ${wrong.join(', ')}`);
  return expected;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const version = checkVersions(collectVersions(), process.argv[2]);
  console.log(`Every manifest and tree-sitter.json carries ${version}`);
}
