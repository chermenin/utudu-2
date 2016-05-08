import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 0.1 as ListItem
import "util.js" as Util
import Ubuntu.Components.Popups 0.1

Page {
    property string entryIndex: ""

    Timer {
        id: autosaveTimer
        interval: 5000 // 5 seconds
        running: false
        repeat: false

        onTriggered: {
            Util.debug("Autosaving note")
            storage.setNoteTextByEntry(entryIndex,
                                       noteTextArea.text)
        }
    }

    onEntryIndexChanged: {
        // just return if not a positive number
        if (! /^\+?(0|[1-9]\d*)$/.test(entryIndex)) {
            return
        }

        noteTextArea.initialized = false
        noteTextArea.text = storage.getNoteTextByEntry(entryIndex)
        noteTextArea.initialized = true
    }

    onVisibleChanged: {
        if (visible === true) {
            // just return if not a positive number
            if (! /^\+?(0|[1-9]\d*)$/.test(entryIndex)) {
                return
            }

            noteTextArea.initialized = false
            noteTextArea.text = storage.getNoteTextByEntry(entryIndex)
            noteTextArea.initialized = true
            noteTextArea.forceActiveFocus()
        } else { // commit changes
            // just return if not a positive number
            if (! /^\+?(0|[1-9]\d*)$/.test(entryIndex)) {
                return
            }

            storage.setNoteTextByEntry(entryIndex, noteTextArea.text)
            autosaveTimer.reset
            autosaveTimer.running = false
        }
    }

    header: PageHeader {
        title: parent.title
    }

    Rectangle {
        id: notesColumn
        width: parent.width
        height: parent.height
        anchors {
            fill: parent
            topMargin: header.height
        }

        Rectangle {
            x: units.gu(-0.5)
            y: units.gu(-0.5)
            width: parent.width + units.gu(1)
            height: parent.height + units.gu(1)

            TextArea {
                id: noteTextArea
                anchors.fill: parent
                width: parent.width
                height: parent.height

                placeholderText: i18n.tr("Add note text...")

                // let's make it nice to use as a code editor
                selectByMouse: true
                mouseSelectionMode: TextEdit.SelectCharacters
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.WrapAnywhere
                inputMethodHints: Qt.ImhNoAutoUppercase
                                  //| Qt.ImhNoPredictiveText
                                  //| Qt.ImhNoAutoPunctuation # doesn't exist
//                font.family: "Monospace" // TODO: configurable per note

                property bool initialized: false

                onTextChanged: {
                    // prevent starting timer on initial load
                    if (initialized === false) {
                        autosaveTimer.reset
                        autosaveTimer.running = false
                        return
                    }

                    // reset the timer after each key press. Once we stop
                    // typing in the text area, when the timer expires, we
                    // autosave
                    autosaveTimer.reset
                    autosaveTimer.running = false
                    autosaveTimer.running = true
                }
            }
        }
    }
}
