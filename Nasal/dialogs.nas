#    This file is part of extra500
#
#    extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    extra500 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 23 2013
#
#      Last change:      Dirk Dittmann
#      Date:             14.03.2014
#



var autopilot = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/extra500/Dialogs/autopilot.xml");

var radios = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/extra500/Dialogs/radios.xml");

var checklist = gui.Dialog.new("/sim/gui/dialogs/checklist/dialog",
        "Aircraft/extra500/Dialogs/checklist.xml");

var extra500config = gui.Dialog.new("/sim/gui/dialogs/extra500config/dialog",
        "Aircraft/extra500/Dialogs/Config.xml");

var extra500about = gui.Dialog.new("/sim/gui/dialogs/extra500about/dialog",
        "Aircraft/extra500/Dialogs/about.xml");


gui.menuBind("fuel-and-payload", "Dialogs.fuelPayload.toggle();");