#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 26 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#
#
#
# overloaded functions from Flightgear $fgdata/Nasal/controls.nas

var flapsDown = func(step) {
	if(step == 0) return;
	if(step > 0){
		UI.click("Flaps down");
	}else{
		UI.click("Flaps up");
	}
}