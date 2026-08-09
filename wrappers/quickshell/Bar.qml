import Quickshell // for PanelWindow
import QtQuick // for Text
import QtQuick.Layouts
import Quickshell.Io

Scope {
    id: root
    readonly property string fontFamily: "FiraCode Nerd Font"
    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    Variants {
        model: Quickshell.screens

        Item {
            required property var modelData
            property var windowTags
            PanelWindow {
                id: mainBar
                screen: modelData

                color: Colors.base3

                anchors {
                    top: true
                    bottom: true
                    left: true
                }

                implicitWidth: 80

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    Repeater {
                        model: Niri.workspaces.filter(el => el.output == mainBar.screen.name) //TODO

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 6

                            color: {
                                if (modelData.is_focused)
                                    return Colors.base1;
                                if (modelData.is_urgent)
                                    return Colors.purple;
                                return Colors.base2;
                            }

                            Text {
                                font.family: root.fontFamily
                                anchors.centerIn: parent
                                text: parent.modelData.idx
                                color: Colors.base03
                                font.bold: parent.modelData.is_active
                            }
                        }
                    }
                    Seperator {}
                    Repeater {
                        model: Niri.windows.filter(el => el.workspace_id == Niri.workspaces.find(el => el.is_focused).id)

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32

                            Text {
                                text: modelData.title
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                    // CPU
                    ColumnLayout {
                        visible: false
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: "\uf4bc"
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 30
                        }
                        Text {
                            text: "N/A"
                            font.pixelSize: 15
                        }
                    }
                    Seperator {}
                    // battery
                    RowLayout {
                        visible: batteryStatusFile.exists
                        Text {
                            readonly property string batteryStatus: batteryStatusFile.text().trim()
                            font.family: root.fontFamily
                            font.pixelSize: 20
                            text: {
                                if (batteryStatus == "Discharging") {
                                    let fillLevel = batteryFile.text().trim();
                                    if (fillLevel < 10)
                                        return "\udb80\udc8e";
                                    if (fillLevel < 20)
                                        return "\udb80\udc7a";
                                    if (fillLevel < 30)
                                        return "\udb80\udc7b";
                                    if (fillLevel < 40)
                                        return "\udb80\udc7c";
                                    if (fillLevel < 50)
                                        return "\udb80\udc7d";
                                    if (fillLevel < 60)
                                        return "\udb80\udc7e";
                                    if (fillLevel < 70)
                                        return "\udb80\udc7f";
                                    if (fillLevel < 80)
                                        return "\udb80\udc80";
                                    if (fillLevel < 90)
                                        return "\udb80\udc81";
                                    if (fillLevel < 95)
                                        return "\udb80\udc82";
                                    if (fillLevel <= 100)
                                        return "\udb80\udc79";
                                }
                                if (batteryStatus == "Charging")
                                    return "\udb80\udc84";
                                if (batteryStatus == "Not charging")
                                    return "\udb80\udc83";
                                if (batteryStatus == "Full")
                                    return "\udb80\udc79";
                                return "N/A";
                            }
                            color: {
                                if (batteryStatus == "Discharging")
                                    return Colors.red;
                                if (batteryStatus == "Charging")
                                    return Colors.green;
                                if (batteryStatus == "Not charging")
                                    return Colors.orange;
                                return Colors.base03;
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignRight
                            Text {
                                // turn into a battery, red and flashing into lower state when draining, and lighting when charging. Power shows and the wattage below nad above
                                id: batteryIndicator
                                color: Colors.base03
                                text: batteryFile.text().trim() + "%"
                            }
                            Text {
                                color: Colors.base03
                                text: (Number(batteryPowerFile.text().trim() / 1000000).toFixed(2) + "W")
                            }
                        }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        font.family: root.fontFamily
                        font.weight: 500
                        font.pixelSize: 19
                        color: Colors.base03
                        text: root.time
                    }
                }
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    FileView {
        id: batteryFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }
    FileView {
        property bool exists: true
        onLoadFailed: exists = false
        id: batteryStatusFile
        path: "/sys/class/power_supply/BAT0/status"
    }
    FileView {
        id: batteryPowerFile
        path: "/sys/class/power_supply/BAT0/power_now"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            batteryFile.reload();
            batteryStatusFile.reload();
            batteryPowerFile.reload();
        }
    }
}
