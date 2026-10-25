import QtQuick
import Quickshell.Io
import "Lib.js" as Lib

// Focus / Short / Long timer shared by the card and the floating pop-out.
QtObject {
    id: t
    required property var app
    property string mode: "focus"              // focus | short | long
    property bool running: false
    property bool started: false               // false = READY
    property int session: 1
    property double endsAt: 0

    readonly property var lengths: ({
        focus: Math.round(app.cfg.focusMin * 60),
        short: Math.round(app.cfg.shortMin * 60),
        long: Math.round(app.cfg.longMin * 60)
    })
    readonly property int total: lengths[mode]
    property int remaining: total
    readonly property real progress: total > 0 ? 1 - remaining / total : 0
    readonly property string timeText: Lib.fmt(remaining)
    readonly property string stateText: running ? (mode === "focus" ? "FOCUS" : "BREAK") : (started && remaining < total ? "PAUSED" : "READY")

    onTotalChanged: if (!running && !started) remaining = total

    function start() {
        if (remaining <= 0) remaining = total;
        endsAt = Date.now() + remaining * 1000;
        started = true;
        running = true;
    }
    function pause() { tick(); running = false; }
    function toggle() { running ? pause() : start(); }
    function reset() { running = false; started = false; remaining = total; }
    function setMode(m) { running = false; started = false; mode = m; remaining = lengths[m]; }
    function tick() { remaining = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000)); }

    function finish() {
        running = false;
        started = false;
        var wasFocus = mode === "focus";
        notifier.command = ["notify-send", "-a", "BuildNotch", "-u", "normal",
            wasFocus ? "Focus session finished" : "Break is over",
            wasFocus ? "Time for a break." : "Ready for the next session?"];
        notifier.running = true;
        app.pushNotice(wasFocus ? "Focus session " + session + " finished" : "Break finished");
        if (wasFocus) {
            var next = session % 4 === 0 ? "long" : "short";
            session += 1;
            mode = next;
        } else mode = "focus";
        remaining = lengths[mode];
    }

    property Timer ticker: Timer {
        interval: 250; repeat: true; running: t.running
        onTriggered: { t.tick(); if (t.remaining <= 0) t.finish(); }
    }
    property Process notifier: Process {}
}
