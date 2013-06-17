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
#      Date: April 04 2013
#
#      Last change:      Dirk Dittmann
#      Date:             29.04.13
#

# print("#############################################");
# print("#                                           #");
# print("#              Extra500                     #");
# print("#                                           #");
# print("#############################################");
print("\n\n");
print("#########################################################");
print("#                 __               __________  ____     #");
print("#      ___  _  __/ /__________ _  / ____/ __ \/ __ \    #");
print("#     / _ \| |/_/ __/ ___/ __ `/ /___ \/ / / / / / /    #");
print("#    /  __/>  </ /_/ /  / /_/ /  ___/ / /_/ / /_/ /     #");
print("#    \___/_/|_|\__/_/   \__,_/ /_____/\____/\____/      #");
print("#                                                       #");
print("#########################################################");
print("\n\n");

var fnAnnounce = func(type,msg){
	if (type = "debug"){
		print (msg);
	}
}

var clamp = func(value,min=0.0,max=0.0){
	if(value < min) {value = min;}
	if(value > max) {value = max;}
	return value;
}



