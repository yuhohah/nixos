import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
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

        implicitWidth: isActive ? 26 : 20
        implicitHeight: 20
        radius: 6
        color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? "#45475a" : "transparent")
        border.color: isActive ? "#cba6f7" : (wsMouse.containsMouse ? "#45475a" : "transparent")
        border.width: 1

        Behavior on implicitWidth {
          NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
        Behavior on color {
          ColorAnimation { duration: 150 }
        }

        Text {
          anchors.centerIn: parent
          text: String(wsBtn.wsId)
          color: wsBtn.isActive ? "#11111b" : "#cdd6f4"
          font.family: root.fontFamily || "JetBrainsMono Nerd Font"
          font.pixelSize: 11
          font.bold: wsBtn.isActive
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
