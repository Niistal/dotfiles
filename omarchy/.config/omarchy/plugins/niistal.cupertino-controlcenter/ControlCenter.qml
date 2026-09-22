import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property bool opened: false
  property var shell: null
  property var manifest: null

  function toggle() { root.opened = !root.opened }
  function open() { root.opened = true }
  function close() { root.opened = false }

  // State
  property string wifiSsid: "Connected"
  property bool wifiEnabled: true
  property bool btEnabled: true
  property bool vpnEnabled: false
  property bool nightlightEnabled: false

  property int volume: 65
  property int brightness: 80

  // DevSecOps stats
  property string dockerCount: "0 running"
  property string tailscaleIp: "Disconnected"
  property string sshSessions: "0 active"
  property string cpuUsage: "5%"
  property string ramUsage: "28%"
  property string gpuUsage: "3%"

  Timer {
    interval: 3000
    running: root.opened
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      metricsProc.running = true
    }
  }

  Process {
    id: metricsProc
    command: ["bash", "-c", "echo \"$(docker ps -q 2>/dev/null | wc -l) containers|$(tailscale ip -4 2>/dev/null || echo 'Inactive')|$(who | wc -l) users|$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')%|$(free | grep Mem | awk '{printf(\\\"%.0f%%\\\", $3/$2*100)}')|$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo '0')%\""]
    stdout: StdioCollector {
      onDataChanged: {
        var parts = text.trim().split("|")
        if (parts.length >= 6) {
          root.dockerCount = parts[0]
          root.tailscaleIp = parts[1]
          root.sshSessions = parts[2]
          root.cpuUsage = parts[3]
          root.ramUsage = parts[4]
          root.gpuUsage = parts[5]
        }
      }
    }
  }

  PanelWindow {
    id: ccPanel
    visible: root.opened
    color: "transparent"
    WlrLayershell.namespace: "niistal-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      right: true
      bottom: true
      left: true
    }

    // Dismiss overlay
    MouseArea {
      anchors.fill: parent
      onClicked: root.opened = false
    }

    // Control Center Box
    Rectangle {
      id: card
      width: 320
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: 34
      anchors.rightMargin: 12
      height: contentCol.implicitHeight + 28
      radius: 18

      color: Color.mode === "light" ? "rgba(245, 245, 247, 0.90)" : "rgba(28, 28, 30, 0.88)"
      border.color: Color.mode === "light" ? "rgba(0, 0, 0, 0.12)" : "rgba(255, 255, 255, 0.16)"
      border.width: 1

      MouseArea {
        anchors.fill: parent
        // Prevent dismissal on inside clicks
      }

      Column {
        id: contentCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 14
        spacing: 12

        // Top Toggles Grid (2x2)
        Grid {
          columns: 2
          spacing: 8
          width: parent.width

          // Wi-Fi
          Rectangle {
            width: (parent.width - 8) / 2
            height: 48
            radius: 12
            color: root.wifiEnabled ? (Color.mode === "light" ? "#007AFF" : "#0A84FF") : (Color.mode === "light" ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.08)")

            Row {
              anchors.centerIn: parent
              spacing: 8
              Text {
                text: "󰤨"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: root.wifiEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7")
                anchors.verticalCenter: parent.verticalCenter
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: "Wi-Fi"; font.bold: true; font.pixelSize: 12; color: root.wifiEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
                Text { text: root.wifiEnabled ? "On" : "Off"; font.pixelSize: 10; opacity: 0.8; color: root.wifiEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
              }
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.wifiEnabled = !root.wifiEnabled
            }
          }

          // Bluetooth
          Rectangle {
            width: (parent.width - 8) / 2
            height: 48
            radius: 12
            color: root.btEnabled ? (Color.mode === "light" ? "#007AFF" : "#0A84FF") : (Color.mode === "light" ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.08)")

            Row {
              anchors.centerIn: parent
              spacing: 8
              Text {
                text: "󰂯"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: root.btEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7")
                anchors.verticalCenter: parent.verticalCenter
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: "Bluetooth"; font.bold: true; font.pixelSize: 12; color: root.btEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
                Text { text: root.btEnabled ? "On" : "Off"; font.pixelSize: 10; opacity: 0.8; color: root.btEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
              }
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.btEnabled = !root.btEnabled
            }
          }

          // Tailscale / VPN
          Rectangle {
            width: (parent.width - 8) / 2
            height: 48
            radius: 12
            color: root.vpnEnabled ? (Color.mode === "light" ? "#34C759" : "#30D158") : (Color.mode === "light" ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.08)")

            Row {
              anchors.centerIn: parent
              spacing: 8
              Text {
                text: "󰖂"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: root.vpnEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7")
                anchors.verticalCenter: parent.verticalCenter
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: "Tailscale"; font.bold: true; font.pixelSize: 12; color: root.vpnEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
                Text { text: root.vpnEnabled ? "Connected" : "Off"; font.pixelSize: 10; opacity: 0.8; color: root.vpnEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
              }
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.vpnEnabled = !root.vpnEnabled
                Quickshell.execDetached(["bash", "-c", "omarchy-toggle-tailscale || true"])
              }
            }
          }

          // Night Light
          Rectangle {
            width: (parent.width - 8) / 2
            height: 48
            radius: 12
            color: root.nightlightEnabled ? (Color.mode === "light" ? "#FF9500" : "#FF9F0A") : (Color.mode === "light" ? "rgba(0,0,0,0.06)" : "rgba(255,255,255,0.08)")

            Row {
              anchors.centerIn: parent
              spacing: 8
              Text {
                text: "󰖔"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: root.nightlightEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7")
                anchors.verticalCenter: parent.verticalCenter
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text { text: "Night Light"; font.bold: true; font.pixelSize: 12; color: root.nightlightEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
                Text { text: root.nightlightEnabled ? "Active" : "Off"; font.pixelSize: 10; opacity: 0.8; color: root.nightlightEnabled ? "#FFFFFF" : (Color.mode === "light" ? "#1D1D1F" : "#F5F5F7") }
              }
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.nightlightEnabled = !root.nightlightEnabled
                Quickshell.execDetached(["bash", "-c", "omarchy toggle nightlight || true"])
              }
            }
          }
        }

        // Display Brightness Slider Card
        Rectangle {
          width: parent.width
          height: 44
          radius: 12
          color: Color.mode === "light" ? "rgba(0,0,0,0.04)" : "rgba(255,255,255,0.06)"

          Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
              text: "󰃠"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 16
              anchors.verticalCenter: parent.verticalCenter
              color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
            }

            Rectangle {
              height: 18
              width: parent.width - 40
              radius: 9
              anchors.verticalCenter: parent.verticalCenter
              color: Color.mode === "light" ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.12)"

              Rectangle {
                height: parent.height
                width: parent.width * (root.brightness / 100)
                radius: 9
                color: Color.mode === "light" ? "#007AFF" : "#0A84FF"
              }
            }
          }
        }

        // Sound Volume Slider Card
        Rectangle {
          width: parent.width
          height: 44
          radius: 12
          color: Color.mode === "light" ? "rgba(0,0,0,0.04)" : "rgba(255,255,255,0.06)"

          Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
              text: "󰕾"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 16
              anchors.verticalCenter: parent.verticalCenter
              color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7"
            }

            Rectangle {
              height: 18
              width: parent.width - 40
              radius: 9
              anchors.verticalCenter: parent.verticalCenter
              color: Color.mode === "light" ? "rgba(0,0,0,0.08)" : "rgba(255,255,255,0.12)"

              Rectangle {
                height: parent.height
                width: parent.width * (root.volume / 100)
                radius: 9
                color: Color.mode === "light" ? "#007AFF" : "#0A84FF"
              }
            }
          }
        }

        // DevSecOps Telemetry Card
        Rectangle {
          width: parent.width
          height: devsecopsCol.implicitHeight + 18
          radius: 12
          color: Color.mode === "light" ? "rgba(0,0,0,0.04)" : "rgba(255,255,255,0.06)"

          Column {
            id: devsecopsCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 6

            Text {
              text: "DevSecOps & Telemetry"
              font.bold: true
              font.pixelSize: 11
              color: Color.mode === "light" ? "#86868B" : "#86868B"
            }

            Row {
              spacing: 12
              Text { text: "󰡨 Docker: " + root.dockerCount; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7" }
              Text { text: "󰖂 Tailscale: " + root.tailscaleIp; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7" }
            }

            Row {
              spacing: 12
              Text { text: "󰻠 CPU: " + root.cpuUsage; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7" }
              Text { text: "󰍛 RAM: " + root.ramUsage; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7" }
              Text { text: "󰢮 GPU: " + root.gpuUsage; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; color: Color.mode === "light" ? "#1D1D1F" : "#F5F5F7" }
            }
          }
        }
      }
    }
  }
}
