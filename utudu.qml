import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 0.1 as ListItem
import "components"
import "components/util.js" as Util

MainView {
    property string version: "0.4.4"

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    id: mainView

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "utudu-2.imtec"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Resize contents when keyboard appears
    anchorToKeyboard: true

    width: units.gu(50)
    height: units.gu(75)

    Storage {
        id: myStorage
    }
    property alias storage: myStorage

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            Util.debug("Starting...")
            push(entriesPage)
        }

        EntriesPage {
            id: entriesPage
            visible: false
        }

        ItemsPage {
            id: listView
            visible: false
        }

        NotePage {
            id: noteView
            visible: false
        }

        AboutPage {
            id: aboutPage
            visible: false
        }
    }
}
