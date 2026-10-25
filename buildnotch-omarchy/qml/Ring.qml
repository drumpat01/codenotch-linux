import QtQuick

// Progress ring, from 12 o'clock clockwise. `dots` draws it as a circle of dots instead of a stroke.
Canvas {
    id: r
    property real progress: 0
    property color track: Qt.rgba(1, 1, 1, 0.12)
    property color fill: "#ffffff"
    property real stroke: 5
    property bool dots: false
    property bool knob: false
    property color knobColor: fill
    onProgressChanged: requestPaint()
    onTrackChanged: requestPaint()
    onFillChanged: requestPaint()
    onWidthChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        var cx = width / 2, cy = height / 2, rad = Math.min(width, height) / 2 - stroke;
        var top = -Math.PI / 2;
        if (dots) {
            var n = 60;
            for (var i = 0; i < n; i++) {
                var a = top + i / n * 2 * Math.PI;
                ctx.fillStyle = (i / n < progress) ? fill : track;
                ctx.beginPath();
                ctx.arc(cx + Math.cos(a) * rad, cy + Math.sin(a) * rad, stroke * 0.4, 0, 2 * Math.PI);
                ctx.fill();
            }
            return;
        }
        ctx.lineWidth = stroke; ctx.lineCap = "round";
        ctx.strokeStyle = track;
        ctx.beginPath(); ctx.arc(cx, cy, rad, 0, 2 * Math.PI); ctx.stroke();
        if (progress > 0.001) {
            ctx.strokeStyle = fill;
            ctx.beginPath(); ctx.arc(cx, cy, rad, top, top + progress * 2 * Math.PI); ctx.stroke();
        }
        if (knob) {
            var ka = top + progress * 2 * Math.PI;
            ctx.fillStyle = knobColor;
            ctx.beginPath(); ctx.arc(cx + Math.cos(ka) * rad, cy + Math.sin(ka) * rad, stroke * 0.9, 0, 2 * Math.PI); ctx.fill();
        }
    }
}
