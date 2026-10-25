.pragma library

// Pure logic, no Quickshell types, so it can be unit-tested with node (tests/lib.test.js).

var WIDGET_IDS = ["music", "pomodoro", "ai", "usage", "github", "projects", "quote", "apps", "note"];

var DEFAULT_CFG = {
    monitor: "",
    hoverOpen: true,
    shortNotch: false,
    reduceMotion: false,
    pomoStyle: "clean",
    focusMin: 25,
    shortMin: 5,
    longMin: 15,
    wallpaper: "",
    terminal: ["xdg-terminal-exec"],
    editor: ["nvim"],
    githubRefreshMinutes: 30,
    hideFullscreen: ["google-chrome", "chromium", "Google-chrome", "Chromium"],
    widgets: WIDGET_IDS.map(function (id) { return { id: id, visible: true }; }),
    usage: {
        refreshMinutes: 5,
        providers: [
            { id: "codex", name: "Codex", enabled: true, command: "" },
            { id: "claude", name: "Claude", enabled: true, command: "" },
            { id: "gemini", name: "Gemini", enabled: false, command: "" },
            { id: "cursor", name: "Cursor", enabled: false, command: "" }
        ]
    },
    customApps: [],
    favorites: []
};

var DEFAULT_DATA = {
    project: 0,
    projects: [{ name: "Portfolio", path: "", url: "", tasks: [] }],
    note: "",
    noteSavedAt: 0,
    playground: { lang: "JavaScript", code: "" },
    quote: 0,
    sessions: 0
};

function clone(o) { return JSON.parse(JSON.stringify(o)); }

function merge(base, over) {
    var out = {};
    var k;
    for (k in base) out[k] = clone(base[k]);
    if (!over || typeof over !== "object" || Array.isArray(over)) return out;
    for (k in over) {
        if (!(k in base)) continue;
        var b = base[k], o = over[k];
        if (b && typeof b === "object" && !Array.isArray(b)) out[k] = merge(b, o);
        else if (Array.isArray(b) ? Array.isArray(o) : typeof o === typeof b) out[k] = o;
    }
    return out;
}

function parseJson(text) {
    try { return JSON.parse(text); } catch (e) { return null; }
}

// Keeps saved order and visibility; appends widgets added in newer versions; drops unknown ids.
function normalizeWidgets(saved) {
    var out = [], seen = {};
    (Array.isArray(saved) ? saved : []).forEach(function (w) {
        if (w && WIDGET_IDS.indexOf(w.id) >= 0 && !seen[w.id]) {
            seen[w.id] = true;
            out.push({ id: w.id, visible: w.visible !== false });
        }
    });
    WIDGET_IDS.forEach(function (id) { if (!seen[id]) out.push({ id: id, visible: true }); });
    return out;
}

function normalizeCfg(parsed) {
    var c = merge(DEFAULT_CFG, parsed);
    c.widgets = normalizeWidgets(c.widgets);
    ["focusMin", "shortMin", "longMin"].forEach(function (k) { if (!(c[k] > 0)) c[k] = DEFAULT_CFG[k]; });
    return c;
}

function normalizeData(parsed) {
    var d = merge(DEFAULT_DATA, parsed);
    d.projects = (Array.isArray(d.projects) ? d.projects : []).filter(function (p) {
        return p && typeof p.name === "string";
    }).map(function (p) {
        return {
            name: p.name,
            path: typeof p.path === "string" ? p.path : "",
            url: typeof p.url === "string" ? p.url : "",
            tasks: (Array.isArray(p.tasks) ? p.tasks : []).filter(function (t) {
                return t && typeof t.text === "string";
            }).map(function (t) {
                return { text: t.text, done: t.done === true, due: typeof t.due === "string" ? t.due : "" };
            })
        };
    });
    if (d.projects.length === 0) d.projects.push({ name: "Inbox", path: "", url: "", tasks: [] });
    if (!(d.project >= 0 && d.project < d.projects.length)) d.project = 0;
    return d;
}

// Moves widget `fromId` to the slot currently held by `toId` (visible order maps onto the full list,
// so hidden cards keep their position).
function moveWidget(list, fromId, toId) {
    var out = list.slice();
    var from = out.findIndex(function (w) { return w.id === fromId; });
    var to = out.findIndex(function (w) { return w.id === toId; });
    if (from < 0 || to < 0 || from === to) return out;
    var item = out.splice(from, 1)[0];
    out.splice(to, 0, item);
    return out;
}

function fmt(sec) {
    sec = Math.max(0, Math.floor(sec));
    var m = Math.floor(sec / 60), s = sec % 60;
    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
}

function wordCount(text) {
    var m = String(text || "").trim().match(/\S+/g);
    return m ? m.length : 0;
}

function relTime(ts, now) {
    var s = Math.max(0, Math.floor(((now || Date.now()) - ts) / 1000));
    if (s < 60) return s + " sec ago";
    var m = Math.floor(s / 60);
    if (m < 60) return m + " min ago";
    var h = Math.floor(m / 60);
    if (h < 24) return h + " hr ago";
    return Math.floor(h / 24) + " d ago";
}

function expandHome(p, home) {
    if (p === "~") return home;
    return p.indexOf("~/") === 0 ? home + p.slice(1) : p;
}

// ---- JSON tool (Developer tools -> Format) ----

function lineCol(text, pos) {
    var line = 1, col = 1;
    for (var i = 0; i < pos && i < text.length; i++) {
        if (text[i] === "\n") { line++; col = 1; } else col++;
    }
    return { line: line, col: col };
}

// mode: "pretty" | "minify". Returns { ok, text, error }. Invalid JSON reports where parsing failed.
function formatJson(text, mode) {
    if (!String(text).trim()) return { ok: false, text: "", error: "Nothing to format." };
    try {
        var v = JSON.parse(text);
        return { ok: true, text: mode === "minify" ? JSON.stringify(v) : JSON.stringify(v, null, 2), error: "" };
    } catch (e) {
        var msg = String(e.message || e);
        var m = msg.match(/position (\d+)/);
        var where = "";
        if (m) { var lc = lineCol(text, parseInt(m[1], 10)); where = " (line " + lc.line + ", column " + lc.col + ")"; }
        else {
            var l = msg.match(/line (\d+) column (\d+)/);
            if (l) where = " (line " + l[1] + ", column " + l[2] + ")";
        }
        return { ok: false, text: "", error: "Invalid JSON" + where + ": " + msg };
    }
}

// ---- GitHub ----

var CONTRIB_QUERY = "query { viewer { login avatarUrl contributionsCollection { contributionCalendar { totalContributions weeks { contributionDays { contributionCount date } } } } } }";

function level(count, max) {
    if (count <= 0 || max <= 0) return 0;
    return Math.min(4, Math.ceil((count / max) * 4));
}

// Returns { login, avatar, total, weeks: [[{count,date,level}]] } for the last `keep` weeks, or throws.
function parseContributions(text, keep) {
    var j = JSON.parse(text);
    var v = j && j.data && j.data.viewer;
    if (!v) throw new Error("unexpected response from gh");
    var weeks = v.contributionsCollection.contributionCalendar.weeks.slice(-(keep || 18));
    var max = 0, total = 0;
    weeks.forEach(function (w) {
        w.contributionDays.forEach(function (d) { total += d.contributionCount; if (d.contributionCount > max) max = d.contributionCount; });
    });
    return {
        login: v.login,
        avatar: v.avatarUrl || "",
        total: total,
        weeks: weeks.map(function (w) {
            return w.contributionDays.map(function (d) {
                return { count: d.contributionCount, date: d.date, level: level(d.contributionCount, max) };
            });
        })
    };
}

// ---- Clipboard (cliphist) ----

function classifyClip(preview) {
    var t = String(preview).trim();
    if (/^\[\[ binary data .*\]\]$/.test(t)) return "image";
    if (/^(https?:\/\/|www\.)\S+$/.test(t)) return "link";
    if (/[{};]\s*$|=>|^\s*(import|export|const|let|var|function|def|class|fn|pub|use|#include|npm|git|cargo|sudo)\b|<\/?[a-z][^>]*>/m.test(t)) return "code";
    return "text";
}

// `cliphist list` lines: "<id>\t<preview>". Image previews look like "[[ binary data 1.2 MiB png 800x600 ]]".
function parseCliphist(text, now) {
    var out = [];
    String(text).split("\n").forEach(function (line) {
        var i = line.indexOf("\t");
        if (i <= 0) return;
        var id = line.slice(0, i), prev = line.slice(i + 1);
        if (!/^\d+$/.test(id)) return;
        var kind = classifyClip(prev), meta = "";
        if (kind === "image") {
            var m = prev.match(/binary data (\S+ \S+) (\w+) (\d+x\d+)/);
            if (m) meta = m[2].toUpperCase() + " · " + m[1];
        }
        out.push({ id: id, kind: kind, preview: kind === "image" ? (meta || "Image") : prev, meta: meta });
    });
    return out;
}

function clipMatches(item, filter) {
    if (filter === "All") return true;
    return ({ Text: "text", Code: "code", Images: "image", Links: "link" })[filter] === item.kind;
}

// ---- System readouts ----

// scripts/sysstat.sh prints: "cpu u n s idle iow irq sirq st", "memtotal kB", "memavail kB", "net rxBytes txBytes", "bat pct status".
function parseSys(text, prev, dtSec) {
    var r = { cpu: prev ? prev.cpu : 0, ramUsed: 0, ramTotal: 0, net: 0, bat: -1, charging: false,
              _cpuTotal: 0, _cpuIdle: 0, _net: 0 };
    String(text).split("\n").forEach(function (line) {
        var p = line.trim().split(/\s+/);
        if (p[0] === "cpu") {
            var n = p.slice(1).map(Number);
            var total = n.reduce(function (a, b) { return a + b; }, 0), idle = n[3] + (n[4] || 0);
            r._cpuTotal = total; r._cpuIdle = idle;
            if (prev && total > prev._cpuTotal) {
                r.cpu = Math.round(100 * (1 - (idle - prev._cpuIdle) / (total - prev._cpuTotal)));
            }
        } else if (p[0] === "memtotal") r.ramTotal = Number(p[1]) / 1048576;
        else if (p[0] === "memavail") r.ramUsed = r.ramTotal - Number(p[1]) / 1048576;
        else if (p[0] === "net") {
            r._net = Number(p[1]) + Number(p[2]);
            if (prev && dtSec > 0 && r._net >= prev._net) r.net = (r._net - prev._net) / dtSec / 1048576;
        } else if (p[0] === "bat" && p.length >= 3) {
            r.bat = Number(p[1]); r.charging = p[2] === "Charging" || p[2] === "Full";
        }
    });
    r.cpu = Math.max(0, Math.min(100, r.cpu));
    return r;
}

// ---- Fullscreen app rules ----

function shouldHide(active, rules) {
    if (!active || !active.fullscreen) return false;
    var cls = String(active.class || "").toLowerCase();
    return (rules || []).some(function (r) { return String(r).toLowerCase() === cls; });
}

// ---- AI apps and usage ----

var AI_KNOWN = [
    { name: "Claude", ids: ["claude", "claude-desktop"] },
    { name: "ChatGPT", ids: ["chatgpt"] },
    { name: "Codex", ids: ["codex"] },
    { name: "Cursor", ids: ["cursor"] },
    { name: "Antigravity", ids: ["antigravity"] },
    { name: "T3 Code (Alpha)", ids: ["t3code", "t3-code", "t3"] },
    { name: "Windsurf", ids: ["windsurf"] },
    { name: "Zed", ids: ["zed", "dev.zed.zed"] },
    { name: "Ollama", ids: ["ollama"] },
    { name: "LM Studio", ids: ["lm-studio", "lmstudio"] },
    { name: "Perplexity", ids: ["perplexity"] },
    { name: "Gemini", ids: ["gemini"] }
];

// entries: [{ id, name }] from the desktop database; returns matches in AI_KNOWN order.
function matchAiApps(entries) {
    var out = [], used = {};
    AI_KNOWN.forEach(function (k) {
        for (var i = 0; i < entries.length; i++) {
            var id = String(entries[i].id).toLowerCase().replace(/\.desktop$/, "");
            if (!used[i] && k.ids.indexOf(id) >= 0) { used[i] = true; out.push({ name: k.name, index: i }); break; }
        }
    });
    return out;
}

// Provider command output: { "plan": "Plus", "windows": [{ "label": "5-hour limit", "usedPercent": 12, "resetsAt": "2026-09-28T17:49:00Z" }] }
function parseUsage(text) {
    var j = JSON.parse(text);
    var ws = (Array.isArray(j.windows) ? j.windows : []).filter(function (w) {
        return w && typeof w.label === "string" && typeof w.usedPercent === "number";
    }).map(function (w) {
        return { label: w.label, used: Math.max(0, Math.min(100, w.usedPercent)), resetsAt: w.resetsAt || "" };
    });
    if (ws.length === 0) throw new Error("no usage windows");
    return { plan: typeof j.plan === "string" ? j.plan : "", windows: ws };
}

// ---- Quotes ----

var QUOTES = [
    "Your future is created by what you do today, not tomorrow.",
    "Ship the smallest useful version, then learn from real behavior.",
    "We are what we repeatedly do. Excellence is a habit, not an act.",
    "The impediment to action advances action. What stands in the way becomes the way.",
    "You have power over your mind, not outside events. Realize this, and you will find strength.",
    "Make it work, make it right, make it fast.",
    "Waste no more time arguing what a good man should be. Be one.",
    "It is not that we have a short time to live, but that we waste much of it.",
    "Done is better than perfect.",
    "Simplicity is the ultimate sophistication.",
    "What we do now echoes in eternity.",
    "The best way out is always through.",
    "A journey of a thousand miles begins with a single step.",
    "Focus is saying no to a hundred good ideas.",
    "Small steps every day beat big plans someday.",
    "He who has a why to live can bear almost any how.",
    "Begin at once to live, and count each separate day as a separate life.",
    "The obstacle is the path.",
    "Quality is not an act, it is a habit.",
    "Do the hard thing first.",
    "Perfection is achieved when there is nothing left to take away.",
    "Courage is resistance to fear, mastery of fear, not absence of fear.",
    "Stay hungry. Stay foolish.",
    "If it scares you, it might be a good thing to try.",
    "Real artists ship.",
    "The secret of getting ahead is getting started.",
    "Be so good they cannot ignore you.",
    "Energy and persistence conquer all things.",
    "Don't watch the clock; do what it does. Keep going.",
    "Action is the foundational key to all success.",
    "Discipline is choosing between what you want now and what you want most.",
    "You do not rise to the level of your goals. You fall to the level of your systems.",
    "Every expert was once a beginner.",
    "Well begun is half done.",
    "Think like a person of action, act like a person of thought.",
    "Build something people want.",
    "Make something you would use every day.",
    "First do it, then do it right, then do it better.",
    "Fall seven times, stand up eight.",
    "Nothing will work unless you do."
];
