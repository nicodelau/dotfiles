import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components

Flickable {
    id: rightFlick

    property var currentBinds: []
    property var groupedBinds: {
        let groups = [];
        let currentGroup = null;
        for (let i = 0; i < currentBinds.length; i++) {
            let item = currentBinds[i];
            if (item.is_subheader) {
                if (currentGroup !== null)
                    groups.push(currentGroup);

                currentGroup = {
                    "name": item.name,
                    "binds": []
                };
            } else {
                if (currentGroup === null)
                    currentGroup = {
                    "name": "",
                    "binds": []
                };

                currentGroup.binds.push(item);
            }
        }
        if (currentGroup !== null)
            groups.push(currentGroup);

        return groups;
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: Math.max(bindsCol.implicitHeight, rightFlick.height)
    clip: true
    flickableDirection: Flickable.VerticalFlick
    anchors.margins: Constants.sizeLg

    ColumnLayout {
        id: bindsCol

        width: parent.width
        spacing: Constants.sizeLg

        Repeater {
            model: rightFlick.groupedBinds

            Card {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Constants.sizeLg

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Constants.sizeMd
                        visible: modelData.name !== ""

                        ThemedText {
                            text: modelData.name || ""
                            font.pixelSize: Constants.sizeSm
                            color: Theme.muted
                        }

                    }

                    Repeater {
                        id: bindsRepeater

                        model: modelData.binds

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Constants.sizeLg

                            KeybindItem {
                                uiElements: modelData.uiElements || []
                                desc: modelData.desc || ""
                            }

                        }

                    }

                }

            }

        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: rightFlick.height
            visible: currentBinds.length === 0

            GhostEmptyState {
                anchors.centerIn: parent
                text: "No keybinds loaded"
                isAnimating: currentBinds.length === 0
            }

        }

    }

}
