import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "niistal.search-button"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍉"
    fontFamily: "JetBrainsMono Nerd Font"
    horizontalMargin: 6.5
    onPressed: function(btn) {
      if (!root.bar) return
      root.bar.run("omarchy-menu toggle root")
    }
  }
}
