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
#      Date:  01.10.16
#
#      Last change:      Dirk Dittmann
#      Date:             01.10.16
#

# extends std.Vector
#print("extends std.Vector ---------");
#debug.dump(std.Vector);

std.Vector.last = func(){
	if(size(me.vector)>0){
		return me.vector[-1];
	}else{
		return nil;
		
	}
};
std.Vector.first = func(){
	if(size(me.vector)>0){
		return me.vector[0];
	}else{
		return nil;
	}
};

 
#debug.dump(std.Vector);