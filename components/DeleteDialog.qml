import QtQuick 2.0
import Ubuntu.Components 1.3
import "util.js" as Util
import Ubuntu.Components.Popups 0.1

Item {
    property var dialog: dialogComponent
    property string entryIndex: ""
    property string itemIndex: ""

    Component {
        id: dialogComponent

        Dialog {

            id: dialog
            title: i18n.tr("Delete entry")
            text: i18n.tr("Delete the following entry?\n") +
                  storage.getEntryName(entryIndex)

            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialog)
                }
            }
            Button {
                text: i18n.tr("Delete")
                onClicked: {
                    pageStack.pop()
                    PopupUtils.close(dialog)
                    storage.deleteEntry(entryIndex)
                    entriesPage.updateEntries()
                    entryIndex = ""
                }
            }
        }
    }
}
