import QtQuick 2.0
import Ubuntu.Components 1.3

// TODO: this has to be easier than this. As it is, copied in the entire
// CheckBoxStyle.qml from the Ubuntu Components.
Item {
    id: checkBoxStyle
    /*!
      The image to show inside the checkbox when it is checked.
     */
    //property url tickSource: "image://theme/artwork/tick.png"
    property url tickSource: "../graphics/tick@30.png"

    opacity: enabled ? 1.0 : 0.5

    implicitWidth: units.gu(4.25)
    implicitHeight: units.gu(4)

    UbuntuShape {
        id: background
        anchors.fill: parent
        anchors.margins: units.gu(0.5)
    }

    Image {
        id: tick

// Changed from Ubuntu
//fillMode: Image.PreserveAspectCrop
width: parent.width - units.gu(0.625)
height: parent.height - units.gu(0.5)

        anchors.centerIn: parent
        smooth: true
        source: tickSource
        visible: styledItem.checked || transitionToChecked.running || transitionToUnchecked.running
    }

    state: styledItem.checked ? "checked" : "unchecked"
    states: [
        State {
            name: "checked"
            PropertyChanges {
                target: tick
                anchors.verticalCenterOffset: 0
            }
            PropertyChanges {
                target: background
// changed from Ubuntu
                color: UbuntuColors.orange
            }
        },
        State {
            name: "unchecked"
            PropertyChanges {
                target: tick
                anchors.verticalCenterOffset: checkBoxStyle.height
            }
            PropertyChanges {
                target: background
                color: Qt.rgba(Theme.palette.normal.foreground.r, Theme.palette.normal.foreground.g,
                               Theme.palette.normal.foreground.b, 0.2)
            }
        }
    ]

    transitions: [
        Transition {
            id: transitionToUnchecked
            to: "unchecked"
            ColorAnimation {
                target: background
                duration: UbuntuAnimation.FastDuration
                easing: UbuntuAnimation.StandardEasingReverse
            }
            SequentialAnimation {
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: true
                }
                NumberAnimation {
                    target: tick
                    property: "anchors.verticalCenterOffset"
                    duration: UbuntuAnimation.FastDuration
                    easing: UbuntuAnimation.StandardEasingReverse
                }
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: false
                }
            }
        },
        Transition {
            id: transitionToChecked
            to: "checked"
            ColorAnimation {
                target: background
                duration: UbuntuAnimation.FastDuration
                easing: UbuntuAnimation.StandardEasing
            }
            SequentialAnimation {
                PropertyAction {
                    target: checkBoxStyle
                    property: "clip"
                    value: true
                }
                NumberAnimation {
                    target: tick
                    property: "anchors.verticalCenterOffset"
                    duration: UbuntuAnimation.FastDuration
                    easing: UbuntuAnimation.StandardEasing
                }
                PropertyAction {
                    target: checkBoxStyle
                }
            }
        }
    ]
}
