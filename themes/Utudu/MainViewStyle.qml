import QtQuick 2.0
import Ubuntu.Components 1.3

// This sets up the MainViewStyle to be like the defaults, but not overridden
// by the default themes.
Item {
    // styling properties
    anchors.fill: parent
    z: -1
    id: mainViewStyle

    Gradient {
        id: backgroundGradient
        GradientStop { position: 0.0; color: styledItem.headerColor }
        GradientStop { position: 0.83; color: styledItem.backgroundColor }
        GradientStop { position: 1.0; color: styledItem.footerColor }
    }

    Rectangle {
        id: backgroundColor
        anchors.fill: parent
        color: styledItem.backgroundColor
        gradient: internals.isGradient ? backgroundGradient : null
    }

    QtObject {
        id: internals
        property bool isGradient: styledItem.backgroundColor !== styledItem.headerColor ||
                                  styledItem.backgroundColor !== styledItem.footerColor
    }
}
