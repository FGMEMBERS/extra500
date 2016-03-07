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
#      Date: 31.01.2015
#
#      Last change: Dirk Dittmann      
#      Date:  31.01.2015           
#
#
# 
#

var currentViewSettings = {
	fieldOfView 	: getprop("/sim/current-view/field-of-view"),
	goalHeading 	: getprop("/sim/current-view/goal-heading-offset-deg"),
	goalPitch	: getprop("/sim/current-view/goal-pitch-offset-deg"),
	
	
};


var quickZoomView = func(){
	#print("View.quickZoomView() ...");
	var currentField 	= getprop("/sim/current-view/field-of-view");
	var quickZoomField 	= getprop("/extra500/config/view/quickZoom/field-of-view");
	
	if (currentField == quickZoomField){
		# reset to the old
		
		setprop("/sim/current-view/field-of-view",currentViewSettings.fieldOfView);
		setprop("/sim/current-view/goal-heading-offset-deg",currentViewSettings.goalHeading);
		setprop("/sim/current-view/goal-pitch-offset-deg",currentViewSettings.goalPitch);
		
		
	}else{
		# set quick view
		
		currentViewSettings.fieldOfView = getprop("/sim/current-view/field-of-view");
		currentViewSettings.goalHeading = getprop("/sim/current-view/goal-heading-offset-deg");
		currentViewSettings.goalPitch = getprop("/sim/current-view/goal-pitch-offset-deg");
		
		setprop("/sim/current-view/field-of-view",getprop("/extra500/config/view/quickZoom/field-of-view"));
		setprop("/sim/current-view/goal-heading-offset-deg",getprop("/extra500/config/view/quickZoom/goal-heading-offset-deg"));
		setprop("/sim/current-view/goal-pitch-offset-deg",getprop("/extra500/config/view/quickZoom/goal-pitch-offset-deg"));
		
	}
	

};

setlistener("/sim/current-view/view-number", func(n) {
	var v = view.current.getNode("config");
	var yOffset = v.getNode("y-offset-m", 1).getValue() or 0;
	#print("yOffset",yOffset);
	setprop("/sim/current-view/y-offset-m-config", yOffset);
}, 1);