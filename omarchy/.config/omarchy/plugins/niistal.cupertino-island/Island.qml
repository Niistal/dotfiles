import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool expanded: false
  property string eventIcon: "󰕾"
  property string eventText: "Ready"
  property string eventColor: "#0A84FF"

  function showEvent(eventJson) {
    try {
      var ev = typeof eventJson === "string" ? JSON.parse(eventJson) : eventJson
      if (ev.icon) root.eventIcon = ev.icon
      if (ev.text) root.eventText = ev.text
      if (ev.color) root.eventColor = ev.color
      root.expanded = true
      collapseTimer.restart()
      return "ok"
    } catch (e) {
      return "error"
    }
  }

  Timer {
    id: collapseTimer
    interval: 2800
    onTriggered: root.expanded = false
  }

  PanelWindow {
    id: islandPanel
    visible: true
    color: "transparent"
    WlrLayershell.namespace: "niistal-island"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
    }

    margins {
      top: 4
    }

    Rectangle {
      id: islandPill
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      width: root.expanded ? 240 : 20
      height: root.expanded ? 30 : 16
      radius: height / 2

      color: "#000000"
      border.color: "#33FFFFFF"
      border.width: 1

      Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutBack }
      }
      Behavior on height {
        NumberAnimation { duration: 180; easing.type: Easing.OutBack }
      }

      // Compact dot
      Rectangle {
        anchors.centerIn: parent
        width: 6
        height: 6
        radius: 3
        color: "#FFFFFF"
        opacity: root.expanded ? 0 : 0.7
        visible: !root.expanded
      }

      // Expanded content
      Row {
        anchors.centerIn: parent
        spacing: 8
        visible: root.expanded
        opacity: root.expanded ? 1.0 : 0.0

        Behavior on opacity {
          NumberAnimation { duration: 150 }
        }

        Text {
          text: root.eventIcon
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 13
          color: root.eventColor
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          text: root.eventText
          font.family: Style.font.family
          font.pixelSize: 11
          font.bold: true
          color: "#FFFFFF"
          anchors.verticalCenter: parent.verticalCenter
          elide: Text.ElideRight
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (!root.expanded) {
            root.showEvent({ icon: "", text: "Niistal Cupertino", color: "#0A84FF" })
          } else {
            root.expanded = false
          }
        }
      }
    }
  }
}
