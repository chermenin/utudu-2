/* Storage.qml
 *
 * Copyright 2014 Jamie Strandboge <jamie@ubuntu.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import U1db 1.0 as U1db
import "util.js" as Util

Item {
    id: storage

    // this string is here so any one can display it
    property var uncategorized: i18n.tr("Uncategorized")

    // Setup the database
    U1db.Database {
        id: db
        path: "utudu2.u1db"
    }

    property var db_settings_defaults: {
        "db_version": "1.0",
        "theme": "Gray"
    }

    // Declare a document
    U1db.Document {
        database: db
        docId: "settings"
        id: settings
        create: true
        defaults: db_settings_defaults
    }

    property var themes: {
        "Gray": {
            "headerColor": "#221e1c",
            "bgColor": "#221e1c",
            "footerColor": "#221e1c",
            "fgColor": "#333333",
            //"fgFontColor": "#aea79f",
            "fgFontColor": "#ffffff",
            "componentColor": "#333333",
            "componentFontColor": "#ffffff"
        },
        "Aubergine": {
            "headerColor": "#2c001e",
            "bgColor": "#5E2750",
            "footerColor": "#2c001e",
            "fgColor": "#2c001e",
            "fgFontColor": "#ffffff",
            "componentColor": "#2c001e",
            "componentFontColor": "#ffffff"
        },
        "Light": {
            "headerColor": "#545443",
            "bgColor": "#a8a887",
            "footerColor": "#a8a887",
            "fgColor": "#ffffcc",
            "fgFontColor": "#545443",
            "componentColor": "#787863",
            "componentFontColor": "#ffffff"
        }
    }

    //
    // Settings API
    //
    function getThemeSetting(attr) {
        var t = settings.contents["theme"]
        return themes[t][attr]
    }

    function getTheme() {
        return settings.contents["theme"]
    }

    function setTheme(theme) {
        var tmp = settings.contents
        tmp["theme"] = theme
        settings.contents = tmp
        return true
    }


    // Store this separately which will make it easier to do db updates in the
    // future. These might look like:
    //   if (db_version != db_version_latest) {
    //     settings.contents = tmp // we could be a lot smarter about this
    //                             // and just update the individual keys
    //   }
    //
    property var db_defaults: {
        "db_version": "1.0",
        "next_entry_index": "4",
        "next_category_index": "3",
        "entries": {
            "0": {
                "name": "Greetings from Utudu!",
                "type": "note",
                "modified": "1390759927000",
                "category": "2",
                "text": "Hello!\n\nUtudu is a simple checklist and note\ntaking program that is designed to be easy\nto use. It supports categories and two\ntypes of entries: checklists and notes.\n\nSide swipe an entry to delete and long\npress to edit.\n\nYou too can todo with Utudu!\n"
            },
            "1": {
                "name": "Groceries",
                "show_checked": "0",
                "type": "list",
                "modified": "1390760047000",
                "category": "0",
                "next_item_index": "2",
                "items": {
                    "0": {
                        "name": "milk",
                        "checked": "1",
                        "note": "always get 2%"
                    },
                    "1": {
                        "name": "eggs",
                        "checked": "0",
                        "note": ""
                    }
                }
            },
            "2": {
                "name": "Travel",
                "show_checked": "0",
                "type": "list",
                "modified": "1390759987000",
                "category": "1",
                "next_item_index": "3",
                "items": {
                    "0": {
                        "name": "toothbrush",
                        "checked": "0",
                        "note": ""
                    },
                    "1": {
                        "name": "toothpaste",
                        "checked": "0",
                        "note": ""
                    },
                    "2": {
                        "name": "hairbrush",
                        "checked": "0",
                        "note": ""
                    }
                }
            }
        },
        "categories": { // should not include "-1"
            "0": "today",
            "1": "week",
            "2": "other"
        }
    }

    // Declare a document
    U1db.Document {
        database: db
        docId: "items"
        id: items
        create: true
        defaults: db_defaults
    }


    //
    // Items API
    //

    //
    // Category functions
    //

    // find index for a given category
    function getCategoryIndex(category) {
        if (category === uncategorized) {
            return -1
        }
        for (var idx in items.contents["categories"]) {
            if (items.contents["categories"][idx] === category) {
                return idx
            }
        }
        Util.error("getCategoryIndex(): category '" + category +
                   "' does not exist")

        return -1
    }

    // find category for a given index
    function getCategory(idx) {
        if (items.contents["categories"][idx] === undefined) {
            Util.error("getCategory(): idx '" + idx + "' does not exist")
            return -1
        }
        return items.contents["categories"][idx]
    }

    // return list of categories
    function getCategories() {
        var c = []
        for (var idx in items.contents["categories"]) {
            c.push(items.contents["categories"][idx])
        }
        c.sort()
        return c
    }

    function addCategory(category) {
        Util.debug("addCategory()")
        if (category === "-1") { // Undefined/uncategorized
            Util.error("addCategory(): may not use '-1' as category")
            return false
        } else if (category === "") {
            Util.error("addCategory(): may not use empty category")
            return false
        } else if (category === uncategorized) {
            Util.error("addCategory(): may not use '" + category +
                       "' as category")
            return false
        }

        var cat_idx = getCategoryIndex(category)
        if (cat_idx >= 0) {
            Util.error("addCategory(): category '" + category +
                       "'already exists")
            return false
        }

        var idx = items.contents["next_category_index"]
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["next_category_index"] = (idx * 1 + 1).toString()
        tmp["categories"][idx] = category

        //items.contents = tmp
        db.putDoc(tmp, "items")

        return true
    }

    function deleteCategory(idx) {
        Util.debug("deleteCategory()")
        var category = getCategory(idx)
        if (category < 0) {
            return false
        }

        //var tmp = items.contents
        var tmp = db.getDoc("items")

        // Adjust category for any entries with this category to be
        // uncategorized
        var entries = getEntryIndexesByCategory(category)
        for (var i = 0; i < entries.length; i++) {
            tmp["entries"][entries[i]]["category"] = "-1"
        }

        delete tmp["categories"][idx]
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function setCategoryName(idx, text) {
        Util.debug("setCategoryName('" + idx + ", '" + text + "')")
        if (items.contents["categories"][idx] === undefined) {
            return false
        }

        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["categories"][idx] = text
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }
    //
    // entry items functions
    //

    function getNoteTextByEntry(idx) {
        Util.debug("getNoteTextByEntry(" + idx + ")")
        if (idx === "") {
            return ""
        }
        if (items.contents["entries"][idx] === undefined) {
            return ""
        }
        if (items.contents["entries"][idx]["type"] !== "note") {
            Util.error("getNoteTextEntry(): entry idx '" + idx + "' not a note")
            return ""
        }
        return items.contents["entries"][idx]["text"]
    }

    function setNoteTextByEntry(idx, text) {
        Util.debug("setNoteTextByEntry(" + idx + ")")
        if (idx === "") {
            Util.error("setNoteTextByEntry(): idx is empty")
            return false
        }
        if (items.contents["entries"][idx] === undefined) {
            Util.error("setNoteTextByEntry(): idx '" + idx + "' does not exist")
            return false
        }
        if (items.contents["entries"][idx]["type"] !== "note") {
            Util.error("setNoteTextByEntry(): entry idx '" + idx + "' not a note")
            return false
        }

        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][idx]["text"] = text
        //items.contents = tmp
        db.putDoc(tmp, "items")

        return true
    }

    function getItemsByEntry(idx) {
        Util.debug("getItemsByEntry(" + idx + ")")
        var items_arr = []

        if (idx === "") {
            return items_arr
        }
        if (items.contents["entries"][idx] === undefined) {
            return items_arr
        }
        if (items.contents["entries"][idx]["type"] !== "list") {
            Util.error("getItemsByEntry(): entry idx '" + idx + "' not a list")
            return items_arr
        }

        // return array of items sorted by index
        var indexes = Object.keys(items.contents["entries"][idx]["items"])
        indexes.sort(function(a,b){return a-b})
        for (var i = 0; i < indexes.length; i++) {
            var item_idx = indexes[i]
            var item = items.contents["entries"][idx]["items"][item_idx]
            // FIXME: add this so the ListModel has it
            item["listModelIndex"] = item_idx
            items_arr.push(item)
        }

        return items_arr
    }

    function addListItem(idx, s) {
        Util.debug("addListItem(" + idx + ", " + s + ", " + items.contents["entries"][idx]["next_item_index"] + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("addListItem(): idx '" + idx + "' does not exist")
            return null
        }

        var next_idx = items.contents["entries"][idx]["next_item_index"]
        var tmp = items.contents
        tmp["entries"][idx]["items"][next_idx] = {}
        tmp["entries"][idx]["items"][next_idx]["name"] = s
        tmp["entries"][idx]["items"][next_idx]["checked"] = "0"
        tmp["entries"][idx]["items"][next_idx]["note"] = ""
        tmp["entries"][idx]["next_item_index"] = (next_idx * 1 + 1).toString()
        items.contents = tmp

        // FIXME: add this so the ListModel has it
        tmp["entries"][idx]["items"][next_idx]["listModelIndex"] = next_idx
        return tmp["entries"][idx]["items"][next_idx]
    }

    function deleteListItem(idx, item_idx) {
        Util.debug("deleteListItem(" + idx + ", " + item_idx + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("deleteListItem(): idx '" + idx + "' does not exist")
            return false
        }
        if (items.contents["entries"][idx]["items"][item_idx] === undefined) {
            Util.error("deleteListItem(): item_idx '" + item_idx + "' does not exist")
            return false
        }

        var tmp = db.getDoc("items")
        delete tmp["entries"][idx]["items"][item_idx]
        db.putDoc(tmp, "items")
        return true
    }

    function setListItemChecked(entry_idx, item_idx, checked) {
        Util.debug("setListItemChecked(" + entry_idx + ", " + item_idx +
                   ", " + checked + ")")
        if (items.contents["entries"][entry_idx] === undefined || entry_idx === "") {
            Util.error("setListItemChecked(): entry_idx '" + entry_idx +
                       "' does not exist")
            return -1
        }
        if (items.contents["entries"][entry_idx]["items"][item_idx] === undefined) {
            Util.error("setListItemChecked(): item '" + item_idx +
                       "' does not exist")
            return -1
        }
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][entry_idx]["items"][item_idx]["checked"] = checked
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function setListItemName(entry_idx, item_idx, text) {
        Util.debug("setListItemName(" + entry_idx + ", " + item_idx +
                   ", " + text + ")")
        if (items.contents["entries"][entry_idx] === undefined || entry_idx === "") {
            Util.error("setListItemName(): entry_idx '" + entry_idx +
                       "' does not exist")
            return false
        }
        if (items.contents["entries"][entry_idx]["items"][item_idx] === undefined) {
            Util.error("setListItemName(): item '" + item_idx +
                       "' does not exist")
            return false
        }
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][entry_idx]["items"][item_idx]["name"] = text
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    //
    // entries functions
    //

    // category should be category name or storage.uncategorized for all
    function getEntryIndexesByCategory(category) {
        var e = []
        var cat_idx = null

        // if category specified, then find the index, if it can't be found,
        // return empty list
        if (category === "-1") { // Using "-1" explicitly is an error
            return e
        } else if (category !== uncategorized && category !== "") {
            cat_idx = getCategoryIndex(category)
            if (cat_idx < 0) {
                return e
            }
        }

        // return array of items sorted by index
        var indexes = Object.keys(items.contents["entries"])
        indexes.sort(function(a,b){return a-b})
        for (var i = 0; i < indexes.length; i++) {
            var idx = indexes[i]
            // cat_idx is null when category is storage.uncategorized or ""
            if (cat_idx === null ||
                items.contents["entries"][idx]["category"] === cat_idx) {
                e.push(idx)
            }
        }
        return e
    }

    // Return list of entries by categories
    function getEntriesByCategory(category) {
        var entries_arr = []
        var cat_idx = null

        // if category specified, then find the index, if it can't be found,
        // return
        if (category !== uncategorized && category !== "") {
            cat_idx = getCategoryIndex(category)
            if (cat_idx < 0) {
                return entries_arr
            }
        }

        // return array of items sorted by index
        var indexes = Object.keys(items.contents["entries"])
        indexes.sort(function(a,b){return a-b})
        for (var i = 0; i < indexes.length; i++) {
            var idx = indexes[i]
            // cat_idx is null when category is storage.uncategorized
            if (cat_idx === null ||
                items.contents["entries"][idx]["category"] === cat_idx) {
                var entry = items.contents["entries"][idx]
                // FIXME: add this so the ListModel has it
                entry["listModelIndex"] = idx
                entries_arr.push(entry)
            }
        }

        return entries_arr
    }

    function getEntryName(idx) {
        Util.debug("getEntryName(" + idx + ")")
        if (items.contents["entries"][idx] === undefined) {
            return ""
        }
        return items.contents["entries"][idx]["name"]
    }

    function setEntryName(idx, text) {
        Util.debug("setEntryName(" + idx + ", '" + text + "')")
        if (items.contents["entries"][idx] === undefined) {
            return false
        }
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][idx]["name"] = text
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function addEntry(entry, category, type) {
        Util.debug("addEntry()")
        var cat_idx = getCategoryIndex(category)
        if (type !== "list" && type !== "note") {
            Util.error("type '" + type + "' is not 'list' or 'note'")
            return false
        }

        var idx = items.contents["next_entry_index"]
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["next_entry_index"] = (idx * 1 + 1).toString()
        tmp["entries"][idx] = {}
        tmp["entries"][idx]["type"] = type
        tmp["entries"][idx]["name"] = entry
        if (category === uncategorized || cat_idx < 0) {
            tmp["entries"][idx]["category"] = "-1" // Undefined
        } else {
            tmp["entries"][idx]["category"] = cat_idx.toString()
        }
        // modified is milliseconds since epoch (divide by 1000 to get epoch)
        tmp["entries"][idx]["modified"] = (new Date().getTime()).toString()

        if (type === "list") {
            tmp["entries"][idx]["show_checked"] = "0"
            tmp["entries"][idx]["items"] = {}
            tmp["entries"][idx]["next_item_index"] = "0"

        } else {
            tmp["entries"][idx]["text"] = ""
        }

        //items.contents = tmp
        db.putDoc(tmp, "items")
        return idx
    }


    function deleteEntry(idx) {
        Util.debug("deleteEntry(" + idx + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("deleteEntry(): idx '" + idx + "' does not exist")
            return false
        }
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        delete tmp["entries"][idx]
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function getEntryCategory(idx) {
        Util.debug("getEntryCategory(" + idx + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("getEntryCategory(): idx '" + idx + "' does not exist")
            return -1
        }
        var cat = items.contents["entries"][idx]["category"]
        if (cat === "-1") {
            cat = uncategorized
        }
        return cat
    }

    function setEntryCategory(idx, category) {
        Util.debug("setEntryCategory(" + idx + ", '" + category + "')")
        if (items.contents["entries"][idx] === undefined) {
            return false
        }
        var cat_idx = getCategoryIndex(category)
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][idx]["category"] = cat_idx
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function getEntryShowChecked(idx) {
        Util.debug("getEntryShowChecked(" + idx + ")")
        if (items.contents["entries"][idx] === undefined || idx === "") {
            Util.error("getEntryShowChecked(): idx '" + idx + "' does not exist")
            return -1
        }
        if (items.contents["entries"][idx]["show_checked"] === "1") {
            return true
        }
        return false
    }

    function setEntryShowChecked(idx, show_checked) {
        Util.debug("setEntryShowChecked(" + idx + ", " + show_checked + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("getEntryShowChecked(): idx '" + idx + "' does not exist")
            return false
        }
        //var tmp = items.contents
        var tmp = db.getDoc("items")
        tmp["entries"][idx]["show_checked"] = show_checked
        //items.contents = tmp
        db.putDoc(tmp, "items")
        return true
    }

    function getEntryCategoryName(idx) {
        Util.debug("getEntryCategoryName(" + idx + ")")
        var cat_idx = getEntryCategory(idx)
        if (idx < 0) {
            return -1
        }
        return getCategory(cat_idx)
    }

    function isEntryList(idx) {
        Util.debug("isEntryList(" + idx + ")")
        if (items.contents["entries"][idx] === undefined) {
            Util.error("isEntryList(): idx '" + idx + "' does not exist")
            return false
        }

        if (items.contents["entries"][idx]["type"] === "list") {
            return true
        }
        return false
    }
}
