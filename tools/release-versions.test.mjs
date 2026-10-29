import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { checkVersions, collectVersions, workspaceVersion } from './release-versions.mjs';

const crate = (name, version = 'version.workspace = true') =>
  `[package]\nname = "${name}"\n${version}\nedition = "2024"\n\n[dependencies]\nfoo = { version = "1.2.3" }\n`;

function scaffold(version, overrides = {}) {
  const root = mkdtempSync(join(tmpdir(), 'release-versions-'));
  const files = {
    'Cargo.toml': `[workspace]\nmembers = ["dataweave", "raml"]\n\n[workspace.package]\nversion = "${version}"\n`,
    'package.json': JSON.stringify({ name: 'root', version, private: true }),
    'tree-sitter.json': JSON.stringify({ metadata: { version } }),
  };
  for (const grammar of ['dataweave', 'raml']) {
    mkdirSync(join(root, grammar));
    files[`${grammar}/Cargo.toml`] = crate(`tree-sitter-${grammar}`);
    files[`${grammar}/package.json`] = JSON.stringify({ name: grammar, version });
    files[`${grammar}/tree-sitter.json`] = JSON.stringify({ metadata: { version } });
  }
  for (const [path, content] of Object.entries({ ...files, ...overrides })) {
    writeFileSync(join(root, path), content);
  }
  return root;
}

test('workspaceVersion reads only the [workspace.package] table', () => {
  const manifest =
    '[workspace]\nmembers = []\n\n[workspace.package]\nversion = "0.2.0"\n\n[workspace.dependencies]\nfoo = { version = "1.0.0" }\n';
  assert.equal(workspaceVersion(manifest), '0.2.0');
  assert.equal(workspaceVersion('[workspace]\nmembers = []\n'), undefined);
});

test('agreeing versions pass with and without a matching tag', () => {
  const root = scaffold('0.2.0');
  try {
    const found = collectVersions(root);
    assert.equal(checkVersions(found), '0.2.0');
    assert.equal(checkVersions(found, 'v0.2.0'), '0.2.0');
    assert.throws(() => checkVersions(found, 'v0.2.1'), /0\.2\.1/);
    for (const tag of ['main', '--help', 'v0.2.0-rc.1', '0.2.0']) {
      assert.throws(() => checkVersions(found, tag));
    }
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('a drifted file is named in the failure', () => {
  const root = scaffold('0.2.0', {
    'raml/tree-sitter.json': JSON.stringify({ metadata: { version: '0.1.9' } }),
  });
  try {
    assert.throws(
      () => checkVersions(collectVersions(root)),
      /raml\/tree-sitter\.json has 0\.1\.9/,
    );
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test('a crate with its own version is refused', () => {
  const root = scaffold('0.2.0', {
    'dataweave/Cargo.toml': crate('tree-sitter-dataweave', 'version = "0.2.0"'),
  });
  try {
    assert.throws(() => collectVersions(root), /version\.workspace/);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});
