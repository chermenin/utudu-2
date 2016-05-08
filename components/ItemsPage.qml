import QtQuick 2.0
import Ubuntu.Components 1.3
import "util.js" as Util
import Ubuntu.Components.Popups 0.1

Page {
    property string entryIndex: ""
    property var items: []
    title: "Unset"

    onEntryIndexChanged: {
        updateItems()
    }

    function updateItems() {
        // just return if not a positive number
        if (! /^\+?(0|[1-9]\d*)$/.test(entryIndex)) {
            return
        }

        items = storage.getItemsByEntry(entryIndex)

        itemsModel.clear()
        for (var i = 0; i < items.length; i++) {
            itemsModel.append(items[i])
        }
    }

    ListModel {
        id: itemsModel
    }

    header: PageHeader {
        title: parent.title
        trailingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Uncheck all")
                    iconName: "undo"
                    onTriggered: {
                        Util.debug("pressed listViewUncheckButton")

                        // uncheck all the checked items in the db
                        for (var i = 0; i < itemsModel.count; i++) {
                            if (itemsModel.get(i)["checked"] === "1") {
                                storage.setListItemChecked(entryIndex,
                                    itemsModel.get(i)["listModelIndex"], "0")
                            }
                        }

                        // clear and repopulate the model
                        updateItems()
                    }
                },
                Action {
                    text: i18n.tr("Delete checked")
                    iconName: "clear"
                    onTriggered: {
                        Util.debug("pressed listViewDeleteButton")

                        var has_checked = false
                        for (var i = 0; i < itemsModel.count; i++) {
                            if (itemsModel.get(i)["checked"] === "1") {
                                has_checked = true
                                break
                            }
                        }
                        if (has_checked === true) {
                            PopupUtils.open(dialogDeleteChecked)
                        }
                    }
                }
            ]
            numberOfSlots: 1
        }
    }

    Component {
        id: dialogDeleteChecked
        Dialog {
            id: dialogBox
            title: i18n.tr("Delete checked items")
            text: i18n.tr("Are you sure you want to delete all checked items?")
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogBox)
                }
            }
            Button {
                text: i18n.tr("Delete")
                gradient: UbuntuColors.orangeGradient
                onClicked: {
                    // remove all the checked items from the db
                    for (var i = itemsModel.count - 1; i >= 0; i--) {
                        if (itemsModel.get(i)["checked"] === "1") {
                            storage.deleteListItem(entryIndex,
                                itemsModel.get(i)["listModelIndex"])
                        }
                    }

                    PopupUtils.close(dialogBox)

                    // clear and repopulate the model
                    updateItems()
                }
            }
        }
    }

    Rectangle {
        width: parent.width - units.gu(1)
        height: parent.height - units.gu(1)
        anchors {
            fill: parent
            topMargin: header.height - units.gu(0.1)
        }

        Column {
            anchors {
                fill: parent
            }

            Row {
                height: addListItemTextField.height
                width: parent.width
                x: units.gu(-0.5)

                TextArea {
                    id: addListItemTextField
                    x: units.gu(-0.5)
                    width: parent.width + units.gu(1)
                    height: units.gu(6)
                    placeholderText: i18n.tr("Add item...")


                    Keys.onReturnPressed: {
                        Util.debug("addListItemTextField: entered '" +
                                   addListItemTextField.text  + "'")
                        if (addListItemTextField.text === "") {
                            // in 14.10, onAccepted is triggered when
                            // addListItemTextField.text is set to empty string
                            // (which we do below)
                            return
                        } else if (addListItem(entryIndex,
                            addListItemTextField.text) === true) {
                            addListItemTextField.text = ""
                            // after adding an item, scroll the list
                            listEntries.positionViewAtIndex(listEntries.count - 1, ListView.Beginning)
                        }
                    }

                    function addListItem(idx, s) {
                        var item = storage.addListItem(idx, s)
                        if (item !== null) {
                            items.push(item)
                            itemsModel.append(item)
                            return true
                        }
                        return false
                    }
                }
            }

            ListView {
                id: listEntries
                objectName: "listEntries"
                width: parent.width
                height: parent.height - addListItemTextField.height

                visible: true

                // make sure scrolling doesn't overlap other elements
                clip: true

                // Scroll to editing item quickly
                highlightMoveVelocity: 2500

                model: itemsModel

                delegate: ListItem {
                    width: parent.width
                    height: Math.max(checkBox.height, itemLabel.height) + units.gu(3)
                    visible: (index >= 0)

                    property bool editing: false
                    property var cur: ListView.isCurrentItem

                    leadingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "delete"
                                text: "Delete"
                                onTriggered: {
                                    storage.deleteListItem(entryIndex, itemsModel.get(index)["listModelIndex"])
                                    updateItems()
                                }
                            }
                        ]
                    }

                    onPressAndHold: {
                        listEntries.currentIndex = index
                        editing = true
                    }

                    onClicked: {
                        listEntries.currentIndex = index
                        checkBox.trigger(!checkBox.checked)
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
                            editTextField.text = itemLabel.text
                            editTextField.focus = true
                            editTextField.visible = true
                            itemLabel.visible = false
                            editTextField.forceActiveFocus()
                            editTextField.cursorPosition = editTextField.text.length
                        } else {
                            editTextField.focus = false
                            editTextField.visible = false
                            itemLabel.visible = true
                        }
                    }

                    CheckBox {
                        id: checkBox
                        height: units.gu(3.5)
                        width: height
                        style: UtuduCheckBoxStyle {}
                        x: units.gu(1)
                        anchors.verticalCenter: parent.verticalCenter
                        checked: index >= 0 && itemsModel.get(index)["checked"]
                                     === "1" ? true : false

                        onTriggered: {
                            if (checked === true) {
                                Util.debug("checked " + entryIndex)
                                storage.setListItemChecked(entryIndex,
                                    itemsModel.get(index)["listModelIndex"], "1")
                                itemsModel.get(index)["checked"] = "1"
                            } else {
                                Util.debug("unchecked " + entryIndex)
                                storage.setListItemChecked(entryIndex,
                                    itemsModel.get(index)["listModelIndex"], "0")
                                itemsModel.get(index)["checked"] = "0"
                            }
                        }
                    }

                    Label {
                        id: itemLabel
                        anchors.left: checkBox.right
                        anchors.leftMargin: units.gu(1)
                        width: parent.width - checkBox.width - units.gu(4)
                        anchors.verticalCenter: parent.verticalCenter
                        text: index >= 0 ? itemsModel.get(index)["name"] : ""
                        wrapMode: Text.WordWrap
                        visible: true
                    }

                    TextArea {
                        id: editTextField
                        anchors.left: checkBox.right
                        anchors.leftMargin: units.gu(1)
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                        text: ""
                        width: parent.width - checkBox.width - units.gu(1)
                        height: parent.height + units.gu(0.5)
                        autoSize: true

                        function processEditInput() {
                            Util.debug("editTextField input changed to '" +
                                       editTextField.text + "'")
                            var item_idx = itemsModel.get(index)["listModelIndex"]
                            if (storage.setListItemName(entryIndex,
                                item_idx, editTextField.text) === true) {
                                itemLabel.text = editTextField.text
                            }
                            editing = false
                        }

                        // Why isn't onAccepted working here?
                        Keys.onReturnPressed: {
                            processEditInput()
                        }
                    }

//                    onItemRemoved: {
//                        storage.deleteListItem(entryIndex,
//                            itemsModel.get(index)["listModelIndex"])
//                        updateItems()
//                    }
                }
            }
        } // Column
    } // UbuntuShape
}
