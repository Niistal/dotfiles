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
  property int hoveredIndex: -1

  readonly property var pinnedApps: [
    { name: "Finder", icon: "system-file-manager", fallbackIcon: "", exec: "uwsm-app -- nautilus", match: "nautilus" },
    { name: "Browser", icon: "chromium", fallbackIcon: "󰖟", exec: "omarchy-launch-browser", match: "chromium" },
    { name: "Terminal", icon: "utilities-terminal", fallbackIcon: "", exec: "xdg-terminal-exec", match: "foot" },
    { name: "Code", icon: "code", fallbackIcon: "", exec: "omarchy-launch-editor", match: "code|nvim" },
    { name: "Git", icon: "git", fallbackIcon: "", exec: "omarchy-launch-or-focus-tui lazygit", match: "lazygit" },
    { name: "ChatGPT", icon: "chatgpt", fallbackIcon: "󰚩", exec: "omarchy-launch-webapp 'https://chatgpt.com'", match: "chatgpt" },
    { name: "Docker", icon: "docker", fallbackIcon: "󰡨", exec: "omarchy-menu summon setup.docker", match: "docker" },
    { name: "Settings", icon: "preferences-system", fallbackIcon: "󰒓", exec: "omarchy-menu toggle root", match: "settings" }
  ]

  function isRunning(matchPattern) {
    if (!matchPattern) return false
    var toplevels = []
    try { toplevels = ToplevelManager.toplevels.values || [] } catch (e) { return false }
    var pat = new RegExp(matchPattern, "i")
    for (var i = 0; i < toplevels.length; i++) {
      var tl = toplevels[i]
      if (tl && ((tl.appId && pat.test(tl.appId)) || (tl.title && pat.test(tl.title)))) return true
    }
    return false
  }

  function activateApp(matchPattern, execCmd) {
    var toplevels = []
    try { toplevels = ToplevelManager.toplevels.values || [] } catch (e) { }
    if (matchPattern && toplevels.length > 0) {
      var pat = new RegExp(matchPattern, "i")
      for (var i = 0; i < toplevels.length; i++) {
        var tl = toplevels[i]
        if (tl && ((tl.appId && pat.test(tl.appId)) || (tl.title && pat.test(tl.title)))) {
          tl.activate()
          return
        }
      }
    }
    Quickshell.execDetached(["bash", "-c", execCmd])
  }

  PanelWindow {
    id: dockPanel
    visible: true
    color: "transparent"
    WlrLayershell.namespace: "niistal-dock"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Auto

    anchors {
      bottom: true
    }

    margins {
      bottom: 8
    }

    // Dock Card
    Rectangle {
      id: dockBg
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      height: 56
      width: dockRow.implicitWidth + 24
      radius: 18

      // Glass style
      color: Color.mode === "light" ? "rgba(255, 255, 255, 0.78)" : "rgba(28, 28, 30, 0.78)"
      border.color: Color.mode === "light" ? "rgba(0, 0, 0, 0.12)" : "rgba(255, 255, 255, 0.16)"
      border.width: 1

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: root.hoveredIndex = -1
      }

      Row {
        id: dockRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
          model: root.pinnedApps

          delegate: Item {
            id: appItem
            required property int index
            required property var modelData

            readonly property int dist: root.hoveredIndex >= 0 ? Math.abs(root.hoveredIndex - index) : 99
            readonly property real targetSize: dist === 0 ? 50 : (dist === 1 ? 42 : (dist === 2 ? 37 : 34))

            implicitWidth: targetSize
            implicitHeight: 46

            Behavior on implicitWidth {
              NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Rectangle {
              id: iconContainer
              width: appItem.targetSize
              height: appItem.targetSize
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottom: indicator.top
              anchors.bottomMargin: 2
              color: "transparent"

              Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
              }
              Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
              }

              Image {
                id: appIcon
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: Quickshell.iconPath(appItem.modelData.icon, true)
                visible: source != "" && status === Image.Ready
              }

              Text {
                id: fallbackGlyph
                anchors.centerIn: parent
                visible: !appIcon.visible
                text: appItem.modelData.fallbackIcon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: parent.width * 0.58
                color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
              }
            }

            // Running indicator dot
            Rectangle {
              id: indicator
              width: 4
              height: 4
              radius: 2
              anchors.bottom: parent.bottom
              anchors.bottomMargin: 1
              anchors.horizontalCenter: parent.horizontalCenter
              color: Color.mode === "light" ? "#1D1D1F" : "#FFFFFF"
              opacity: root.isRunning(appItem.modelData.match) ? 0.85 : 0.0

              Behavior on opacity {
                NumberAnimation { duration: 200 }
              }
            }

            // Tooltip
            Rectangle {
              id: tooltip
              visible: root.hoveredIndex === appItem.index
              anchors.bottom: iconContainer.top
              anchors.bottomMargin: 8
              anchors.horizontalCenter: parent.horizontalCenter
              height: 22
              width: tooltipText.implicitWidth + 14
              radius: 6
              color: Color.mode === "light" ? "rgba(240, 240, 245, 0.95)" : "rgba(35, 35, 38, 0.95)"
              border.color: Color.mode === "light" ? "rgba(0, 0, 0, 0.1)" : "rgba(255, 255, 255, 0.15)"
              border.width: 1
              z: 100

              Text {
                id: tooltipText
                anchors.centerIn: parent
                text: appItem.modelData.name
                font.family: Style.font.family
                font.pixelSize: 11
                color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: root.hoveredIndex = appItem.index
              onClicked: root.activateApp(appItem.modelData.match, appItem.modelData.exec)
            }
          }
        }
      }
    }
  }
}
