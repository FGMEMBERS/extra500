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
#      Date: 2013-06-16
#
#      Last change:      Eric van den Berg
#      Date:             2014-02-03
#

# NOTE: AP messages are in the autopilot nasal file

# ENGINE Messages: the .../event/whatever is set in the extra500-system-indication.xml where engine parameters are calculated

setlistener("/fdm/jsbsim/aircraft/events/OP130", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/OP130") == 1 ) {
		UI.msg.warning("Oil pressure is above 130psi. Wait until pressure drops below before increasing power or engine damage will occur.");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TRQ111", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/TRQ111") == 1 ) {
		UI.msg.warning("TRQ limit is 111%. Engine and propeller damage may occur.");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TRQ92", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/TRQ92") == 1 ) {
		UI.msg.caution("Maximum continuous TRQ limit is 92%. Up to 111% is permissible for 5 minutes at take-off");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT927", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/TOT927") == 1 ) {
		UI.msg.warning("Congratulations on your (~$300.000) overheated engine. Make sure TOT<100degC and add fuel N1 > 12%");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT810", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/TOT810") == 1 ) {
		UI.msg.warning("TOT limit is 810degC. Engine damage will occur");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT752", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/TOT752") == 1 ) {
		UI.msg.caution("Maximum continuous TOT limit is 752degC. Up to 810degC is permissible for 5 minutes at take-off");
	}
 }, 1, 0);


# GEAR and FLAP messages: event properties are set in extra500-system-indication.xml

setlistener("/fdm/jsbsim/aircraft/events/GEAR140", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/GEAR140") == 1 ) {
		UI.msg.warning("At airspeeds > 140 KIAS, the gear must be retracted");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/FLAPS30", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/FLAPS30") == 1 ) {
		UI.msg.warning("At airspeeds > 109 KIAS, maximum flap deflection is 15deg");
	}
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/FLAPS15", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/FLAPS15") == 1 ) {
		UI.msg.warning("At airspeeds > 120 KIAS, the flaps must be retracted");
	}
 }, 1, 0);


# Other messages

setlistener("/fdm/jsbsim/aircraft/events/EXTERNALPOWER", func {
	if ( getprop("/fdm/jsbsim/aircraft/events/EXTERNALPOWER") == 1 ) {
		UI.msg.warning("You were arrested for steeling an External Power Cart. CRTL-E to disconnect.");
	}
 }, 1, 0);
