import "Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows
import qs.Modules.Settings.EffectsSettings
import qs.Modules.Settings.InputAndClipboardSettings
import qs.Modules.Settings.IntegrationsSettings
import qs.Modules.Settings.PersonalizationSettings
import qs.Modules.Settings.SystemInfo
import qs.Modules.Settings.UpdatePreferences
import qs.Modules.Settings.WindowSettings

AppWindow {
    id: root

    property int activeTab: 0
    property int lastTab: 0
    property int animOff: 0
    property var pageComponents: [personalizationComp, effectsComp, windowComp, integrationsComp, inputAndClipboardComp, updatePreferencesComp, systemInfoComp]
    property string powerProfile: SystemInfoService.powerProfile
    property string batteryStatus: SystemInfoService.batteryStatus
    property string batteryPercentage: SystemInfoService.batteryPercentage
    property string batteryEstimation: SystemInfoService.batteryEstimation

    popupId: "minflair_settings"
    windowTitle: "Minflair Settings"
    contentPadding: 0
    onIsOpenChanged: {
        if (isOpen) {
            if (AppState.pendingSettingsTab !== -1) {
                activeTab = AppState.pendingSettingsTab;
                AppState.pendingSettingsTab = -1;
            } else {
                activeTab = 0;
            }
        }
    }

    Process {
        id: queryHyprlandProc

        command: ["sh", "-c", "echo \"{\\\"blur\\\":$(hyprctl getoption decoration:blur:enabled -j | jq .int),\\\"rounding\\\":$(hyprctl getoption decoration:rounding -j | jq .int),\\\"active_opacity\\\":$(hyprctl getoption decoration:active_opacity -j | jq .float),\\\"inactive_opacity\\\":$(hyprctl getoption decoration:inactive_opacity -j | jq .float),\\\"blur_size\\\":$(hyprctl getoption decoration:blur:size -j | jq .int),\\\"blur_passes\\\":$(hyprctl getoption decoration:blur:passes -j | jq .int),\\\"gaps_in\\\":\\\"$(hyprctl getoption general:gaps_in -j | jq -r .custom)\\\",\\\"gaps_out\\\":\\\"$(hyprctl getoption general:gaps_out -j | jq -r .custom)\\\"}\""]

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "") {
                    try {
                        let opts = JSON.parse(data.trim());
                        HyprlandService.hyprBlur = opts.blur === 1;
                        HyprlandService.hyprRounding = opts.rounding;
                        HyprlandService.hyprActiveOpacity = Math.round(opts.active_opacity * 100);
                        HyprlandService.hyprInactiveOpacity = Math.round(opts.inactive_opacity * 100);
                        HyprlandService.hyprBlurSize = opts.blur_size;
                        HyprlandService.hyprBlurPasses = opts.blur_passes;
                        let gapsInStr = opts.gaps_in || "4";
                        HyprlandService.hyprGapsIn = parseInt(gapsInStr.split(" ")[0]) || 4;
                        let gapsOutStr = opts.gaps_out || "8";
                        HyprlandService.hyprGapsOut = parseInt(gapsOutStr.split(" ")[0]) || 8;
                    } catch (e) {
                        console.error("Error parsing Hyprland options: " + e);
                    }
                }
            }
        }

    }

    Process {
        id: resetSettingsProc

        command: ["sh", "-c", "rm -f ~/.cache/quickshell/settings_prefs.json ~/.cache/quickshell/colorscheme.json ~/.cache/quickshell/wallpaper_colorscheme.json"]
    }

    Process {
        id: clearClipboardProc

        command: ["cliphist", "wipe"]
    }

    Process {
        id: wipeClipboardImagesProc

        command: ["sh", "-c", "rm -rf /tmp/quickshell-clipboard/*"]
    }

    Timer {
        id: reloadTimer

        interval: 300
        repeat: false
        onTriggered: Quickshell.reload()
    }

    Component {
        id: personalizationComp

        PersonalizationSettings {
            anchors.fill: parent
        }

    }

    Component {
        id: effectsComp

        EffectsSettings {
            anchors.fill: parent
        }

    }

    Component {
        id: windowComp

        WindowSettings {
            anchors.fill: parent
        }

    }

    Component {
        id: integrationsComp

        IntegrationsSettings {
            anchors.fill: parent
        }

    }

    Component {
        id: inputAndClipboardComp

        InputAndClipboardSettings {
            anchors.fill: parent
        }

    }

    Component {
        id: updatePreferencesComp

        UpdatePreferences {
            anchors.fill: parent
        }

    }

    Component {
        id: systemInfoComp

        SystemInfo {
            anchors.fill: parent
        }

    }

    Shortcut {
        sequence: "Tab"
        onActivated: {
            root.activeTab = (root.activeTab + 1) % root.pageComponents.length;
        }
    }

    Shortcut {
        sequence: "Shift+Tab"
        onActivated: {
            root.activeTab = (root.activeTab - 1 + root.pageComponents.length) % root.pageComponents.length;
        }
    }

    RowLayout {
        spacing: 0

        SettingsSidebar {
            Layout.fillHeight: true
            Layout.preferredWidth: 260
            activeTab: root.activeTab
            onTabClicked: (index) => {
                root.activeTab = index;
            }
        }

        PageTransitionView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            activeIndex: root.activeTab
            onContentNeedsUpdate: (index) => {
                pageLoader.sourceComponent = root.pageComponents[index];
            }

            Loader {
                id: pageLoader

                anchors.fill: parent
                sourceComponent: personalizationComp
            }

        }

    }

}
