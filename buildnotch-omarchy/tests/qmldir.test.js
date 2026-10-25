// Run: node tests/qmldir.test.js
// Every component in qml/ must be registered in qmldir, otherwise the implicit
// directory import hides it ("X is not a type"). shell.qml is the entry point.
const fs = require("fs");
const path = require("path");

const dir = path.join(__dirname, "../qml");
const listed = new Map();
for (const line of fs.readFileSync(path.join(dir, "qmldir"), "utf8").split("\n")) {
  const m = line.trim().match(/^(?:singleton\s+)?(\w+)\s+\d+\.\d+\s+(\S+\.qml)$/);
  if (m) listed.set(m[2], m[1]);
}

const errors = [];
for (const f of fs.readdirSync(dir).filter((f) => f.endsWith(".qml") && f !== "shell.qml")) {
  const name = f.replace(/\.qml$/, "");
  if (listed.get(f) !== name) errors.push(`${f} is not listed in qml/qmldir as "${name} 1.0 ${f}"`);
}
for (const f of listed.keys()) {
  if (!fs.existsSync(path.join(dir, f))) errors.push(`qmldir lists missing file ${f}`);
}
if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log(`qmldir ok (${listed.size} entries)`);
