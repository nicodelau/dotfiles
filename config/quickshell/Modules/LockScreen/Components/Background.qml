import Qt5Compat.GraphicalEffects
import QtQuick
import qs.Core
import qs.Core.Utils

Rectangle {
    id: bgRect

    property bool isDark: ColorUtils.isDark(Theme.bg)

    color: Theme.bg
    opacity: 1

    Item {
        anchors.fill: parent
        opacity: 0.05

        Repeater {
            model: Math.ceil(parent.width / (Constants.size5Xl * 1.5))

            Rectangle {
                x: index * (Constants.size5Xl * 1.5)
                width: 1
                height: parent.height
                color: Theme.muted
            }

        }

        Repeater {
            model: Math.ceil(parent.height / (Constants.size5Xl * 1.5))

            Rectangle {
                y: index * (Constants.size5Xl * 1.5)
                width: parent.width
                height: 1
                color: Theme.muted
            }

        }

    }

    RadialGradient {
        anchors.fill: parent
        horizontalOffset: parent.width / 3
        verticalOffset: -parent.height / 3.5
        horizontalRadius: parent.width / 4
        verticalRadius: parent.height / 4

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(Theme.accentComplementary.r, Theme.accentComplementary.g, Theme.accentComplementary.b, bgRect.isDark ? 0.12 : 0.35)
            }

            GradientStop {
                position: 1
                color: "transparent"
            }

        }

    }

    RadialGradient {
        anchors.fill: parent
        horizontalOffset: -parent.width / 3
        verticalOffset: parent.height / 3.5
        horizontalRadius: parent.width / 4
        verticalRadius: parent.height / 4

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, bgRect.isDark ? 0.1 : 0.3)
            }

            GradientStop {
                position: 1
                color: "transparent"
            }

        }

    }

}
