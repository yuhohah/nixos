import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.memory"

  property int memUsage: 0
  property real totalGb: 0
  property real usedGb: 0
  property real freeGb: 0
  property real availGb: 0
  property real swapTotalGb: 0
  property real swapUsedGb: 0
  property bool showAbsolute: false
  property bool highUsage: memUsage >= 85

  function readMem() {
    if (!memProc.running) memProc.running = true
  }

  function parseMeminfo(raw) {
    if (!raw) return
    var lines = String(raw || "").split("\n")
    var totalKb = 0
    var freeKb = 0
    var availKb = 0
    var swapTotalKb = 0
    var swapFreeKb = 0

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (line.indexOf("MemTotal:") === 0) totalKb = parseKb(line)
      else if (line.indexOf("MemFree:") === 0) freeKb = parseKb(line)
      else if (line.indexOf("MemAvailable:") === 0) availKb = parseKb(line)
      else if (line.indexOf("SwapTotal:") === 0) swapTotalKb = parseKb(line)
      else if (line.indexOf("SwapFree:") === 0) swapFreeKb = parseKb(line)
    }

    if (totalKb > 0) {
      var usedKb = totalKb - (availKb > 0 ? availKb : freeKb)
      root.totalGb = Math.round(totalKb / 1024 / 102.4) / 10
      root.usedGb = Math.round(usedKb / 1024 / 102.4) / 10
      root.freeGb = Math.round(freeKb / 1024 / 102.4) / 10
      root.availGb = Math.round(availKb / 1024 / 102.4) / 10
      root.memUsage = Math.round((usedKb / totalKb) * 100)

      root.swapTotalGb = Math.round(swapTotalKb / 1024 / 102.4) / 10
      var swapUsedKb = swapTotalKb - swapFreeKb
      root.swapUsedGb = Math.round(swapUsedKb / 1024 / 102.4) / 10
    }
  }

  function parseKb(line) {
    var parts = line.split(/\s+/)
    return parts.length >= 2 ? (parseInt(parts[1], 10) || 0) : 0
  }

  function launchMonitor() {
    if (root.bar) {
      root.bar.run("omarchy-launch-floating-terminal-with-presentation btop")
    }
  }

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: memProc
    command: ["cat", "/proc/meminfo"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseMeminfo(text)
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.readMem()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.showAbsolute
      ? ("mem: " + root.memUsage + "%")
      : ("mem: " + root.usedGb.toFixed(1) + "G")
    active: root.highUsage
    tooltipText: "RAM: " + root.usedGb.toFixed(1) + " GB / " + root.totalGb.toFixed(1) + " GB (" + root.memUsage + "%)\n"
      + "Available: " + root.availGb.toFixed(1) + " GB\n"
      + (root.swapTotalGb > 0 ? "Swap: " + root.swapUsedGb.toFixed(1) + " GB / " + root.swapTotalGb.toFixed(1) + " GB\n" : "")
      + "Click to toggle format · Right-click for btop"
    onPressed: function(b) {
      if (b === Qt.RightButton || b === Qt.MiddleButton) {
        root.launchMonitor()
      } else {
        root.showAbsolute = !root.showAbsolute
      }
    }
  }
}
