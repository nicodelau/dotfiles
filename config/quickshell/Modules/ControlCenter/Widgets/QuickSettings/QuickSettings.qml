import "Components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows

Item {
    id: root

    property bool quickSettingsOpen: false
    property var notificationService
    property int activePageIndex: 0

    implicitWidth: mainPage.implicitWidth
    implicitHeight: activePageIndex === 0 ? mainPage.implicitHeight : (activePageIndex === 1 ? wifiPage.implicitHeight : bluetoothPage.implicitHeight)

    Item {
        id: stackContainer

        width: parent.width
        implicitHeight: root.implicitHeight
        clip: true

        ColumnLayout {
            id: mainPage

            width: parent.width
            spacing: Constants.sizeLg
            x: root.activePageIndex === 0 ? 0 : -parent.width
            visible: x > -parent.width

            Card {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Constants.sizeLg

                    RowLayout {
                        id: topControlsRow

                        Layout.fillWidth: true
                        spacing: Constants.sizeLg

                        WifiControl {
                            id: wifiControl

                            Layout.fillWidth: true
                            expanded: root.activePageIndex === 1
                            onMenuClicked: {
                                if (isActive)
                                    root.activePageIndex = 1;

                            }
                            onIsActiveChanged: {
                                if (!isActive && root.activePageIndex === 1)
                                    root.activePageIndex = 0;

                            }
                        }

                        BluetoothControl {
                            id: btControl

                            Layout.fillWidth: true
                            expanded: root.activePageIndex === 2
                            onMenuClicked: {
                                if (isActive)
                                    root.activePageIndex = 2;

                            }
                            onIsActiveChanged: {
                                if (!isActive && root.activePageIndex === 2)
                                    root.activePageIndex = 0;

                            }
                        }

                    }

                    RowLayout {
                        id: bottomControlsRow

                        Layout.alignment: Qt.AlignHCenter
                        spacing: Constants.sizeLg

                        VolumeControl {
                            id: volControl
                        }

                        MicControl {
                            id: micBtn
                        }

                        CaffeineControl {
                            id: caffeineBtn
                        }

                        NightLightControl {
                            id: nightLightBtn
                        }

                        GameModeControl {
                            id: gamepadBtn
                        }

                        RecordControl {
                            id: recordBtn
                        }

                        DndControl {
                            id: dndBtn

                            notificationService: root.notificationService
                        }

                    }

                    ColumnLayout {
                        id: sliderCol

                        Layout.fillWidth: true
                        spacing: Constants.sizeLg

                        VolumeSlider {
                            volume: volControl.volume
                            muted: volControl.muted
                            onMoved: (val) => {
                                return volControl.setVolume(val);
                            }
                            onIconClicked: volControl.toggleMute()
                        }

                        ThemedSlider {
                            id: micSlider

                            enabled: !AudioService.micMuted
                            value: AudioService.micVolume
                            icon: AudioService.micMuted ? "microphone-off" : "microphone"
                            onMoved: (val) => {
                                AudioService.setMicVolume(val);
                            }
                            onIconClicked: AudioService.setMicMuted(!AudioService.micMuted)
                        }

                        BrightnessSlider {
                        }

                    }

                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

        Card {
            id: wifiPage

            width: parent.width
            x: root.activePageIndex === 1 ? 0 : parent.width
            visible: x < parent.width

            ColumnLayout {
                anchors.fill: parent
                spacing: Constants.sizeLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.sizeSm

                    SvgIconButton {
                        icon: "chevron-left"
                        iconSize: Constants.sizeLg
                        flat: true
                        onClicked: root.activePageIndex = 0
                    }

                    ThemedText {
                        text: "Wi-Fi Networks"
                        font.pixelSize: Constants.sizeLg
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

                WifiList {
                    Layout.fillWidth: true
                    expanded: root.activePageIndex === 1
                    isActive: wifiControl.isActive
                    wifiList: wifiControl.wifiList
                    onConnect: (ssid) => {
                        return wifiControl.connect(ssid);
                    }
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

        Card {
            id: bluetoothPage

            width: parent.width
            x: root.activePageIndex === 2 ? 0 : parent.width
            visible: x < parent.width
            backgroundColor: Theme.bgSecondary

            ColumnLayout {
                anchors.fill: parent
                spacing: Constants.sizeLg

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.sizeSm

                    SvgIconButton {
                        icon: "chevron-left"
                        iconSize: Constants.sizeLg
                        flat: true
                        onClicked: root.activePageIndex = 0
                    }

                    ThemedText {
                        text: "Bluetooth Devices"
                        font.pixelSize: Constants.sizeLg
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                }

                BluetoothList {
                    Layout.fillWidth: true
                    expanded: root.activePageIndex === 2
                    isActive: btControl.isActive
                    btList: btControl.btList
                    onConnect: (mac) => {
                        return btControl.connect(mac);
                    }
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: Constants.animNormal
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
