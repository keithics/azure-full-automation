// parse-output.js
const fs = require('fs');
const path = require('path');

const jsonFilePath = process.argv[2];
if (!jsonFilePath) {
    console.error('Usage: node parse-output.js <absolute-path-to-output.json>');
    process.exit(1);
}

if (!fs.existsSync(jsonFilePath)) {
    console.error(`File not found: ${jsonFilePath}`);
    process.exit(1);
}

const unitName = path.basename(path.dirname(jsonFilePath));
const outputDir = path.dirname(jsonFilePath);
const targetFile = path.join(outputDir, 'output.hcl');

function formatValue(val) {
    if (typeof val === 'string') {
        return JSON.stringify(val);
    } else if (typeof val === 'object' && val !== null) {
        const entries = Object.entries(val)
            .map(([k, v]) => `      ${k} = ${formatValue(v)}`)
            .join('\n');
        return `{
${entries}
    }`;
    } else {
        return JSON.stringify(val);
    }
}

function generateHCL(unitName, outputJson) {
    const entries = Object.entries(outputJson);
    const lines = [
        'locals {',
        `  ${unitName} = {`
    ];

    for (const [key, value] of entries) {
        lines.push(`    ${key} = ${formatValue(value?.value)}`);
    }

    lines.push('  }', '}');
    return lines.join('\n');
}

const raw = fs.readFileSync(jsonFilePath, 'utf8');
const parsed = JSON.parse(raw);
const hcl = generateHCL(unitName, parsed);

fs.writeFileSync(targetFile, hcl);
console.log(`✅  Exported: ${targetFile}`);
console.log(`🎉 Finished processing output for unit '${unitName}'`);
