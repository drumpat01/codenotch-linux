// Run: node tests/lib.test.js  (Lib.js is a QML .pragma library but plain JS otherwise.)
const fs = require("fs");
const vm = require("vm");
const path = require("path");
const assert = require("assert");
const deq = (a, b) => assert.strictEqual(JSON.stringify(a), JSON.stringify(b));

const src = fs.readFileSync(path.join(__dirname, "../qml/Lib.js"), "utf8").replace(/^\.pragma library/m, "");
const ctx = {};
vm.createContext(ctx);
vm.runInContext(src + "\nthis.Lib = { " +
    "normalizeCfg, normalizeData, normalizeWidgets, moveWidget, fmt, wordCount, relTime, formatJson, parseContributions, " +
    "classifyClip, parseCliphist, clipMatches, parseSys, shouldHide, reservedTop, resizeRemaining, sourceBadge, matchAiApps, parseUsage, QUOTES, DEFAULT_CFG, expandHome };", ctx);
const L = ctx.Lib;

// config
let c = L.normalizeCfg({ hoverOpen: false, focusMin: -3, bogus: 1, pomoStyle: 5 });
assert.strictEqual(c.hoverOpen, false);
assert.strictEqual(c.focusMin, 25);
assert.strictEqual(c.pomoStyle, "clean");
assert.ok(!("bogus" in c));
assert.strictEqual(c.widgets.length, 9);
c = L.normalizeCfg({ widgets: [{ id: "note", visible: false }, { id: "nope" }, { id: "music" }] });
deq(c.widgets.slice(0, 2).map(w => w.id), ["note", "music"]);
assert.strictEqual(c.widgets[0].visible, false);
assert.strictEqual(c.widgets.length, 9);

// data
const d = L.normalizeData({ projects: [{ name: "A", tasks: [{ text: "x", done: true }, { nope: 1 }] }], project: 9 });
assert.strictEqual(d.projects[0].tasks.length, 1);
assert.strictEqual(d.project, 0);
assert.strictEqual(L.normalizeData(null).projects[0].name, "Portfolio");

// layout move keeps hidden cards in place
const ws = [{ id: "a", visible: true }, { id: "b", visible: false }, { id: "c", visible: true }];
deq(L.moveWidget(ws, "a", "c").map(w => w.id), ["b", "c", "a"]);
deq(L.moveWidget(ws, "a", "a").map(w => w.id), ["a", "b", "c"]);

// text helpers
assert.strictEqual(L.fmt(1500), "25:00");
assert.strictEqual(L.fmt(-4), "00:00");
assert.strictEqual(L.wordCount("  one two\nthree "), 3);
assert.strictEqual(L.wordCount(""), 0);
assert.strictEqual(L.relTime(0, 12000), "12 sec ago");
assert.strictEqual(L.relTime(0, 120000), "2 min ago");
assert.strictEqual(L.expandHome("~/x", "/h"), "/h/x");

// JSON tool
assert.strictEqual(L.formatJson('{"a":1,"b":[1,2]}', "minify").text, '{"a":1,"b":[1,2]}');
assert.strictEqual(L.formatJson('{"a":1}', "pretty").text, '{\n  "a": 1\n}');
let bad = L.formatJson('{"a":1,\n"b":}', "pretty");
assert.strictEqual(bad.ok, false);
assert.ok(/Invalid JSON/.test(bad.error), bad.error);
assert.strictEqual(L.formatJson("   ", "pretty").ok, false);

// GitHub
const gh = JSON.stringify({ data: { viewer: { login: "me", avatarUrl: "u", contributionsCollection: { contributionCalendar: { totalContributions: 99, weeks: [
    { contributionDays: [{ contributionCount: 0, date: "2026-01-01" }] },
    { contributionDays: [{ contributionCount: 4, date: "2026-01-08" }, { contributionCount: 1, date: "2026-01-09" }] }] } } } } });
const r = L.parseContributions(gh, 1);
assert.strictEqual(r.total, 5);
assert.strictEqual(r.weeks.length, 1);
deq(r.weeks[0].map(x => x.level), [4, 1]);
assert.throws(() => L.parseContributions("{}", 18));

// clipboard
const list = "12\t[[ binary data 1.2 MiB png 800x600 ]]\n11\thttps://github.com/microsoft/windows-rs\n10\tnpm run tauri dev\n9\tShip the smallest useful version.\nx\tjunk\n";
const cl = L.parseCliphist(list);
deq(cl.map(x => x.kind), ["image", "link", "code", "text"]);
assert.strictEqual(cl[0].meta, "PNG · 1.2 MiB");
assert.strictEqual(L.clipMatches(cl[1], "Links"), true);
assert.strictEqual(L.clipMatches(cl[1], "Text"), false);
assert.strictEqual(L.clipMatches(cl[1], "All"), true);

// system
const s1 = L.parseSys("cpu 100 0 100 800 0 0 0 0\nmemtotal 16777216\nmemavail 8388608\nnet 1000 1000\nbat 80 Charging", null, 0);
assert.strictEqual(Math.round(s1.ramTotal), 16);
assert.strictEqual(Math.round(s1.ramUsed), 8);
assert.strictEqual(s1.bat, 80);
assert.strictEqual(s1.charging, true);
const s2 = L.parseSys("cpu 200 0 200 1600 0 0 0 0\nmemtotal 16777216\nmemavail 8388608\nnet 2098152 1000\nbat 79 Discharging", s1, 1);
assert.strictEqual(s2.cpu, 20);
assert.ok(Math.abs(s2.net - 2) < 0.001);

// fullscreen rules
assert.strictEqual(L.shouldHide({ fullscreen: 1, class: "Google-chrome" }, ["google-chrome"]), true);
assert.strictEqual(L.shouldHide({ fullscreen: 0, class: "google-chrome" }, ["google-chrome"]), false);
assert.strictEqual(L.shouldHide({ fullscreen: 2, class: "mpv" }, ["google-chrome"]), false);

// timer length change, bar offset, music badge
assert.strictEqual(L.resizeRemaining(600, 1500, 900), 0);
assert.strictEqual(L.resizeRemaining(1500, 1500, 900), 900);
assert.strictEqual(L.resizeRemaining(1200, 1500, 3000), 2700);
assert.strictEqual(L.reservedTop({ reserved: [0, 38, 0, 0] }), 38);
assert.strictEqual(L.reservedTop({ reserved: [0, 0, 0, 40] }), 0);
assert.strictEqual(L.reservedTop(null), 0);
assert.strictEqual(L.sourceBadge("Spotify", "spotify").name, "Spotify");
assert.strictEqual(L.sourceBadge("Mozilla Firefox", "firefox").name, "Firefox");
assert.strictEqual(L.sourceBadge("", "").name, "Player");
assert.strictEqual(L.sourceBadge("Strawberry", "").name, "Strawberry");

// AI apps and usage
const m = L.matchAiApps([{ id: "firefox.desktop" }, { id: "cursor.desktop" }, { id: "Claude" }]);
deq(m.map(x => x.name), ["Claude", "Cursor"]);
const u = L.parseUsage('{"plan":"Plus","windows":[{"label":"5-hour limit","usedPercent":0,"resetsAt":"x"}]}');
assert.strictEqual(u.windows[0].used, 0);
assert.throws(() => L.parseUsage('{"windows":[]}'));
assert.throws(() => L.parseUsage("nope"));

assert.ok(L.QUOTES.length >= 40);
console.log("lib tests passed");
