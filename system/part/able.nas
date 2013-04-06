 
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
		
		m.nElectric = nRoot.getNode("electric",1);
		
		m.nAmpere = m.nElectric.initNode("ampere",0.0,"DOUBLE");
		m.nVolt = m.nElectric.initNode("volt",0.0,"DOUBLE");
		m.nMinVolt = m.nElectric.initNode("voltMin",18.0,"DOUBLE");
		m.nWatt = m.nElectric.initNode("watt",0.0001,"DOUBLE");
		m.isPowered = 0;
		m.volt = 0;
		m.minVolt = 18;
		m.ampere = 0;
		m.watt = 0.0001;
		
		return m;
	},
	electricConfig : func(minVolt,watt){
		me.minVolt = minVolt;
		me.watt = watt;
		me.nMinVolt.setValue(me.minVolt);
		me.nWatt.setValue(me.watt);		
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
	hasPower : func(volt=nil){
		if (volt!=nil){
			if (me.volt >= volt){
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