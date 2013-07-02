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
#      Date: Jul 02 2013
#
#      Last change:      Dirk Dittmann
#      Date:             02.07.13
#
# MM Page 563

var CabinClass = {
	new : func(root,name){
		var m = { 
			parents : [
				CabinClass,
				ServiceClass.new(root,name)
			]
		};
		m._nCabinPressure	= m._nRoot.initNode("hasPressureWarning",0,"BOOL");
		m._nBleedOvertemp	= m._nRoot.initNode("hasBleedOvertempWarning",0,"BOOL");
		
		return m;
	},
	init : func(){

	},
};

var cabin = CabinClass.new("/extra500/cabin","Cabin");