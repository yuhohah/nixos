import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.cpu"

  property int cpuUsage: 0
  property real prevTotal: 0
  property real prevIdle: 0
  property string loadAvg: ""
  property string freq: ""
  property bool highLoad: cpuUsage >= 80

  function readCpu() {
    if (!statProc.running) statProc.running = true
  }

  function parseStat(raw) {
    if (!raw) return
    var lines = String(raw || "").split("\n")
    if (lines.length === 0) return
    var fields = lines[0].trim().split(/\s+/)
    if (fields[0] !== "cpu") return

    var user = parseFloat(fields[1]) || 0
    var nice = parseFloat(fields[2]) || 0
    var system = parseFloat(fields[3]) || 0
    var idle = parseFloat(fields[4]) || 0
    var iowait = parseFloat(fields[5]) || 0
    var irq = parseFloat(fields[6]) || 0
    var softirq = parseFloat(fields[7]) || 0
    var steal = parseFloat(fields[8]) || 0

    var total = user + nice + system + idle + iowait + irq + softirq + steal
    var idleAll = idle + iowait

    if (prevTotal > 0 && total > prevTotal) {
      var totalDelta = total - prevTotal
      var idleDelta = idleAll - prevIdle
      var usage = Math.round(100 * (totalDelta - idleDelta) / totalDelta)
      root.cpuUsage = Math.max(0, Math.min(100, usage))
    }

    prevTotal = total
    prevIdle = idleAll
  }

  function parseLoadAvg(raw) {
    if (!raw) return
    var parts = String(raw || "").trim().split(/\s+/)
    if (parts.length >= 3) {
      loadAvg = parts[0] + " · " + parts[1] + " · " + parts[2]
    }
  }

  function parseFreq(raw) {
    if (!raw) return
    var khz = parseFloat(String(raw || "").trim())
    if (khz > 0) {
      freq = (khz / 1000000).toFixed(1) + " GHz"
    }
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
    id: statProc
    command: ["cat", "/proc/stat"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseStat(text)
    }
  }

  Process {
    id: loadProc
    command: ["cat", "/proc/loadavg"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseLoadAvg(text)
    }
  }

  Process {
    id: freqProc
    command: ["cat", "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseFreq(text)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.readCpu()
      if (!loadProc.running) loadProc.running = true
      if (!freqProc.running) freqProc.running = true
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "cpu: " + root.cpuUsage + "%"
    active: root.highLoad
    tooltipText: "CPU: " + root.cpuUsage + "%" + (root.freq ? " @ " + root.freq : "") + (root.loadAvg ? "\nLoad: " + root.loadAvg : "") + "\nClick to open btop"
    onPressed: function(b) {
      root.launchMonitor()
    }
  }
}
