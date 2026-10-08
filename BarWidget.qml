import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Agents Sleep: one bar icon that arms or cancels "suspend once all Claude
// agents are done". The work is done by ./agents-sleep, which runs the watcher
// as the transient user unit "agents-sleep"; the widget only polls its status.
BarWidget {
  id: root
  moduleName: "lonh.agents-sleep"

  readonly property string helper: String(Qt.resolvedUrl("agents-sleep")).replace(/^file:\/\//, "")
  readonly property int quietMinutes: Number(setting("quietMinutes", 5))

  property bool armed: false
  property int activeSessions: 0
  // Like the Stay Awake indicator: hidden while off, dimmed while the bar's
  // center section is hovered (the same reveal flag the built-in indicators
  // use), full color when armed. Hovering the slot itself also reveals it.
  property bool selfHovered: false
  readonly property bool hovered: selfHovered
    || (bar && bar.centerSectionRevealHeld === true && bar.centerHoverRevealSuppressed !== true)

  HoverHandler { onHoveredChanged: root.selfHovered = hovered }

  readonly property string icon: armed ? "󰒲" : "󰒳"
  readonly property string tooltip: armed
    ? "Agents Sleep armed: " + activeSessions + " session" + (activeSessions === 1 ? "" : "s") + " active, suspends after " + quietMinutes + " quiet min. Click to cancel."
    : "Agents Sleep off. Click to suspend once all Claude agents are done."

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function toggle() {
    if (actionProc.running) return
    actionProc.command = [helper, armed ? "off" : "on", "--quiet", String(quietMinutes)]
    actionProc.running = true
  }

  function applyStatus(text) {
    try {
      var status = JSON.parse(text)
      armed = status.armed === true
      activeSessions = Number(status.active) || 0
    } catch (e) {
      armed = false
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: [root.helper, "status", "--json", "--quiet", String(root.quietMinutes)]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.applyStatus(text) }
  }

  Process {
    id: actionProc
    onExited: root.refresh()
  }

  Timer { interval: 15000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    active: root.armed
    useActiveColor: false
    keepSpace: true
    dimmed: !root.armed
    concealed: !root.armed && !root.hovered
    tooltipText: root.tooltip
    onPressed: function(b) { root.toggle() }
  }
}
