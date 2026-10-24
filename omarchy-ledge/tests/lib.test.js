// Run: node tests/lib.test.js  (QML's Lib.js is plain JS with a pragma comment)
const fs = require("fs"), assert = require("assert"), vm = require("vm");
const ctx = {};
vm.runInNewContext(fs.readFileSync(__dirname + "/../qml/Lib.js", "utf8").replace(".pragma library", ""), ctx);
const L = ctx;

assert.strictEqual(L.fmt(0), "00:00");
assert.strictEqual(L.fmt(1500), "25:00");
assert.strictEqual(L.fmt(61.4), "01:01");
assert.strictEqual(L.fmt(-5), "00:00");

assert.strictEqual(L.expandHome("~/code", "/h"), "/h/code");
assert.strictEqual(L.expandHome("/abs", "/h"), "/abs");

let c = L.parseConfig("not json");
assert.strictEqual(c.timerMinutes, 25);
c = L.parseConfig('{"timerMinutes": 50, "colors": {"accent": "#fff"}, "bogus": 1, "expandedWidth": "wide"}');
assert.strictEqual(c.timerMinutes, 50);
assert.strictEqual(c.colors.accent, "#fff");
assert.strictEqual(c.colors.bg, "#14161b");
assert.strictEqual(c.expandedWidth, 560); // wrong type ignored
assert.ok(!("bogus" in c));

let d = L.normalizeData({ projects: [{ name: "A", tasks: [{ text: "x", done: true }, { nope: 1 }] }], note: "hi" });
assert.strictEqual(d.projects[0].tasks.length, 1);
assert.strictEqual(d.projects[0].tasks[0].done, true);
assert.strictEqual(L.normalizeData(null).projects[0].name, "Inbox");

assert.strictEqual(L.level(0, 10), 0);
assert.strictEqual(L.level(10, 10), 4);
assert.strictEqual(L.level(1, 10), 1);

const r = L.parseContributions(JSON.stringify({ data: { viewer: { login: "me", contributionsCollection: { contributionCalendar: {
  totalContributions: 6, weeks: [{ contributionDays: [{ contributionCount: 2, date: "2026-01-01" }, { contributionCount: 4, date: "2026-01-02" }] }] } } } } }));
assert.strictEqual(r.total, 6);
assert.strictEqual(r.weeks[0][1].level, 4);
assert.throws(() => L.parseContributions('{"errors":[]}'));
console.log("ok");
