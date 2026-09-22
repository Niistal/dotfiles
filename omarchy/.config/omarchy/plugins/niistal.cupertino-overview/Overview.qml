import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool opened: false
  property string mode: "mission-control" // "mission-control" or "app-expose"
  property var clientWindows: []
  property var activeWindowData: null
  property int activeWorkspaceId: 1

  readonly property var spacesList: [
    { id: 1, name: "1 DEV" },
    { id: 2, name: "2 WEB" },
    { id: 3, name: "3 AI" },
    { id: 4, name: "4 OPS" },
    { id: 5, name: "5 SEC" },
    { id: 6, name: "6 DATA" },
    { id: 7, name: "7 MEDIA" },
    { id: 8, name: "8 CHAT" },
    { id: 9, name: "9 LAB" }
  ]

  function openMissionControl() {
    root.mode = "mission-control"
    root.fetchClients()
    root.opened = true
  }

  function openAppExpose() {
    root.mode = "app-expose"
    root.fetchClients()
    root.opened = true
  }

  function toggleMissionControl() {
    if (root.opened && root.mode === "mission-control") root.opened = false
    else root.openMissionControl()
  }

  function toggleAppExpose() {
    if (root.opened && root.mode === "app-expose") root.opened = false
    else root.openAppExpose()
  }

  function fetchClients() {
    clientsProc.running = true
  }

  function focusClient(address) {
    root.opened = false
    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch focuswindow address:" + address])
  }

  function switchWorkspace(id) {
    root.opened = false
    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch workspace " + id])
  }

  Process {
    id: clientsProc
    command: ["bash", "-c", "hyprctl clients -j; echo '---'; hyprctl activewindow -j; echo '---'; hyprctl activeworkspace -j"]
    stdout: StdioCollector {
      onDataChanged: {
        var sections = text.trim().split("---")
        if (sections.length >= 3) {
          try {
            var rawClients = JSON.parse(sections[0].trim())
            var activeWin = JSON.parse(sections[1].trim() || "{}")
            var activeWs = JSON.parse(sections[2].trim() || "{}")

            root.activeWindowData = activeWin
            root.activeWorkspaceId = activeWs.id || 1

            if (root.mode === "app-expose" && activeWin.class) {
              root.clientWindows = rawClients.filter(function(c) {
                return c.class === activeWin.class
              })
            } else {
              root.clientWindows = rawClients
            }
          } catch (e) {
            console.warn("Overview parse error:", e)
          }
        }
      }
    }
  }

  PanelWindow {
    id: overviewPanel
    visible: root.opened
    color: "transparent"
    WlrLayershell.namespace: "niistal-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // Scrim Darkening Background
    Rectangle {
      anchors.fill: parent
      color: Color.mode === "light" ? "rgba(240, 240, 245, 0.70)" : "rgba(10, 10, 12, 0.75)"

      MouseArea {
        anchors.fill: parent
        onClicked: root.opened = false
      }
    }

    Item {
      anchors.fill: parent
      focus: true

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
          root.opened = false
          event.accepted = true
        } else if (event.key === Qt.Key_Up && (event.modifiers & Qt.MetaModifier)) {
          root.toggleMissionControl()
          event.accepted = true
        } else if (event.key === Qt.Key_Down && (event.modifiers & Qt.MetaModifier)) {
          root.toggleAppExpose()
          event.accepted = true
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: 24
        anchors.bottomMargin: 24
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        spacing: 20

        // Title & Mode Indicator
        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 12

          Text {
            text: root.mode === "mission-control" ? "Mission Control" : ("App Exposé — " + ((root.activeWindowData && root.activeWindowData.class) || "App"))
            font.family: Style.font.family
            font.pixelSize: 18
            font.bold: true
            color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
          }
        }

        // Spaces bar at top (Mission Control)
        Rectangle {
          visible: root.mode === "mission-control"
          width: Math.min(parent.width, spacesRow.implicitWidth + 24)
          height: 48
          radius: 14
          anchors.horizontalCenter: parent.horizontalCenter
          color: Color.mode === "light" ? "rgba(255, 255, 255, 0.85)" : "rgba(35, 35, 38, 0.85)"
          border.color: Color.mode === "light" ? "rgba(0, 0, 0, 0.1)" : "rgba(255, 255, 255, 0.15)"
          border.width: 1

          Row {
            id: spacesRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
              model: root.spacesList

              delegate: Rectangle {
                required property int index
                required property var modelData

                width: spaceLabel.implicitWidth + 16
                height: 32
                radius: 8
                color: root.activeWorkspaceId === modelData.id ? (Color.mode === "light" ? "#007AFF" : "#0A84FF") : "transparent"

                Text {
                  id: spaceLabel
                  anchors.centerIn: parent
                  text: modelData.name
                  font.family: Style.font.family
                  font.pixelSize: 11
                  font.bold: root.activeWorkspaceId === modelData.id
                  color: root.activeWorkspaceId === modelData.id ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7")
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.switchWorkspace(modelData.id)
                }
              }
            }
          }
        }

        // Windows Grid
        ScrollView {
          width: parent.width
          height: parent.height - 110
          clip: true

          Grid {
            id: winGrid
            columns: Math.max(1, Math.floor(parent.width / 320))
            spacing: 18
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
              model: root.clientWindows

              delegate: Rectangle {
                required property int index
                required property var modelData

                width: 290
                height: 180
                radius: 14
                color: Color.mode === "light" ? "rgba(255, 255, 255, 0.90)" : "rgba(28, 28, 30, 0.88)"
                border.color: Color.mode === "light" ? "rgba(0, 0, 0, 0.12)" : "rgba(255, 255, 255, 0.16)"
                border.width: 1

                Column {
                  anchors.fill: parent
                  anchors.margins: 14
                  spacing: 8

                  Row {
                    width: parent.width
                    spacing: 8

                    Image {
                      width: 20
                      height: 20
                      source: Quickshell.iconPath(modelData.class || "application-x-executable", true)
                    }

                    Text {
                      width: parent.width - 70
                      text: modelData.class || "Window"
                      font.bold: true
                      font.pixelSize: 12
                      color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
                      elide: Text.ElideRight
                    }

                    Rectangle {
                      width: 32
                      height: 18
                      radius: 9
                      color: Color.mode === "light" ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.12)"
                      Text {
                        anchors.centerIn: parent
                        text: (modelData.workspace && modelData.workspace.name) || "1"
                        font.pixelSize: 10
                        color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
                      }
                    }
                  }

                  Rectangle {
                    width: parent.width
                    height: 100
                    radius: 8
                    color: Color.mode === "light" ? "rgba(0,0,0,0.04)" : "rgba(255,255,255,0.05)"
                    border.color: Color.mode === "light" ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.08)"
                    border.width: 1

                    Text {
                      anchors.centerIn: parent
                      width: parent.width - 20
                      text: modelData.title || ""
                      font.pixelSize: 11
                      opacity: 0.7
                      wrapMode: Text.Wrap
                      maximumLineCount: 3
                      horizontalAlignment: Text.AlignHCenter
                      color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
                    }
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  hoverEnabled: true
                  onEntered: parent.scale = 1.03
                  onExited: parent.scale = 1.0
                  onClicked: root.focusClient(modelData.address)
                }

                Behavior on scale {
                  NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
              }
            }
          }
        }
      }
    }
  }
}
