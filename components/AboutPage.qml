import QtQuick 2.0
import Ubuntu.Components 1.3
import "util.js" as Util

Page {
    id: aboutPage
    visible: false

    header: PageHeader {
        title: i18n.tr("About")
    }

    Rectangle {
        height: parent.height
        width: parent.width
        anchors {
            fill: parent
        }

        Column {
            id: aboutColumn
            spacing: units.gu(3)
            width: parent.width
            y: header.height + units.gu(2)

            Label {
                fontSize: "x-large"
                font.bold: true
                text: i18n.tr("Ütudu 2")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                font.bold: true
                text: "(yoo-too-DOO-too)"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Utilize image with transparency
            UbuntuShape {
                width: 196
                height: 186 // don't show transparency
                anchors.horizontalCenter: parent.horizontalCenter

                image: Image {
                    fillMode: Image.PreserveAspectCrop
                    source: "../graphics/utudu256.png"
                    verticalAlignment: Image.AlignVCenter
                    horizontalAlignment: Image.AlignHCenter
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                }
            }
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                spacing: units.gu(1)
                Label {
                    id: versionLabel
                    font.bold: true
                    text: i18n.tr("Version: ")
                }
                Label {
                    text: version
                }
                Label {
                    font.bold: true
                    text: i18n.tr("Based on: ")
                }
                Label {
                    text: "Utudu 0.2.3"
                }
                Label {
                    font.bold: true
                    text: i18n.tr("Powered by: ")
                }
                Label {
                    text: "Jamie Strandboge"
                }
                Label {
                    font.bold: true
                    text: i18n.tr("Icon: ")
                }
                Label {
                    text: "Sam Hewitt"
                }
                Label {
                    font.bold: true
                    text: i18n.tr("Licenses: ")
                }
                Label {
                    text: "<a href=\"http://www.gnu.org/licenses/gpl-3.0.html#content\">GPL-3</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Label {
                    font.bold: true
                    text: "<a href=\"https://github.com/chermenin/utudu-2\">github.com/chermenin/utudu-2</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }

}
