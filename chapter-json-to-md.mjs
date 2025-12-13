#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const [,, inFile, outDir] = process.argv;
if(!inFile || !outDir){
  console.error('Usage: node tools/chapter-json-to-md.mjs <input.json> <outDir>');
  process.exit(1);
}
const chapter = JSON.parse(fs.readFileSync(inFile,'utf8'));
fs.mkdirSync(outDir,{recursive:true});

const b = (arr)=> (arr||[]).map(x=>`- ${x}`).join('\n');

fs.writeFileSync(path.join(outDir,'index.md'),
`# ${chapter.title}\n\n${b(chapter.summary)}\n`, 'utf8');

fs.writeFileSync(path.join(outDir,'policies.md'),
`# Policies\n\n${(chapter.policies||[]).map(p=>`## ${p.id}\n\n**Policy:** ${p.text}\n\n**Rationale:** ${p.rationale}\n`).join('\n')}\n`, 'utf8');

fs.writeFileSync(path.join(outDir,'implementation.md'),
`# Implementation Steps\n\n${(chapter.implementation_steps||[]).map(s=>`## Step ${s.step}: ${s.role}\n\n**Action:** ${s.action}\n\n**Proof:** ${s.proof}\n`).join('\n')}\n`, 'utf8');

fs.writeFileSync(path.join(outDir,'diagrams.md'),
`# Diagrams\n\n${(chapter.diagrams||[]).map(d=>`## ${d.title}\n\n\`\`\`mermaid\n${d.mermaid}\n\`\`\`\n`).join('\n')}\n`, 'utf8');

const sec = chapter.security || {};
fs.writeFileSync(path.join(outDir,'security.md'),
`# Security\n\n## Threats\n${b(sec.threats)}\n\n## Tests\n${b(sec.tests)}\n\n## Gates\n${b(sec.gates)}\n`, 'utf8');

fs.writeFileSync(path.join(outDir,'compliance.md'),
`# Compliance Matrix\n\n${(chapter.compliance_matrix||[]).map(c=>`- **${c.control}** → ${c.evidence}`).join('\n')}\n`, 'utf8');

console.log('Wrote:', outDir);
