import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "niistal.window-controls"

  readonly property var activeToplevel: ToplevelManager.activeToplevel
  readonly property bool hasActiveWindow: activeToplevel !== null

  implicitWidth: 32
  implicitHeight: barSize

  // Red: Close (Cerrar ventana)
  Rectangle {
    id: btnClose
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 8
    width: 13
    height: 13
    radius: 6.5
    color: closeArea.pressed ? "#BF4942" : "#FF5F56"
    border.color: "#E0443E"
    border.width: 1
    opacity: root.hasActiveWindow ? 1.0 : 0.65

    scale: closeArea.pressed ? 0.90 : (closeArea.containsMouse ? 1.15 : 1.0)
    Behavior on scale {
      NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
    }
    Behavior on opacity {
      NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Text {
      anchors.centerIn: parent
      text: "✕"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 8
      font.bold: true
      color: "#4C0000"
      opacity: closeArea.containsMouse ? 0.95 : 0.0

      Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
      }
    }

    MouseArea {
      id: closeArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: {
        if (root.bar) root.bar.showTooltip(root, "Cerrar ventana (Super+W)")
      }
      onExited: {
        if (root.bar) root.bar.hideTooltip(root)
      }
      onClicked: {
        if (root.activeToplevel) {
          root.activeToplevel.close()
        } else {
          Quickshell.execDetached(["hyprctl", "dispatch", "killactive"])
        }
      }
    }
  }
}
