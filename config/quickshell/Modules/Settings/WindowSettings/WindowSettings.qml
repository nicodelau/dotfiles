import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    SettingGroup {
        title: "Window"
        icon: "window"

        ColumnLayout {
            spacing: Constants.sizeLg

            SettingSpinBox {
                label: "Window Rounding"
                from: 0
                to: 40
                stepSize: 1
                value: HyprlandService.hyprRounding
                defaultValue: 32
                suffix: "px"
                onMoved: (val) => {
                    HyprlandService.hyprRounding = Math.round(val);
                }
            }

            SettingSpinBox {
                label: "Global Opacity"
                description: "Transparency of windows and shell"
                from: 50
                to: 100
                stepSize: 5
                value: HyprlandService.hyprActiveOpacity
                defaultValue: 100
                suffix: "%"
                onMoved: (val) => {
                    let intVal = Math.round(val);
                    HyprlandService.hyprActiveOpacity = intVal;
                    HyprlandService.hyprInactiveOpacity = intVal;
                    HyprlandService.applyHyprlandSettings();
                    Theme.bgOpacity = intVal / 100;
                    Theme.saveScheme();
                }
            }

        }

        ColumnLayout {
            spacing: Constants.sizeLg

            SettingSpinBox {
                label: "Gaps In"
                from: 0
                to: 20
                stepSize: 1
                value: HyprlandService.hyprGapsIn
                defaultValue: 4
                suffix: "px"
                onMoved: (val) => {
                    HyprlandService.hyprGapsIn = Math.round(val);
                }
            }

            SettingSpinBox {
                label: "Gaps Out"
                from: 0
                to: 40
                stepSize: 1
                value: HyprlandService.hyprGapsOut
                defaultValue: 8
                suffix: "px"
                onMoved: (val) => {
                    HyprlandService.hyprGapsOut = Math.round(val);
                }
            }

            SettingSpinBox {
                label: "Border Size"
                from: 0
                to: 10
                stepSize: 1
                value: HyprlandService.hyprBorderSize
                defaultValue: 2
                suffix: "px"
                onMoved: (val) => {
                    HyprlandService.hyprBorderSize = Math.round(val);
                }
            }

        }

    }

}
