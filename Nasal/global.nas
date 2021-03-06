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
#      Date:             05.07.13
#


# print("\n\n");
# print("##########################################################");
# print("#       _____                                            #"); 
# print("#      / ___/    __                __________  ____      #");
# print("#     / /__  __ / /__________ _   / ____/ __ \/ __ \     #");
# print("#    / __| |/_// __/ ___/ __ `/  /___ \/ / / / / / /     #");
# print("#   / /_ >  < / /_/ /  / /_/ /   ___/ / /_/ / /_/ /      #");
# print("#  /____/_/|_|\__/_/   \__,_/  /_____/\____/\____/       #");
# print("#                                                        #");
# print("##########################################################");
# print("\n\n");

# should be within default terminal size 80x40

print("\n\n");
print("                                                      @                         ");
print("                                                       #+                       ");
print("                                                        ##                      ");
print("                                                         ##.                    ");
print("                                                          ##+                   ");
print("     _____                                                 ##@                  ");
print("    / ___/    __                __________  ____    ,#@#;.@####         @:      ");
print("   / /__  __ / /__________ _   / ____/ __ \/ __ \  +++##########@        '###   ");
print("  / __| |/_// __/ ___/ __ `/  /___ \/ / / / / / /   +#############@     '###@   ");
print(" / /_ >  < / /_/ /  / /_/ /   ___/ / /_/ / /_/ /     +################ @###::#  ");
print("/____/_/|_|\__/_/   \__,_/  /_____/\____/\____/        '##################+   @;");
print("                                                          '@##############      ");
print("                                                                  '''###@       ");
print("____________________________________________________________________  @#;  ____ ");
print("                                                                       :#@      ");
print("                                           D-EKEW, D-LEON, D-STHO        ##     ");
print("                                                                          ##'   ");
print("                                                                            #   ");
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

var cycle = func(value=0,min=0,max=1,step=1){
	value += step;
	if(value > max) {value = min;}
	if(value < min) {value = max;}
	return value;
}

var norm = func(value,min=0.0,max=0.0){
	value = (value-min) / (max-min);
	if(value < 0) {value = 0;}
	if(value > 1.0) {value = 1.0;}
	return value;
}

var formatTime = func(daysec,format="H:i"){
	daysec = math.mod(daysec,86400);
	var hour = daysec/3600;
	var min =  math.mod(daysec,3600)/60;
	var timeString = "";
	
	if(format == "H:i:s"){
		var sec =  math.mod(daysec,60);
		timeString = sprintf("%02u:%02u:%02u",hour,min,sec);
	}elsif(format == "i:s"){
		var sec =  math.mod(daysec,60);
		timeString = sprintf("%02u:%02u",min,sec);
	}else{
		timeString = sprintf("%02u:%02u",hour,min);	
	}
	return timeString;
}

var roundInt = func(value){
	return math.floor(value + 0.5);
}

var odd = func(v){
	#debug.dump(v);
	return (math.fmod(v,2.0) != 0);
}
var even = func(v){
	#debug.dump(v);
	return (math.fmod(v,2.0) == 0);
}

var format = {
	FlightLevelInFeet : func(v){
		v = int(v / 100) * 100;
		return v;
	},
	PositiveFloat : func(v){
		if (v < 0.0){
			v = 0.0;
		}
		return v;
	},
};


