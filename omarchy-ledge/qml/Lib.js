.pragma library

var DEFAULTS = {
    monitor: "",
    collapsedWidth: 180,
    collapsedHeight: 6,
    expandedWidth: 560,
    expandedHeight: 300,
    hoverDelayMs: 120,
    collapseDelayMs: 350,
    animationMs: 220,
    timerMinutes: 25,
    terminal: ["xdg-terminal-exec"],
    editor: ["nvim"],
    githubRefreshMinutes: 30,
    projects: [],
    colors: { bg: "#14161b", fg: "#e6e8ee", dim: "#8a90a0", accent: "#7aa2f7", surface: "#1e2128" }
};

function merge(base, over) {
    var out = {};
    var k;
    for (k in base) out[k] = base[k];
    if (!over || typeof over !== "object") return out;
    for (k in over) {
        if (!(k in base)) continue;
        var b = base[k], o = over[k];
        if (b && typeof b === "object" && !Array.isArray(b)) out[k] = merge(b, o);
        else if (Array.isArray(b) ? Array.isArray(o) : typeof o === typeof b) out[k] = o;
    }
    return out;
}

function parseConfig(text) {
    try { return merge(DEFAULTS, JSON.parse(text)); }
    catch (e) { return merge(DEFAULTS, null); }
}

function expandHome(p, home) {
    if (p === "~") return home;
    return p.indexOf("~/") === 0 ? home + p.slice(1) : p;
}

function fmt(sec) {
    sec = Math.max(0, Math.floor(sec));
    var m = Math.floor(sec / 60), s = sec % 60;
    return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
}

function normalizeData(d) {
    var out = { projects: [], note: "" };
    if (d && typeof d.note === "string") out.note = d.note;
    if (d && Array.isArray(d.projects)) {
        d.projects.forEach(function (p) {
            if (!p || typeof p.name !== "string") return;
            var tasks = (Array.isArray(p.tasks) ? p.tasks : []).filter(function (t) {
                return t && typeof t.text === "string";
            }).map(function (t) { return { text: t.text, done: t.done === true }; });
            out.projects.push({ name: p.name, tasks: tasks });
        });
    }
    if (out.projects.length === 0) out.projects.push({ name: "Inbox", tasks: [] });
    return out;
}

var CONTRIB_QUERY = "query { viewer { login contributionsCollection { contributionCalendar { totalContributions weeks { contributionDays { contributionCount date } } } } } }";

// Returns { login, total, weeks: [[{count, date, level}]] } or throws.
function parseContributions(text) {
    var j = JSON.parse(text);
    var v = j && j.data && j.data.viewer;
    if (!v) throw new Error("unexpected response from gh");
    var cal = v.contributionsCollection.contributionCalendar;
    var max = 0;
    cal.weeks.forEach(function (w) {
        w.contributionDays.forEach(function (d) { if (d.contributionCount > max) max = d.contributionCount; });
    });
    return {
        login: v.login,
        total: cal.totalContributions,
        weeks: cal.weeks.map(function (w) {
            return w.contributionDays.map(function (d) {
                return { count: d.contributionCount, date: d.date, level: level(d.contributionCount, max) };
            });
        })
    };
}

function level(count, max) {
    if (count <= 0 || max <= 0) return 0;
    return Math.min(4, Math.ceil((count / max) * 4));
}
