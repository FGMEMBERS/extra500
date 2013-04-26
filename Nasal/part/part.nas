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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#

# The Basic Part all Parts should derivate from this 
var Part = {
	new : func(nRoot,name){
		var m = {parents:[
			Part,
			ServiceAble.new(nRoot)
		]};
		m.nRoot = nRoot;
		m.nRoot.initNode("name",name,"STRING");
		m.name = name;
		return m;
	},
};

# List of Intefaces(Able)
var aListSimStateAble = [];
var aListElectricFuseAble = [];
