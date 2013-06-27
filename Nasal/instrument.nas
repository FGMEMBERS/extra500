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
#      Date: Jun 27 2013
#
#      Last change:      Dirk Dittmann
#      Date:             27.06.13
#

var DigitalInstrumentPackageClass = {
	new : func(root,name,watt=12.0){
		var m = { 
			parents : [
				DigitalInstrumentPackageClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		
		#m.nGenAmps = props.globals.initNode("extra500/electric/eBox/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		#m.nBatAmps = props.globals.initNode("extra500/electric/eBox/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		m.nIAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m.nFuelTemp = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FT-degC",0.0,"DOUBLE");
		m.nFuelPress = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FP-psi",0.0,"DOUBLE");
		
		m.nIndicatedVDC = m._nRoot.initNode("indicatedVDC",0.0,"DOUBLE");
		m.nIndicatedGEN = m._nRoot.initNode("indicatedGEN",0.0,"DOUBLE");
		m.nIndicatedBAT = m._nRoot.initNode("indicatedBAT",0.0,"DOUBLE");
		
		m.nIndicatedIAT = m._nRoot.initNode("indicatedIAT",0.0,"DOUBLE");
		m.nIndicatedFuelTemp = m._nRoot.initNode("indicatedFuelTemp",0.0,"DOUBLE");
		m.nIndicatedFuelPress = m._nRoot.initNode("indicatedFuelPress",0.0,"DOUBLE");
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = 0;
		m.timerLoop = maketimer(1.0,m,DigitalInstrumentPackageClass.update);
		
		
		return m;
	},
	update : func(){
		
		me.nIndicatedVDC.setValue(eSystem._volt);
		me.nIndicatedGEN.setValue(eSystem.source.Generator._ampere);
		me.nIndicatedBAT.setValue(eSystem.source.Battery._ampere);
		
		me.nIndicatedFuelPress.setValue(me.nFuelPress.getValue());
		me.nIndicatedFuelTemp.setValue(me.nFuelTemp.getValue());
		me.nIndicatedIAT.setValue(me.nIAT.getValue());
	}
	
};


var engineInstrumentPackage = ConsumerClass.new("extra500/instrumentation/EIP","Engine Instrument Package",24.0);
var digitalInstrumentPackage = DigitalInstrumentPackageClass.new("extra500/instrumentation/DIP","Digital Instrument Package",12.0);


eSystem.circuitBreaker.ENG_INST_1.addOutput(engineInstrumentPackage);
eSystem.circuitBreaker.ENG_INST_2.addOutput(engineInstrumentPackage);

eSystem.circuitBreaker.DIP_1.addOutput(digitalInstrumentPackage);
eSystem.circuitBreaker.DIP_2.addOutput(digitalInstrumentPackage);



engineInstrumentPackage.setListerners();
digitalInstrumentPackage.setListerners();