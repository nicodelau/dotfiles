import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components

RowLayout {
    property var uiElements
    property string desc

    Layout.fillWidth: true

    ThemedText {
        text: desc
        font.pixelSize: Constants.sizeMd
        color: Theme.fg
        Layout.fillWidth: true
        elide: Text.ElideRight
    }

    Row {
        spacing: 4

        Repeater {
            model: uiElements

            delegate: Item {
                required property var modelData

                width: modelData.isKey ? keyRect.width : sepText.implicitWidth
                height: 26

                Rectangle {
                    id: keyRect

                    visible: modelData.isKey
                    width: Math.max(capText.implicitWidth + 16, 32)
                    height: 28
                    radius: 6
                    color: Theme.bgSecondary
                    border.color: Theme.border
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 3
                        radius: 6
                        color: Theme.bgSecondary
                    }

                    ThemedText {
                        id: capText

                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1
                        text: modelData.isKey ? modelData.text : ""
                        color: Theme.fg
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                    }

                }

                ThemedText {
                    id: sepText

                    visible: !modelData.isKey
                    text: !modelData.isKey ? modelData.text : ""
                    color: Theme.muted
                    font.pixelSize: Constants.sizeMd
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

}
