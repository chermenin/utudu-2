import QtQuick 2.0
import Ubuntu.Components 1.3
import "util.js" as Util
import Ubuntu.Components.Themes.Ambiance 0.1
import Ubuntu.Components.Popups 0.1

Page {
    property int numEntries: -1
    property string showToday: "today"

    // TODO: keep these in sync with entriesPage (but can't now since setting
    // selectedIndex doesn't work right
    property string filterCategory: ""
    property int filterCategoryIndex: 0

    property string newEntryType: ""

    onNumEntriesChanged: {
        entriesModel.clear()

        var entries = storage.getEntriesByCategory(filterCategory == "" ? showToday : filterCategory)

        // sorted by when entered (index)
        //for (var i = 0; i < entries.length; i++) {
        //    entriesModel.append(entries[i])
        //}

        // sorted alphabetical by name
        var names = {}
        for (var i = 0; i < entries.length; i++) {
            var n = entries[i]["name"].toLowerCase()
            if (names.hasOwnProperty(n)) {
                names[n].push(entries[i])
            } else {
                names[n] = []
                names[n].push(entries[i])
            }
        }
        var keys = []
        for (var k in names) {
            keys.push(k)
        }
        keys.sort()
        for (var i = 0; i < keys.length; i++) {
            for (var j = 0; j < names[keys[i]].length; j++) {
                entriesModel.append(names[keys[i]][j])
            }
        }
    }

    onVisibleChanged: {
        if (visible === true) {
            filterCategory = filterCategory == "" ? showToday : filterCategory
        }
    }

    onFilterCategoryChanged: {
        if (filterCategory === undefined) {
            return
        }
        Util.debug("EntriesPage: filterCategory changed to '" +
                   filterCategory + "'")
        updateEntries()
    }

    Component.onCompleted: {
        filterCategory = showToday
    }

    function updateEntries() {
        numEntries = storage.getEntryIndexesByCategory(filterCategory).length
    }

    Component {
        id: addEntryDialogComponent

        Dialog {
            id: addEntryDialog
            title: i18n.tr("New " + newEntryType)
            text: i18n.tr("Enter title text to create new entry")

            TextArea {
                id: entryTitleTextField
                autoSize: true

                Keys.onReturnPressed: {
                    storage.addEntry(entryTitleTextField.text, filterCategory, newEntryType)
                    PopupUtils.close(addEntryDialog)
                    updateEntries()
                }
            }

            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(addEntryDialog)
                }
            }

            Button {
                text: i18n.tr("Create")
                gradient: UbuntuColors.orangeGradient
                onClicked: {
                    storage.addEntry(entryTitleTextField.text, filterCategory, newEntryType)
                    PopupUtils.close(addEntryDialog)
                    updateEntries()
                }
            }

            Component.onCompleted: {
                entryTitleTextField.forceActiveFocus()
            }
        }
    }

    header: PageHeader {
        title: i18n.tr(filterCategory.charAt(0).toUpperCase() + filterCategory.substring(1, filterCategory.length))

        leadingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Today")
                    iconName: "starred"
                    onTriggered: {
                        numEntries = -1
                        filterCategory = "today"
                        filterCategoryIndex = 0
                    }
                },
                Action {
                    text: i18n.tr("Week")
                    iconName: "calendar-today"
                    onTriggered: {
                        numEntries = -1
                        filterCategory = "week"
                        filterCategoryIndex = 1
                    }
                },
                Action {
                    text: i18n.tr("Other")
                    iconName: "calendar"
                    onTriggered: {
                        numEntries = -1
                        filterCategory = "other"
                        filterCategoryIndex = 2
                    }
                }
            ]
            numberOfSlots: 1
        }

        trailingActionBar {
            actions: [
                Action {
                    text: i18n.tr("About")
                    iconName: "info"
                    onTriggered: {
                        pageStack.push(aboutPage)
                    }
                },
                Action {
                    text: i18n.tr("New list")
                    iconName: "view-list-symbolic"
                    onTriggered: {
                        newEntryType = "list"
                        PopupUtils.open(addEntryDialogComponent)
                    }
                },
                Action {
                    text: i18n.tr("New note")
                    iconName: "message"
                    onTriggered: {
                        newEntryType = "note"
                        PopupUtils.open(addEntryDialogComponent)
                    }
                }
            ]
        }
    }

    ListModel {
        id: entriesModel
    }

    Rectangle {
        width: parent.width
        height: parent.height - header.height
        anchors {
            fill: parent
            topMargin: header.height // + units.gu(1)
        }

        Column {
            spacing: units.gu(0)
            anchors {
                fill: parent
            }
            width: parent.width

            UbuntuListView {
                id: entriesList
                width: parent.width
                height: parent.height
                visible: true

                // make sure scrolling doesn't overlap other elements
                clip: true

                // Scroll to editing item quickly
                highlightMoveVelocity: 2500

                model: entriesModel

                delegate: ListItem {

                    height: entryLabel.height + units.gu(4)

                    leadingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "delete"
                                text: "Delete"
                                onTriggered: {
                                    storage.deleteEntry(entriesModel.get(index)["listModelIndex"])
                                    updateEntries()
                                }
                            }
                        ]
                    }

                    trailingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "starred"
                                text: "Today"
                                onTriggered: {
                                    storage.setEntryCategory(entriesModel.get(index)["listModelIndex"], "today")
                                    updateEntries()
                                }
                            },
                            Action {
                                iconName: "calendar-today"
                                text: "This week"
                                onTriggered: {
                                    storage.setEntryCategory(entriesModel.get(index)["listModelIndex"], "week")
                                    updateEntries()
                                }
                            },
                            Action {
                                iconName: "calendar"
                                text: "Other"
                                onTriggered: {
                                    storage.setEntryCategory(entriesModel.get(index)["listModelIndex"], "other")
                                    updateEntries()
                                }
                            }
                        ]
                    }

                    property bool editing: false
                    property var cur: ListView.isCurrentItem

                    onPressAndHold: {
                        entriesList.currentIndex = index
                        editing = true
                    }

                    onClicked: {
                        entriesList.currentIndex = index

                        var idx = entriesModel.get(index)["listModelIndex"]
                        var view = noteView
                        if (storage.isEntryList(idx) === true) {
                            view = listView
                        }
                        view.title = entriesModel.get(index)["name"]
                        view.entryIndex = idx
                        pageStack.push(view)
                    }

                    onCurChanged: {
                        // Don't allow concurrent edits
                        if (cur === false) {
                            editing = false
                        }
                    }

                    onEditingChanged: {
                        if (editing === true) {
                            // forget previous changes
                            editTextField.text = entryLabel.text
                            editTextField.focus = true
                            editTextField.visible = true
                            entryLabel.visible = false
                            editTextField.forceActiveFocus()
                            editTextField.cursorPosition = editTextField.text.length
                        } else {
                            editTextField.focus = false
                            editTextField.visible = false
                            entryLabel.visible = true
                        }
                    }

                    Label {
                        id: entryLabel
                        height: contentHeight
                        width: parent.width - units.gu(4)
                        x: units.gu(2)
                        wrapMode: Text.WordWrap
                        text: index >= 0 ? entriesModel.get(index)["name"] : ""
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    TextArea {
                        id: editTextField
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        text: entryLabel.text
                        width: parent.width - units.gu(2)
                        x: units.gu(1)
                        height: units.gu(4.3)
                        autoSize: true

                        function processEditInput() {
                            Util.debug("editTextField input changed to '" +
                                       editTextField.text + "'")
                            var idx = entriesModel.get(index)["listModelIndex"]
                            if (storage.setEntryName(idx,
                                editTextField.text) === true) {
                                entryLabel.text = editTextField.text
                                updateEntries()
                            }
                            editing = false
                        }

                        // Why isn't onAccepted working here?
                        Keys.onReturnPressed: {
                            processEditInput()
                        }
                    }
                }
            }
        } // Column
    } // UbuntuShape
}
