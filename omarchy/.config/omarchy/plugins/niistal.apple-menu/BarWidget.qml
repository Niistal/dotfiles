import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "niistal.apple-menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    fontFamily: "JetBrainsMono Nerd Font"
    fontSize: 14
    horizontalMargin: 8
    tooltipText: "Apple Menu"
    onPressed: function(btn) {
      if (!root.bar) return
      if (btn === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-menu toggle root")
    }
  }
}
