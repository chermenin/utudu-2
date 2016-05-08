/* util.js
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

var debugging = true

function debug(m) {
    if (debugging === true) {
        print("[DEBUG] " + m)
    }
}

function error(m) {
    console.log("[ERROR] " + m)
}

// *sigh*
// would rather just do:
//   iconSource: "image://theme/select"
// but unfortunately that doesn't seem to work well with pure QML on the
// desktop
function getIcon(s) {
    return Qt.resolvedUrl("/usr/share/icons/ubuntu-mobile/actions/scalable/" +
                          s + ".svg")
}
