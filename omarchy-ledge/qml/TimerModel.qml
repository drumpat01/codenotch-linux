import QtQuick
import Quickshell.Io

QtObject {
    id: t
    property int lengthSec: 25 * 60
    property int remaining: lengthSec
    property bool running: false
    property double endsAt: 0

    function start() {
        if (remaining <= 0) remaining = lengthSec;
        endsAt = Date.now() + remaining * 1000;
        running = true;
    }
    function pause() { tick(); running = false; }
    function reset() { running = false; remaining = lengthSec; }
    function setMinutes(m) {
        if (!(m > 0)) return;
        lengthSec = Math.round(m * 60);
        if (!running) remaining = lengthSec;
    }
    function tick() { remaining = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000)); }

    property Timer ticker: Timer {
        interval: 250
        repeat: true
        running: t.running
        onTriggered: {
            t.tick();
            if (t.remaining <= 0) {
                t.running = false;
                t.notifier.command = ["notify-send", "-a", "Ledge", "-u", "normal", "Focus session finished", "Time for a break."];
                t.notifier.running = true;
            }
        }
    }
    property Process notifier: Process {}
}
