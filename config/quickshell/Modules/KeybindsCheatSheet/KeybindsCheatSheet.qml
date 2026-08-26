import "Components"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Windows

AppWindow {
    id: root

    property var hyprlandData: []
    property var nvimData: []
    property int activeTab: 0
    property int selectedCategory: 0
    property var currentData: activeTab === 0 ? hyprlandData : nvimData
    property string searchText: ""
    property var computedBinds: {
        if (currentData.length === 0)
            return [];

        if (searchText !== "") {
            let matches = [];
            let lowerSearch = searchText.toLowerCase();
            for (let i = 0; i < currentData.length; i++) {
                let cat = currentData[i];
                for (let j = 0; j < cat.binds.length; j++) {
                    let bind = cat.binds[j];
                    if (bind.is_subheader)
                        continue;

                    let matchDesc = bind.desc && bind.desc.toLowerCase().indexOf(lowerSearch) !== -1;
                    let matchKey = false;
                    for (let k = 0; k < bind.uiElements.length; k++) {
                        if (bind.uiElements[k].isKey && bind.uiElements[k].text.toLowerCase().indexOf(lowerSearch) !== -1) {
                            matchKey = true;
                            break;
                        }
                    }
                    if (matchDesc || matchKey)
                        matches.push(bind);

                }
            }
            return matches;
        }
        if (selectedCategory < 0 || selectedCategory >= currentData.length)
            return [];

        return currentData[selectedCategory].binds;
    }
    property var displayedBinds: []

    function loadKeybinds() {
        hyprlandData = [];
        nvimData = [];
        activeTab = 0;
        selectedCategory = 0;
        hyprProc.running = true;
        nvimProc.running = true;
    }

    function processKeybindData(rawData) {
        let processed = [];
        for (let i = 0; i < rawData.length; i++) {
            let section = rawData[i];
            let newBinds = [];
            let bindCount = 0;
            for (let j = 0; j < section.binds.length; j++) {
                let bind = section.binds[j];
                if (bind.is_subheader) {
                    newBinds.push({
                        "is_subheader": true,
                        "name": bind.name,
                        "uiElements": [],
                        "desc": ""
                    });
                    continue;
                }
                bindCount++;
                let keys = bind.keys;
                let desc = bind.desc;
                let result = [];
                let multiKeys = [];
                let joiner = "";
                if (desc.endsWith(" ←→↑↓")) {
                    desc = desc.replace(" ←→↑↓", "");
                    multiKeys = ["↕ ↔"];
                } else if (desc.endsWith(" 1..0")) {
                    desc = desc.replace(" 1..0", "");
                    multiKeys = ["1", "0"];
                    joiner = "..";
                } else if (desc === "Previous / Next Workspace") {
                    multiKeys = ["←", "→"];
                    joiner = "/";
                } else if (desc === "Scroll Through Workspaces") {
                    multiKeys = ["Scroll ↓", "Scroll ↑"];
                    joiner = "/";
                } else {
                    multiKeys = [keys[keys.length - 1]];
                }
                for (let k = 0; k < keys.length - 1; k++) {
                    result.push({
                        "text": keys[k],
                        "isKey": true
                    });
                    result.push({
                        "text": "+",
                        "isKey": false
                    });
                }
                for (let k = 0; k < multiKeys.length; k++) {
                    result.push({
                        "text": multiKeys[k],
                        "isKey": true
                    });
                    if (k < multiKeys.length - 1 && joiner !== "")
                        result.push({
                        "text": joiner,
                        "isKey": false
                    });

                }
                newBinds.push({
                    "uiElements": result,
                    "desc": desc
                });
            }
            processed.push({
                "section": section.section,
                "binds": newBinds,
                "bindCount": bindCount
            });
        }
        return processed;
    }

    contentPadding: 0
    onComputedBindsChanged: {
        if (transitionView.updateCallback === null)
            root.displayedBinds = root.computedBinds;

    }
    popupId: "minflair_keybinds"
    windowTitle: "Minflair Keybinds Cheat Sheet"
    onIsOpenChanged: {
        if (isOpen)
            root.loadKeybinds();

    }

    Shortcut {
        sequence: "Tab"
        enabled: root.isOpen && root.currentData.length > 0
        onActivated: {
            let nextCat = (root.selectedCategory + 1) % root.currentData.length;
            let dir = nextCat > root.selectedCategory ? 1 : -1;
            if (nextCat === 0 && root.selectedCategory > 0)
                dir = 1;

            transitionView.triggerTransition(dir, function() {
                root.displayedBinds = root.computedBinds;
            });
            root.selectedCategory = nextCat;
        }
    }

    Shortcut {
        sequence: "Shift+Tab"
        enabled: root.isOpen && root.currentData.length > 0
        onActivated: {
            let prevCat = (root.selectedCategory - 1 + root.currentData.length) % root.currentData.length;
            let dir = prevCat < root.selectedCategory ? -1 : 1;
            if (prevCat === root.currentData.length - 1 && root.selectedCategory === 0)
                dir = -1;

            transitionView.triggerTransition(dir, function() {
                root.displayedBinds = root.computedBinds;
            });
            root.selectedCategory = prevCat;
        }
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        enabled: root.isOpen
        onActivated: {
            let nextTab = root.activeTab === 0 ? 1 : 0;
            let dir = nextTab > root.activeTab ? 1 : -1;
            transitionView.triggerTransition(dir, function() {
                root.displayedBinds = root.computedBinds;
            });
            root.activeTab = nextTab;
            root.selectedCategory = 0;
        }
    }

    Process {
        id: hyprProc

        command: ["python3", Quickshell.shellDir + "/Scripts/parse_keybinds.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let rawData = JSON.parse(hyprOutput.text);
                    root.hyprlandData = processKeybindData(rawData);
                } catch (e) {
                    console.error("Error parsing Hyprland keybinds: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: hyprOutput
        }

    }

    Process {
        id: nvimProc

        command: ["python3", Quickshell.shellDir + "/Scripts/parse_keybinds.py", "--nvim"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    let rawData = JSON.parse(nvimOutput.text);
                    root.nvimData = processKeybindData(rawData);
                } catch (e) {
                    console.error("Error parsing Neovim keybinds: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: nvimOutput
        }

    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        KeybindsSidebar {
            activeTab: root.activeTab
            selectedCategory: root.selectedCategory
            currentData: root.currentData
            searchText: root.searchText
            onTabSelected: function(tabIndex) {
                if (tabIndex === root.activeTab)
                    return ;

                let dir = tabIndex > root.activeTab ? 1 : -1;
                transitionView.triggerTransition(dir, function() {
                    root.displayedBinds = root.computedBinds;
                });
                root.activeTab = tabIndex;
            }
            onCategorySelected: function(categoryIndex) {
                if (categoryIndex === root.selectedCategory)
                    return ;

                let dir = categoryIndex > root.selectedCategory ? 1 : -1;
                transitionView.triggerTransition(dir, function() {
                    root.displayedBinds = root.computedBinds;
                });
                root.selectedCategory = categoryIndex;
            }
            onSearchRequested: function(text) {
                root.searchText = text;
            }
        }

        PageTransitionView {
            id: transitionView

            Layout.fillWidth: true
            Layout.fillHeight: true

            KeybindsList {
                anchors.fill: parent
                currentBinds: root.displayedBinds
            }

        }

    }

}
