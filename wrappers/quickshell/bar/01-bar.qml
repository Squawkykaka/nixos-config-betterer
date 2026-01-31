import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: "#1a1b26"

    Text {
        anchors.centerIn: parent
        text: "My First Bar"
        color: "#a9b1d6"
        font.pixelSize: 14
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 8

        property var desktops: [];

        Process {
            id: desktopProc
            command: ['sh', '-c', "bspc query -D --names"]
                        running: true

                                    stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    let temp = layout.desktops.slice()
                    temp.push(data)
                    layout.desktops = temp
                }
            }
        }

        Repeater {
            model: layout.desktops

            Text {
                text: modelData
                color: "#a9b1d6"
                font.pixelSize: 12
            }
        }

        Item { Layout.fillWidth: true }

Text {
    id: clock
    text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    font.pixelSize: 14

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }
}
    }
}
