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
#      Last change:      Dirk Dittmann
#      Date:             01.10.16
#

# NOTE: AP messages are in the autopilot nasal file

# ENGINE Messages: the .../event/whatever is set in the extra500-system-indication.xml where engine parameters are calculated

setlistener("/fdm/jsbsim/aircraft/events/OP130", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("Oil pressure is above 130psi. Wait until pressure drops below before increasing power or engine damage will occur.");
	}
	IFD.cas.alert(IFD.CAS.HIGH_OIL_PRESS,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TRQ111", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("TRQ limit is 111%. Engine and propeller damage may occur.");
	}
	IFD.cas.alert(IFD.CAS.TRQ111,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TRQ92", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.caution("Maximum continuous TRQ limit is 92%. Up to 111% is permissible for 5 minutes at take-off");
	}
	IFD.cas.alert(IFD.CAS.TRQ92,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT927", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("Congratulations on your (~$300.000) overheated engine. Make sure TOT<100degC and add fuel N1 > 12%");
	}
	IFD.cas.alert(IFD.CAS.TOT927,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT810", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("TOT limit is 810degC. Engine damage will occur");
	}
	IFD.cas.alert(IFD.CAS.TOT810,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/TOT752", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.caution("Maximum continuous TOT limit is 752degC. Up to 810degC is permissible for 5 minutes at take-off");
	}
	IFD.cas.alert(IFD.CAS.TOT752,(value==1));
 }, 1, 0);


# GEAR and FLAP messages: event properties are set in extra500-system-indication.xml

setlistener("/fdm/jsbsim/aircraft/events/GEAR140", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("At airspeeds > 140 KIAS, the gear must be retracted");
	}
	IFD.cas.alert(IFD.CAS.GEAR140,value==1);
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/FLAPS30", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("At airspeeds > 109 KIAS, maximum flap deflection is 15deg");
	}
	IFD.cas.alert(IFD.CAS.FLAPS30,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/FLAPS15", func(n) {
	var value = n.getValue();
	if ( value == 1 ) {
		UI.msg.warning("At airspeeds > 120 KIAS, the flaps must be retracted");
	}
	IFD.cas.alert(IFD.CAS.FLAPS15,(value==1));
 }, 1, 0);

# over-g messages: event properties are set in extra500-system-indication.xml

setlistener("/fdm/jsbsim/aircraft/events/overgflup", func(n) {
	var value = n.getValue();
	print(sprintf("event.overgflup(%d) ... ",value));
	if ( value == 1 ) {
		UI.msg.warning("Over-g! With flaps up you must stay between -1.5 and +3.8g or one day your wing will break off");
	}
	IFD.cas.alert(IFD.CAS.OVER_G_FLUP,(value==1));
 }, 1, 0);

setlistener("/fdm/jsbsim/aircraft/events/overgflext", func(n) {
	var value = n.getValue();
	print(sprintf("event.overgflext(%d) ... ",value));
	if ( value == 1 ) {
		UI.msg.warning("Over-g! With flaps extended you must stay between 0.0 and +2.0g or one day your flaps (or your wing...or both) will break off");
	}
	IFD.cas.alert(IFD.CAS.OVER_G_FLEXT,(value==1));
 }, 1, 0);

# Other messages

setlistener("/fdm/jsbsim/aircraft/events/EXTERNALPOWER", func(n) {
	if ( getprop("/fdm/jsbsim/aircraft/events/EXTERNALPOWER") == 1 ) {
		UI.msg.warning("You were arrested for stealing an External Power Cart. CRTL-E to disconnect.");
	}
 }, 1, 0);


# TEST IFD Messages

setlistener("/extra500/instrumentation/IFD/CAS/Test/advisory1", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_ADVISORY_1,(n.getValue()));
 }, 1, 0);
setlistener("/extra500/instrumentation/IFD/CAS/Test/advisory2", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_ADVISORY_2,(n.getValue()));
 }, 1, 0);
setlistener("/extra500/instrumentation/IFD/CAS/Test/caution1", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_CAUTION_1,(n.getValue()));
 }, 1, 0);
setlistener("/extra500/instrumentation/IFD/CAS/Test/caution2", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_CAUTION_2,(n.getValue()));
 }, 1, 0);
setlistener("/extra500/instrumentation/IFD/CAS/Test/warning1", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_WARNING_1,(n.getValue()));
 }, 1, 0);
setlistener("/extra500/instrumentation/IFD/CAS/Test/warning2", func(n) {
	IFD.cas.alert(IFD.CAS.TEST_WARNING_2,(n.getValue()));
 }, 1, 0);



