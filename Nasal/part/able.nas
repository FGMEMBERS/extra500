
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
		m.minVolt 	= 18.0;
		m.maxVolt 	= 30.0;
		m.ampere 	= 0.0;
		m.watt 		= 0.0001;
		m.resistor	= 300;
		
		m.nElectric = nRoot.getNode("electric",1);
		
		m.nAmpere 	= m.nElectric.initNode("ampere",m.ampere,"DOUBLE");
		m.nVolt 	= m.nElectric.initNode("volt",m.volt,"DOUBLE");
		m.nResistor 	= m.nElectric.initNode("resistor",m.resistor,"DOUBLE");
		m.nMinVolt 	= m.nElectric.initNode("voltMin",m.minVolt,"DOUBLE");
		m.nMaxVolt 	= m.nElectric.initNode("voltMax",m.maxVolt,"DOUBLE");
		m.nWatt 	= m.nElectric.initNode("watt",m.watt,"DOUBLE");
		
		return m;
	},
	electricConfig : func(minVolt,maxVolt,watt){
		
		me.minVolt 	= minVolt;
		me.maxVolt 	= maxVolt;
		me.resistor	= maxVolt / (watt/maxVolt);
		me.watt 	= watt;
		
		me.nMinVolt.setValue(me.minVolt);
		me.nMaxVolt.setValue(me.maxVolt);
		me.nResistor.setValue(me.resistor);
		me.nWatt.setValue(me.watt);
		
	},
	electricWork : func(electron) {
		var watt = 0.0;
		me.setVolt(electron.volt * (me.resistor / electron.resistor));
		me.setAmpere(electron.ampere);
		watt = me.volt * electron.ampere;
		return watt;
	},
	setVolt : func(value){
		me.volt = value;
		me.nVolt.setValue(value);
	},
	setMinVolt : func(value){
		me.minVolt = value;
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
	hasPower : func(minVolt=nil){
		if (minVolt!=nil){
			if (me.volt >= minVolt){
				me.isPowered = 1;
			}else{
				me.isPowered = 0;
			}
		}else{
			if (me.volt >= me.minVolt){
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
		me.nAmpereUsed.setValue(me.ampereUsed);
	},
};