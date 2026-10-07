import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.disk-speedtest"

  property real prevReadSectors: 0
  property real prevWriteSectors: 0
  property real prevTimeMs: 0

  property real readRateMb: 0
  property real writeRateMb: 0
  readonly property real totalRateMb: readRateMb + writeRateMb
  readonly property bool activeDisk: totalRateMb >= 10.0

  function readStats() {
    if (!statProc.running) statProc.running = true
  }

  function parseDiskstats(raw) {
    if (!raw) return
    var lines = String(raw || "").split("\n")
    var totalReads = 0
    var totalWrites = 0

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line) continue
      var parts = line.split(/\s+/)
      if (parts.length < 14) continue
      var dev = parts[2]
      if (/^(nvme[0-9]+n[0-9]+|sd[a-z]|vd[a-z]|mmcblk[0-9]+)$/.test(dev)) {
        totalReads += parseFloat(parts[5]) || 0
        totalWrites += parseFloat(parts[9]) || 0
      }
    }

    var now = Date.now()
    if (prevTimeMs > 0 && now > prevTimeMs) {
      var deltaSec = (now - prevTimeMs) / 1000.0
      if (deltaSec > 0.5) {
        var deltaReadSectors = Math.max(0, totalReads - prevReadSectors)
        var deltaWriteSectors = Math.max(0, totalWrites - prevWriteSectors)
        root.readRateMb = (deltaReadSectors * 512) / (1024 * 1024 * deltaSec)
        root.writeRateMb = (deltaWriteSectors * 512) / (1024 * 1024 * deltaSec)
      }
    }

    prevReadSectors = totalReads
    prevWriteSectors = totalWrites
    prevTimeMs = now
  }

  readonly property bool isPanelOpen: root.bar && root.bar.shell && typeof root.bar.shell.isPluginOpen === "function"
    ? root.bar.shell.isPluginOpen("omarchy.disk-speedtest")
    : false

  function toggleSpeedtest() {
    if (root.bar && root.bar.shell && typeof root.bar.shell.toggle === "function") {
      root.bar.shell.toggle("omarchy.disk-speedtest", "")
    } else if (root.bar && typeof root.bar.run === "function") {
      root.bar.run("qs ipc call shell toggle omarchy.disk-speedtest \"\"")
    }
  }

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statProc
    command: ["cat", "/proc/diskstats"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseDiskstats(text)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.readStats()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.totalRateMb >= 1.0 ? ("disk: " + root.totalRateMb.toFixed(0) + "M") : "disk"
    active: root.activeDisk || root.isPanelOpen
    tooltipText: "Disk Speed Test\nRead: " + root.readRateMb.toFixed(1) + " MB/s\nWrite: " + root.writeRateMb.toFixed(1) + " MB/s\nClick to run speed test"
    onPressed: function(b) {
      root.toggleSpeedtest()
    }
  }
}
