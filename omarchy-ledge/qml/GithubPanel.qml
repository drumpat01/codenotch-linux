import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "Lib.js" as Lib

// Contribution graph via `gh api graphql` (uses the user's existing gh auth).
Item {
    id: root
    required property var cfg
    readonly property var c: cfg.colors
    property var result: null
    property string error: ""
    property bool loading: false

    function refresh() {
        if (gh.running) return;
        loading = true;
        gh.running = true;
    }
    Component.onCompleted: refresh()

    Timer {
        interval: Math.max(5, root.cfg.githubRefreshMinutes) * 60000
        running: true; repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: gh
        command: ["gh", "api", "graphql", "-f", "query=" + Lib.CONTRIB_QUERY]
        stdout: StdioCollector { id: out }
        stderr: StdioCollector { id: err }
        onExited: code => {
            root.loading = false;
            if (code !== 0) {
                root.error = (err.text || "gh failed").trim() + "\nRun `gh auth login` if you are not signed in.";
                return;
            }
            try { root.result = Lib.parseContributions(out.text); root.error = ""; }
            catch (e) { root.error = String(e); }
        }
    }

    function levelColor(l) {
        return l === 0 ? c.surface : Qt.alpha(c.accent, 0.25 + 0.75 * l / 4);
    }

    ColumnLayout {
        anchors.fill: parent
        visible: root.result !== null
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; color: c.fg; font.pixelSize: 14
                text: root.result ? root.result.total + " contributions in the last year  ·  @" + root.result.login : "" }
            Btn { label: root.loading ? "…" : "Refresh"; fg: c.fg; surface: c.surface; onClicked: root.refresh() }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Row {
                anchors.centerIn: parent
                spacing: 2
                Repeater {
                    model: root.result ? root.result.weeks : []
                    delegate: Column {
                        required property var modelData
                        spacing: 2
                        Repeater {
                            model: modelData
                            delegate: Rectangle {
                                required property var modelData
                                width: 8; height: 8; radius: 2
                                color: root.levelColor(modelData.level)
                                HoverHandler { id: hh }
                                ToolTipLabel { shown: hh.hovered; text: modelData.count + " on " + modelData.date }
                            }
                        }
                    }
                }
            }
        }
    }
    Text {
        anchors.centerIn: parent
        width: parent.width - 40
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        visible: root.result === null
        color: root.error ? "#f7768e" : c.dim
        font.pixelSize: 13
        text: root.error ? root.error : "Loading GitHub activity…"
    }
}
