import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const dir = fileURLToPath(new URL('.', import.meta.url));
const nodeTypes = JSON.parse(readFileSync(`${dir}../src/node-types.json`, 'utf8'));
const named = nodeTypes.filter((node) => node.named);

const kinds = [...new Set(named.map((node) => node.type))].sort();

// One `kind.field -> type|type` line per field, so a renamed, retyped or
// re-counted field changes the snapshot. A trailing `?` marks an optional
// field and `*` one that can repeat. A named type is written as is and an
// anonymous token is quoted.
const fieldLines = named
  .flatMap((node) =>
    Object.entries(node.fields ?? {}).map(([field, info]) => {
      const types = info.types.map((t) => (t.named ? t.type : JSON.stringify(t.type))).sort();
      const marks = `${info.required ? '' : '?'}${info.multiple ? '*' : ''}`;
      return `${node.type}.${field}${marks} -> ${types.join('|')}`;
    }),
  )
  .sort();

writeFileSync(`${dir}node-kinds.txt`, `${[...kinds, ...fieldLines].join('\n')}\n`);
