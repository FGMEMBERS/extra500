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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             29.04.13
#
var SimStateAble = {
	new : func(nRoot,type,default=0){
		var m = {parents:[
			SimStateAble
		]};
		m.default = default;
		m.state = m.default;
		m.nState = nRoot.initNode("state",m.state,type);
		return m;
	},
	simReset : func(){
		me.nState.setValue(me.state);
		me.state = me.default;
	},
	simUpdate : func(){
		me.nState.setValue(me.state);
	},
	
};

var ServiceAble = {
	new : func(nRoot){
		var m = {parents:[
			ServiceAble
		]};
		
		m.nService = nRoot.getNode("service",1);
		
		m.nQos  = m.nService.initNode("qos",1.0,"DOUBLE");
		m.nLifetime = m.nService.initNode("lifetime",72000000,"INT");
		m.nBuildin = m.nService.initNode("buildin",0,"INT");
		m.nSerialNumber = m.nService.initNode("SerialNumber","","STRING");
		m.qos = 0.99;
		return m;
	},
	serviceConfig : func(serialnumber,lifetime,buildin){
		me.nSerialNumber.setValue(serialnumber);
		me.nLifetime.setValue(lifetime);
		me.nBuildin.setValue(buildin);
	},
	serviceLife : func(utcSec){
			used = utcSec - me.nBuildin.getValue();
			
			qos = 1.0 - (used / me.nLifetime.getValue());
			
			if (qos < 0.0){	qos = 0.0; }
			if (qos > 1.0){ qos = 1.0; }
			
			me.nQos.setValue(qos);
			me.qos = qos;
			
	},
};

var ElectricAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricAble
			
		]};
		m.isPowered 	= 0.0;
		m.volt 		= 0.0;
		m.voltMin 	= 18.0;
		m.voltMax 	= 30.0;
		m.voltDelta	= 0.0;
		m.ampere 	= 0.0;
		m.watt 		= 0.0001;
		m.resistor	= 0.01;
		
		m.nElectric = nRoot.getNode("electric",1);
		
		m.nAmpere 	= m.nElectric.initNode("ampere",m.ampere,"DOUBLE");
		m.nVolt 	= m.nElectric.initNode("volt",m.volt,"DOUBLE");
		m.nResistor 	= m.nElectric.initNode("resistor",m.resistor,"DOUBLE");
		m.nMinVolt 	= m.nElectric.initNode("voltMin",m.voltMin,"DOUBLE");
		m.nMaxVolt 	= m.nElectric.initNode("voltMax",m.voltMax,"DOUBLE");
		m.nWatt 	= m.nElectric.initNode("watt",m.watt,"DOUBLE");
		
		return m;
	},
	electricConfig : func(voltMin,voltMax){
		
		me.voltMin 	= voltMin;
		me.voltMax 	= voltMax;
		me.voltDelta	= voltMax-voltMin;
		
		me.nMinVolt.setValue(me.voltMin);
		me.nMaxVolt.setValue(me.voltMax);
		
	},
	setResistor : func(resistor){
		me.resistor	= resistor;
		me.nResistor.setValue(me.resistor);
	},
	setPower : func(volt,watt){
		me.resistor	= volt / (watt / volt)  ;
		me.nResistor.setValue(me.resistor);
		
	},
	electricWork : func(electron) {
		var watt = 0.0;
		me.setVolt(electron.volt * (me.resistor / electron.resistor));
		me.setAmpere(electron.ampere);
		watt = me.volt * electron.ampere;
		me.setWatt(watt);
		return watt;
	},
	setVolt : func(value){
		me.volt = value;
		me.nVolt.setValue(value);
	},
	setMinVolt : func(value){
		me.voltMin = value;
		me.nMinVolt.setValue(value);
	},
	setAmpere : func(value){
		me.ampere = value;
		me.nAmpere.setValue(value);
	},
	setWatt : func(value){
		me.watt = value;
		me.nWatt.setValue(value);
	},
	hasPower : func(voltMin=nil){
		if (voltMin!=nil){
			if (me.volt >= voltMin){
				me.isPowered = 1;
			}else{
				me.isPowered = 0;
			}
		}else{
			if (me.volt >= me.voltMin){
				me.isPowered = 1;
			}else{
				me.isPowered = 0;
			}
		}
		return me.isPowered;
	}
	
};

var ElectricFuseAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricFuseAble
			
		]};
		
		m.nFuse = nRoot.getNode("fuse",1);
		
		m.ampereMax = 10.0;
		m.ampereUsed = 0.0;
		m.state = 1;
		m.nAmpereUsed = m.nFuse.initNode("ampereUsed",0.0,"DOUBLE");
		m.nAmpereMax = m.nFuse.initNode("ampereMax",m.ampereMax,"DOUBLE");
		m.nAmperePeak = m.nFuse.initNode("amperePeak",0.0,"DOUBLE");
		
		
		return m;
	},
	fuseAddAmpere : func(ampere){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricFuseAble.fuseAddAmpere("~ampere~") ... ");
		
		me.ampereUsed += ampere;
		me.nAmpereUsed.setValue(me.ampereUsed);
		
		if (me.nAmperePeak.getValue() < me.ampereUsed){
			me.nAmperePeak.setValue(me.ampereUsed)
		}
		
		if (me.ampereUsed > me.ampereMax){
			me.state = 0;
			return 1;
		}
		return 0;
	},
	fuseConfig : func(ampereMax){
		me.ampereMax = ampereMax;
		me.nAmpereMax.setValue(me.ampereMax);
	},
	fuseReset : func(){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricFuseAble.fuseReset() ... ");
		me.ampereUsed = 0.0;
		#me.nAmpereUsed.setValue(me.ampereUsed);
	},
};


var GearAble = {
	new : func(ratio=1.0){
		var m = {parents:[
			GearAble
			
		]};
		m.gearRatio = ratio;
		m.gearOutput = 0.0;
		m.gearOutputShaft = nil;
		return m;
	},
	driveShaft : func(input){
		me.gearOutput = input * me.gearRatio;
		if(me.gearOutputShaft != nil){
			me.gearOutputShaft.driveShaft(me.gearOutput);
		}
	},
	connectOutputShaft : func (gearAble){
		me.gearOutputShaft = gearAble;
	},
}