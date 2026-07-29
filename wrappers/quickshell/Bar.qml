import Quickshell // for PanelWindow
import QtQuick // for Text
import QtQuick.Layouts
import Quickshell.Io

Scope {
    id: root
    readonly property string time: {
        Qt.formatDateTime(clock.date, "ddd\nMMM d \nhh:mm\nAP")
    }
    property var ipcData

    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData
            property var windowTags
            PanelWindow {
                id: mainBar
                screen: modelData
                color: "black"

                anchors {
                    top: true
                    bottom: true
                    left: true
                }

                implicitWidth: 70

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    // Text {
                    //     text: root.time
                    // }
                    // Item { Layout.fillHeight: true }
                }
            }

            PanelWindow {
                id: tagWindow
                screen: modelData
                color: "transparent"

                anchors {
                    top: true
                    left: mainBar
                }
                implicitWidth: 70
                implicitHeight: column.implicitHeight + 20

                ColumnLayout {
                    id: column
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Repeater {
                        model: {
                            if (!ipcData) return [];
                            const currentWindow = root.ipcData.find(window => window.monitor == modelData.name)
                            return currentWindow.tags.filter(tag => tag.is_active || tag.client_count > 0)
                        }

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 6

                            color: {
                                if (modelData.is_active) return "red"
                                if (modelData.is_urgent) return "purple"
                                return "gray"
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData.index
                                color: "white"
                                font.bold: parent.modelData.is_active
                            }
                
                        }
                    }
                }
            }
        }
    }
    
    SystemClock {
      id: clock
      precision: SystemClock.Minutes
    }

    Process {
        id: mangoIpc
        running: true
        command: ["mmsg", "watch", "all-tags"]
        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                const lines = text.split("\n")
                const json = JSON.parse(lines[lines.length - 2])
                root.ipcData = json.all_tags
            }
        }
    }
}
