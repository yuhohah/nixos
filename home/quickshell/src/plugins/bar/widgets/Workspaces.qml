import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces ? Hyprland.workspaces.values : []
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function hasWindows(id) {
    var ws = workspaceById(id)
    return ws !== null && (ws.windows === undefined || ws.windows > 0)
  }

  function workspaceIds() {
    var maxId = 4
    if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > maxId) {
      maxId = Hyprland.focusedWorkspace.id
    }
    var values = Hyprland.workspaces ? Hyprland.workspaces.values : []
    for (var i = 0; i < values.length; i++) {
      var ws = values[i]
      if (ws && ws.id > maxId && (ws.windows === undefined || ws.windows > 0)) {
        maxId = ws.id
      }
    }
    var ids = []
    for (var j = 1; j <= maxId; j++) {
      ids.push(j)
    }
    return ids
  }

  function focusWorkspace(id) {
    if (typeof Hyprland !== "undefined" && Hyprland.dispatch) {
      Hyprland.dispatch("workspace", String(id))
    } else if (root.bar) {
      root.bar.run("hyprctl dispatch workspace " + id)
    }
  }

  implicitWidth: wsRow.implicitWidth + 16
  implicitHeight: root.barSize

  Row {
    id: wsRow
    anchors.centerIn: parent
    spacing: 4

    Repeater {
      model: root.workspaceIds()

      Rectangle {
        id: wsBtn
        required property int modelData
        property int wsId: modelData
        property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
        property bool hasContent: root.hasWindows(wsId)

        implicitWidth: isActive ? 28 : 22
        implicitHeight: 24
        radius: 7
        color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? (hasContent ? "#45475a" : "#313244") : "transparent")
        border.color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? (hasContent ? "#45475a" : "#313244") : "transparent")
        border.width: 1
        opacity: isActive || hasContent ? 1.0 : (wsMouse.containsMouse ? 0.85 : 0.45)

        Behavior on implicitWidth {
          NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
        Behavior on color {
          ColorAnimation { duration: 150 }
        }
        Behavior on opacity {
          NumberAnimation { duration: 150 }
        }

        Text {
          anchors.centerIn: parent
          text: String(wsBtn.wsId)
          color: wsBtn.isActive ? "#11111b" : (wsBtn.hasContent ? "#cdd6f4" : "#6c7086")
          font.family: root.fontFamily || "JetBrainsMono Nerd Font"
          font.pixelSize: 12
          font.bold: wsBtn.isActive || wsBtn.hasContent
        }

        MouseArea {
          id: wsMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.focusWorkspace(wsBtn.wsId)
        }
      }
    }
  }
}
