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
#      Last change:      Dirk Dittmann
#      Date:             31.01.2015
#
var star = ['ARLON', 'BACON', 'BLOOMI', 'BLOOML', 'CACAO', 'CACHE', 'CAPEN', 'CAPES', 'CREAM', 'DARKS', 'DATUM', 'EGARI', 'KAIHO', 'KENJI', 'MACRO', 'NAGAI', 'NYLON', 'SINGO', 'STEAM'];
var approach = ['ILSY34R', 'ILSZ34R', 'LOCY34R', 'LOCZ34R'];
#{ '34L': <runway>, '16R': <runway>, '34R': <runway>, 22: <runway>, 23: <runway>, 05: <runway>, '16L': <runway>, 04: <runway> }

var createFPL = func(){
	var fpl = flightplan();
	
	fpl.destination_runway = fpl.destination.runways['34R'];
	fpl.star = 'BACON';
	#fpl.approach = 'ILSY34R';
	fpl.approach = 'DEFAULT';
	

};

var createFPL = func(){
	var fpl = flightplan();
	
	fpl.destination_runway = fpl.destination.runways['25L'];
	fpl.star = 'DEFAULT';
	fpl.approach = 'DEFAULT';
	

};