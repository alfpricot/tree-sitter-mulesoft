import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const dir = fileURLToPath(new URL('.', import.meta.url));
const nodeTypes = JSON.parse(readFileSync(`${dir}../src/node-types.json`, 'utf8'));

const kinds = [...new Set(nodeTypes.filter((node) => node.named).map((node) => node.type))].sort();

writeFileSync(`${dir}node-kinds.txt`, `${kinds.join('\n')}\n`);
