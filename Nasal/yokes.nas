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
#      Authors: Eric van den Berg
#      Date: 09.05.2014
#
#      Last change:       
#      Date:             
#
#
# 
#
	var onPTTpilot = func(value){
		setprop("/instrumentation/comm/ptt",value);
		setprop("/extra500/yokes/ptt-pilot/pressed",value);
	}
	var onPTTcopilot = func(value){
		setprop("/instrumentation/comm/ptt",value);
		setprop("/extra500/yokes/ptt-copilot/pressed",value);
	}

UI.register("ptt pilot true", 	func{extra500.onPTTpilot(1); } );
UI.register("ptt pilot false",	func{extra500.onPTTpilot(0); } );

UI.register("ptt copilot true", 	func{extra500.onPTTcopilot(1); } );
UI.register("ptt copilot false",	func{extra500.onPTTcopilot(0); } );
