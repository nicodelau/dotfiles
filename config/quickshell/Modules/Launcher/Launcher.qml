import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Core
import qs.Core.Components
import qs.Core.Windows

CenterWindow {
    id: root

    property string searchText: ""
    property var allApps: []
    property var filteredApps: []
    property string selectedCategory: "All"
    property var activeCategories: ["All"]

    function filterApps(query) {
        query = query.toLowerCase();
        let newFiltered = [];
        for (let i = 0; i < root.allApps.length; i++) {
            let app = root.allApps[i];
            let matchesCategory = false;
            if (root.selectedCategory === "All") {
                matchesCategory = true;
            } else {
                let cats = app.categories || [];
                for (let j = 0; j < cats.length; j++) {
                    let cat = cats[j];
                    if (root.selectedCategory === "Games" && cat === "Game") {
                        matchesCategory = true;
                        break;
                    } else if (root.selectedCategory === "Internet" && cat === "Network") {
                        matchesCategory = true;
                        break;
                    } else if (root.selectedCategory === "Multimedia" && (cat === "AudioVideo" || cat === "Audio" || cat === "Video")) {
                        matchesCategory = true;
                        break;
                    } else if (root.selectedCategory === "Utilities" && cat === "Utility") {
                        matchesCategory = true;
                        break;
                    } else if (root.selectedCategory === cat) {
                        matchesCategory = true;
                        break;
                    }
                }
            }
            if (matchesCategory && app.name.toLowerCase().includes(query))
                newFiltered.push(app);

        }
        root.filteredApps = newFiltered;
        if (appsView) {
            appsView.expandedIndex = -1;
            if (root.filteredApps.length > 0)
                appsView.currentIndex = 0;
            else
                appsView.currentIndex = -1;
        }
    }

    function handleKeyPress(event, fromSearch) {
        if (event.key === Qt.Key_Tab) {
            let categories = root.activeCategories;
            if (categories.length > 1) {
                let currentIndex = categories.indexOf(root.selectedCategory);
                let nextIndex = (currentIndex + 1) % categories.length;
                root.selectedCategory = categories[nextIndex];
                categoryList.positionViewAtIndex(nextIndex, ListView.Contain);
            }
            event.accepted = true;
            return ;
        } else if (event.key === Qt.Key_Backtab) {
            let categories = root.activeCategories;
            if (categories.length > 1) {
                let currentIndex = categories.indexOf(root.selectedCategory);
                let prevIndex = (currentIndex - 1 + categories.length) % categories.length;
                root.selectedCategory = categories[prevIndex];
                categoryList.positionViewAtIndex(prevIndex, ListView.Contain);
            }
            event.accepted = true;
            return ;
        }
        let currentDelegate = appsView.currentItem;
        if (event.key === Qt.Key_Down) {
            if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex < currentDelegate.actionCount - 1) {
                currentDelegate.currentActionIndex++;
                event.accepted = true;
            } else if (appsView.count > 0 && appsView.currentIndex < appsView.count - 1) {
                appsView.expandedIndex = -1;
                appsView.currentIndex++;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Up) {
            if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex >= 0) {
                currentDelegate.currentActionIndex--;
                event.accepted = true;
            } else {
                appsView.expandedIndex = -1;
                if (appsView.currentIndex <= 0 && !fromSearch) {
                    searchField.forceActiveFocus();
                    appsView.currentIndex = -1;
                    event.accepted = true;
                } else if (appsView.currentIndex > 0) {
                    appsView.currentIndex--;
                    event.accepted = true;
                }
            }
        } else if (event.key === Qt.Key_Right) {
            if (currentDelegate && currentDelegate.hasActions && !currentDelegate.isExpanded) {
                appsView.expandedIndex = appsView.currentIndex;
                currentDelegate.currentActionIndex = 0;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Left) {
            if (currentDelegate && currentDelegate.isExpanded) {
                appsView.expandedIndex = -1;
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            let idx = appsView.currentIndex >= 0 ? appsView.currentIndex : 0;
            if (root.filteredApps.length > idx) {
                if (currentDelegate && currentDelegate.isExpanded && currentDelegate.currentActionIndex >= 0) {
                    let action = root.filteredApps[idx].actions[currentDelegate.currentActionIndex];
                    launchApp(action.exec, false);
                } else {
                    let app = root.filteredApps[idx];
                    launchApp(app.exec, app.terminal);
                }
                event.accepted = true;
            }
        }
    }

    function launchApp(exec, terminal) {
        if (!exec)
            return ;

        let command = exec.split(' ').filter(function(arg) {
            return !arg.startsWith('%');
        });
        command = command.map(function(arg) {
            return arg.replace(/^"|"$/g, '');
        });
        if (terminal)
            command = ["kitty", "-e"].concat(command);

        appLauncher.running = false;
        appLauncher.command = command;
        appLauncher.startDetached();
        root.isOpen = false;
    }

    onSelectedCategoryChanged: filterApps(searchField.text)
    onAllAppsChanged: {
        let cats = ["All"];
        let predefined = ["Development", "Games", "Graphics", "Internet", "Multimedia", "Office", "Settings", "System", "Utilities"];
        for (let p = 0; p < predefined.length; p++) {
            let catName = predefined[p];
            let hasApp = false;
            for (let i = 0; i < allApps.length; i++) {
                let app = allApps[i];
                let appCats = app.categories || [];
                for (let j = 0; j < appCats.length; j++) {
                    let c = appCats[j];
                    if (catName === "Games" && c === "Game")
                        hasApp = true;
                    else if (catName === "Internet" && c === "Network")
                        hasApp = true;
                    else if (catName === "Multimedia" && (c === "AudioVideo" || c === "Audio" || c === "Video"))
                        hasApp = true;
                    else if (catName === "Utilities" && c === "Utility")
                        hasApp = true;
                    else if (catName === c)
                        hasApp = true;
                }
                if (hasApp)
                    break;

            }
            if (hasApp)
                cats.push(catName);

        }
        root.activeCategories = cats;
    }
    popupId: "launcher"
    preferredHeight: 480
    preferredWidth: 680
    onPopupOpened: {
        root.selectedCategory = "All";
        if (categoryList) {
            categoryList.positionViewAtIndex(0, ListView.Beginning);
            categoryList.contentX = 0;
        }
        if (appsView)
            appsView.expandedIndex = -1;

        focusTimer.start();
        searchField.text = "";
        loadAppsProc.running = true;
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false
        onTriggered: searchField.forceActiveFocus()
    }

    Process {
        id: loadAppsProc

        command: ["python3", Quickshell.shellDir + "/Scripts/get_apps.py"]
        onExited: function(exitCode) {
            if (exitCode === 0) {
                try {
                    root.allApps = JSON.parse(appFetcherOutput.text);
                    filterApps("");
                } catch (e) {
                    console.error("Error parsing apps JSON: " + e);
                }
            }
        }

        stdout: StdioCollector {
            id: appFetcherOutput
        }

    }

    ThemedSearchBar {
        id: searchField

        Layout.fillWidth: true
        preferredHeight: 40
        placeholderText: "Search applications..."
        onSearchRequested: (text) => {
            return root.filterApps(text);
        }
        textField.font.pixelSize: Constants.sizeMd
        textField.Keys.onPressed: function(event) {
            root.handleKeyPress(event, true);
        }
    }

    Rectangle {
        id: categoryBar

        Layout.fillWidth: true
        Layout.preferredHeight: Constants.size3Xl
        color: "transparent"

        ListView {
            id: categoryList

            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: Constants.sizeXs
            clip: true
            model: root.activeCategories

            delegate: Rectangle {
                width: catText.implicitWidth + Constants.sizeLg * 2
                height: 30
                radius: height / 2
                color: (root.selectedCategory === modelData) ? Theme.accent : (hoverHandler.hovered ? Theme.bgSecondary : "transparent")
                border.color: (root.selectedCategory === modelData) ? "transparent" : Theme.border
                border.width: 1

                ThemedText {
                    id: catText

                    anchors.centerIn: parent
                    text: modelData
                    color: (root.selectedCategory === modelData) ? Theme.bg : Theme.fg
                    font.bold: root.selectedCategory === modelData
                    font.pixelSize: Constants.sizeSm
                }

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        root.selectedCategory = modelData;
                    }
                }

            }

        }

    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        GhostEmptyState {
            anchors.centerIn: parent
            visible: root.filteredApps.length === 0 && searchField.text !== ""
            text: "No applications found"
            isAnimating: visible
        }

        ListView {
            id: appsView

            property int expandedIndex: -1

            anchors.fill: parent
            clip: true
            model: root.filteredApps
            spacing: Constants.sizeXs
            currentIndex: -1
            highlightResizeDuration: 0
            highlightMoveDuration: Constants.animNormal
            highlightFollowsCurrentItem: true
            visible: root.filteredApps.length > 0
            Keys.onPressed: function(event) {
                root.handleKeyPress(event, false);
            }

            highlight: Item {
                width: appsView.width
                height: 44
                z: 1

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeLg
                    color: Theme.bgSecondary
                }

            }

            add: Transition {
                NumberAnimation {
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: Constants.animNormal
                    easing.type: Easing.OutQuint
                }

            }

            populate: Transition {
                NumberAnimation {
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: Constants.animNormal
                    easing.type: Easing.OutQuint
                }

            }

            delegate: Item {
                id: delegateRoot

                readonly property bool isCurrent: appsView.currentIndex === index
                readonly property bool hasActions: modelData.actions && modelData.actions.length > 0
                readonly property int actionCount: modelData.actions ? modelData.actions.length : 0
                readonly property bool isExpanded: appsView.expandedIndex === index
                property int currentActionIndex: -1

                onIsExpandedChanged: {
                    if (!isExpanded)
                        currentActionIndex = -1;

                }
                width: appsView.width
                height: 44 + (isExpanded ? actionsColumn.implicitHeight + Constants.sizeXs : 0)
                z: 2
                clip: true

                Item {
                    id: mainContent

                    width: parent.width
                    height: 44

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeLg
                        color: Theme.bgSecondary
                        visible: hoverHandler.hovered && !isCurrent
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.sizeLg
                        anchors.rightMargin: Constants.sizeLg
                        spacing: Constants.sizeLg

                        Item {
                            Layout.preferredWidth: Constants.size2Xl
                            Layout.preferredHeight: Constants.size2Xl

                            Image {
                                id: appIcon

                                anchors.fill: parent
                                source: {
                                    if (!modelData.icon)
                                        return "";

                                    let path = modelData.icon;
                                    let home = Quickshell.env("HOME");
                                    if (path.startsWith("$HOME"))
                                        path = home + path.substring(5);
                                    else if (path.startsWith("~"))
                                        path = home + path.substring(1);
                                    if (path.startsWith("/") || path.startsWith("file://"))
                                        return path.startsWith("file://") ? path : "file://" + path;

                                    return Quickshell.iconPath(path, true);
                                }
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }

                            SvgIcon {
                                anchors.fill: parent
                                icon: "rocket"
                                iconSize: Constants.size2Xl
                                flat: true
                                iconColor: isCurrent ? Theme.accent : Theme.muted
                                visible: !appIcon.visible
                            }

                        }

                        ThemedText {
                            text: modelData.name
                            color: isCurrent ? Theme.accent : Theme.fg
                            font.bold: isCurrent
                            font.pixelSize: Constants.sizeMd
                            Layout.fillWidth: true
                            scale: isCurrent ? 1.02 : 1
                            transformOrigin: Item.Left

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animNormal
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Constants.animNormal
                                    easing.type: Easing.OutQuint
                                }

                            }

                        }

                        Item {
                            Layout.preferredWidth: Constants.sizeLg * 2
                            Layout.preferredHeight: Constants.sizeLg * 2
                            visible: delegateRoot.hasActions
                        }

                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton && delegateRoot.hasActions) {
                                if (appsView.expandedIndex === index) {
                                    appsView.expandedIndex = -1;
                                } else {
                                    appsView.expandedIndex = index;
                                    appsView.currentIndex = index;
                                    delegateRoot.currentActionIndex = -1;
                                }
                            } else {
                                launchApp(modelData.exec, modelData.terminal);
                            }
                        }
                    }

                    SvgIconButton {
                        icon: "chevron-right"
                        iconSize: Constants.sizeMd
                        visible: delegateRoot.hasActions
                        isActive: delegateRoot.isExpanded
                        iconColor: isActive ? Theme.fg : Theme.muted
                        anchors.right: parent.right
                        anchors.rightMargin: Constants.sizeLg
                        anchors.verticalCenter: mainContent.verticalCenter
                        rotation: delegateRoot.isExpanded ? 90 : 0
                        onClicked: {
                            if (appsView.expandedIndex === index) {
                                appsView.expandedIndex = -1;
                            } else {
                                appsView.expandedIndex = index;
                                appsView.currentIndex = index;
                                delegateRoot.currentActionIndex = -1;
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: Constants.animNormal
                                easing.type: Easing.OutQuint
                            }

                        }

                    }

                }

                Item {
                    id: connectorLines

                    y: 44 + Constants.sizeXs / 2
                    width: parent.width
                    height: actionsColumn.implicitHeight
                    visible: delegateRoot.isExpanded

                    Rectangle {
                        x: Constants.sizeLg + 11
                        y: -Constants.sizeXs / 2
                        width: 2
                        height: parent.height - 12
                        color: Theme.muted
                        radius: width / 2
                    }

                    Repeater {
                        model: modelData.actions || []

                        Rectangle {
                            x: Constants.sizeLg + 11
                            y: index * (34 + actionsColumn.spacing) + 16
                            width: 16
                            height: 2
                            color: Theme.muted
                            radius: height / 2
                        }

                    }

                }

                ColumnLayout {
                    id: actionsColumn

                    y: 44 + Constants.sizeXs / 2
                    width: parent.width
                    spacing: 4
                    visible: delegateRoot.isExpanded

                    Repeater {
                        model: modelData.actions || []

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            Layout.leftMargin: Constants.size4Xl
                            color: "transparent"
                            radius: Constants.sizeLg

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Constants.sizeMd
                                anchors.rightMargin: Constants.sizeLg
                                spacing: Constants.sizeXs

                                Item {
                                    Layout.preferredWidth: 8
                                    Layout.preferredHeight: 8
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 6
                                        height: 6
                                        radius: width / 2
                                        color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Theme.accent : Theme.muted
                                        scale: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? 1.5 : 1

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Constants.animFast
                                            }

                                        }

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: Constants.animFast
                                                easing.type: Easing.OutBack
                                            }

                                        }

                                    }

                                }

                                ThemedText {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: ((delegateRoot.isExpanded && delegateRoot.currentActionIndex === index) || actionMouseArea.containsMouse) ? Theme.accent : Theme.fg
                                    font.pixelSize: Constants.sizeMd
                                    Layout.alignment: Qt.AlignVCenter

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Constants.animFast
                                        }

                                    }

                                }

                            }

                            MouseArea {
                                id: actionMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launchApp(modelData.exec, false)
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Constants.animFast
                                }

                            }

                        }

                    }

                }

                Behavior on height {
                    NumberAnimation {
                        duration: Constants.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
                active: true
            }

        }

    }

    Process {
        id: appLauncher
    }

}
