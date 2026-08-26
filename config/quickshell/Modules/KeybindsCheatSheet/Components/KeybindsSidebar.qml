import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components

SearchableSidebar {
    id: root

    property int activeTab: 0
    property int selectedCategory: 0
    property var currentData: []

    signal tabSelected(int tabIndex)
    signal categorySelected(int categoryIndex)

    searchPlaceholder: "Search keybinds..."

    SidebarItem {
        label: "Hyprland"
        icon: "hyprland"
        isActive: activeTab === 0
        onClicked: {
            tabSelected(0);
            categorySelected(0);
        }
    }

    SidebarItem {
        label: "Neovim"
        icon: "neovim"
        isActive: activeTab === 1
        onClicked: {
            tabSelected(1);
            categorySelected(0);
        }
    }

    Divider {
        Layout.margins: Constants.sizeXs
        Layout.topMargin: 8
        Layout.bottomMargin: 8
    }

    Repeater {
        model: currentData

        delegate: SidebarItem {
            label: modelData.section
            subLabel: modelData.bindCount
            isActive: index === selectedCategory && root.searchText === ""
            onClicked: {
                categorySelected(index);
                searchRequested("");
            }
        }

    }

}
