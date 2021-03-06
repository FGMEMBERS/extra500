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
#      Date: May 08 2013
#
#      Last change:      Dirk Dittmann
#      Date:             08.05.13
#

# Constans for Calculations
# dynamic load from set.xml (PropertyTree)

# init modes for all nasal components 
var INIT_START 		= 1;
var INIT_STOP		= 2;
var INIT_RUN	 	= 3;
var INIT_PAUSE 	 	= 4;

# call in Aircraft namespace global.CONST.DEG2RAD
var Constant = {
	new : func(){
		var m = {parents:[
			Constant,
		]};
		return m;
		
	},
	loadProp : func(path){
		var node = props.globals.getNode(path);
		if (node != nil){
			var nChildren = node.getChildren();
			foreach(var child; nChildren) { 
				me[child.getName()] = child.getValue();
			}
		}
		
	},
	echo : func(){
		foreach(var i; keys(me)) {
			if (typeof(me[i]) == "scalar"){
				print(sprintf("%s : %s",i,me[i]));
			}
		}
	}
	
};


var CONST = Constant.new();
CONST.loadProp("/extra500/const");
#CONST.echo();




