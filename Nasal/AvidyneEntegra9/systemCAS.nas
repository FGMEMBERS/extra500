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
#      Date: 01.10.16
#
#      Last change:      Dirk Dittmann
#      Date:             01.10.16
#

var SystemCasAlert = {
	new: func(type, name, headline="", detail="", page =""){
		var m = {parents:[SystemCasAlert,ListenerClass.new()]};
		m._class 	= "SystemCasAlert";
		
		if(detail==""){
			detail = headline;
		}
		m._type		= type;
		m._name 	= name;
		m._headline 	= headline;
		m._detail 	= detail;
		m._active 	= 0;
		m._activated 	= systime();
		m._acknowledged	= 0;
		m._duration 	= 0;
		m._page		= "";
		
		m._ptree	= {
			name		: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/name",m._name,"STRING"),
			type		: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/type",m._type,"STRING"),
			headline	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/headline",m._headline,"STRING"),
			detail		: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/detail",m._detail,"STRING"),
			active		: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/active",m._active,"BOOL"),
			activated	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/activated",m._activated,"INT"),
			acknowledged	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/acknowledged",m._acknowledged,"BOOL"),
			duration	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/alert/"~name~"/duration",m._duration,"INT"),
		};
		
		m._headline 	= m._ptree.headline.getValue();
		m._detail 	= m._ptree.detail.getValue();
		m._active 	= m._ptree.active.getValue();
		m._activated 	= m._ptree.activated.getValue();
		m._acknowledged	= m._ptree.acknowledged.getValue();
		m._duration 	= m._ptree.duration.getValue();
		
		
		return m;
	},
	setActive : func(value=nil){
		#print(sprintf("SystemCasAlert::setActive(%i) ... ",value));
		if (value == nil){
			me._active = me._active == 1 ? 0 : 1;
		}else{
			me._active = value ? 1 : 0;
		}
		
		me._ptree.active.setBoolValue(me._active);
	},
	setAcknowledged : func(value=nil){
		#print(sprintf("SystemCasAlert::setAcknowledged(%i) ... ",value));
		if (value == nil){
			me._acknowledged = me._acknowledged == 1 ? 0 : 1;
		}else{
			me._acknowledged = value ? 1 : 0;
		}
		
		me._ptree.acknowledged.setBoolValue(me._acknowledged);
	},
	setListeners : func(instance=me){
		append(me._listeners, setlistener(me._ptree.active,func(n){me._onActiveChange(n)},1,0));
	},
	
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();
	},
	
	_onActiveChange : func(n){
		if (n.getValue()){
			me._activated 		= systime();
			me._acknowledged	= 0;
			me._ptree.acknowledged.setValue(me._acknowledged);
		}else{
			me._duration += (systime() - me._activated);
			me._activated = 0;
			me._ptree.duration.setValue(me._duration);
		}	
		me._ptree.activated.setValue(me._activated);
	},
	
	
	getDuration : func(){
		
		var duration = me._duration;
		if(me._activated > 0){
			
			duration += (systime() - me._activated);
		}
		
		return duration; 
	},
	
	getLamp : func(){
		if(me._type == CAS_LEVEL.WARNING){
			return ((level._active==0) and (me._acknowledged==1));
		}else{
			return ((level._active==0) or (me._acknowledged==1));
		}
	},
	
	
};

###
### Alert ID 1 byte Type 3 byte unique ID
###
CAS_LEVEL = {};
CAS_LEVEL.ADVISORY	= "advisory";
CAS_LEVEL.CAUTION	= "caution";
CAS_LEVEL.WARNING	= "warning";

CAS = {};
CAS.HIGH_OIL_PRESS 	= "OP130";
CAS.TRQ111		= "TRQ111";
CAS.TRQ92		= "TRQ92";
CAS.TOT927		= "TOT927";
CAS.TOT810		= "TOT810";
CAS.TOT752		= "TOT752";
CAS.GEAR140		= "GEAR140";
CAS.FLAPS30		= "FLAPS30";
CAS.FLAPS15		= "FLAPS15";
CAS.OVER_G_FLUP		= "overgflup";
CAS.OVER_G_FLEXT	= "overgflext";

CAS.TEST_ADVISORY_1	= "TEST_ADVISORY_1";
CAS.TEST_ADVISORY_2	= "TEST_ADVISORY_2";
CAS.TEST_CAUTION_1	= "TEST_CAUTION_1";
CAS.TEST_CAUTION_2	= "TEST_CAUTION_2";
CAS.TEST_WARNING_1	= "TEST_WARNING_1";
CAS.TEST_WARNING_2	= "TEST_WARNING_2";

#
# POH 9 System ALerts
#  caution-warning alerting system (CAS) 
#
var SystemCAS = {
	new: func(){
		var m = {parents:[SystemCAS,ListenerClass.new()]};
		m._class 	= "SystemCAS";
				
		m._ptree = {
			testAdvisory1   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/advisory1",0,"BOOL"),
			testAdvisory2   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/advisory2",0,"BOOL"),
			testCaution1   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/caution1",0,"BOOL"),
			testCaution2   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/caution2",0,"BOOL"),
			testWarning1   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/warning1",0,"BOOL"),
			testWarning2   : props.globals.initNode("/extra500/instrumentation/IFD/CAS/Test/warning2",0,"BOOL"),
			
		};
		
		m._level = {};
	
		foreach(var t;keys(CAS_LEVEL)){
			m._level[CAS_LEVEL[t]]	= {
				type	  	: CAS_LEVEL[t],
				nActive   	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/"~CAS_LEVEL[t]~"/active",0,"BOOL"),
				nCount	  	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/"~CAS_LEVEL[t]~"/count",0,"INT"),
				nToAck    	: props.globals.initNode("/extra500/instrumentation/IFD/CAS/"~CAS_LEVEL[t]~"/ToAck",0,"INT"),
				active    	: 0,
				count    	: 0,
				toAck	 	: 0,
				listAlert 	: std.Vector.new(),
				stackAck  	: std.Vector.new()
			};
		}
		

		m._alert = {};
				
		return m;
	},
	init : func(){
		me.addAlert(CAS_LEVEL.WARNING	,CAS.HIGH_OIL_PRESS	,"High Oil Press");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.TRQ111		,"TRQ > 111%");
		me.addAlert(CAS_LEVEL.CAUTION	,CAS.TRQ92		,"TRQ > 92%");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.TOT927		,"TOT > 927°C");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.TOT810		,"TOT > 810°C");
		me.addAlert(CAS_LEVEL.CAUTION	,CAS.TOT752		,"TOT > 752°C");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.GEAR140		,"Gear 140 KIAS");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.FLAPS30		,"Flap 109 KIAS");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.FLAPS15		,"Flap 120 KIAS");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.OVER_G_FLUP	,"Over G");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.OVER_G_FLEXT	,"Over G");
		
		me.addAlert(CAS_LEVEL.ADVISORY	,CAS.TEST_ADVISORY_1		,"ADVISORY 01");
		me.addAlert(CAS_LEVEL.ADVISORY	,CAS.TEST_ADVISORY_2		,"ADVISORY 02");
		me.addAlert(CAS_LEVEL.CAUTION	,CAS.TEST_CAUTION_1		,"CAUTION 01");
		me.addAlert(CAS_LEVEL.CAUTION	,CAS.TEST_CAUTION_2		,"CAUTION 02");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.TEST_WARNING_1		,"WARNING 01");
		me.addAlert(CAS_LEVEL.WARNING	,CAS.TEST_WARNING_2		,"WARNING 02");
		
	},
	addAlert : func(type,name,headline="",detail=""){
		var casAlert = SystemCasAlert.new(type, name, headline, detail);
		casAlert.init();
		me._alert[name]	 = casAlert;
	},
	count : func(type,value){
		#print("");
		#print(sprintf("SystemCAS::count(%s,%i) ... ",type,value));
		
		
		me._level[type].count += value;
		if(me._level[type].count<0){
			me._level[type].count = 0;
		}
		
		me._level[type].nActive.setBoolValue((me._level[type].count>0));
		me._level[type].nCount.setValue(me._level[type].count);
	
	},
	alert : func (name,value){
		#print("");
		#print(sprintf("SystemCAS::alert(%s,%d) ... ",name,value));
		if(contains(me._alert,name)){
			var casAlert = me._alert[name];
			var level = me._level[casAlert._type];
				
			casAlert.setActive(value);
			
			if(value){
				if(!level.listAlert.contains(name)){
					level.listAlert.append(name);
					level.count = level.listAlert.size();
					level.nCount.setValue(level.count);
				}
				if(!level.stackAck.contains(name)){
					level.stackAck.append(name);
					level.toAck = level.stackAck.size();
					level.nToAck.setValue(level.toAck);
				}
			}else{
				if(level.listAlert.contains(name)){
					level.listAlert.remove(name);
					
				}
				if(level.type != CAS_LEVEL.WARNING){
					if(level.stackAck.contains(name)){
						casAlert.setAcknowledged(1);
						level.stackAck.remove(name);
					}
				}
			}
			
			### Important: first fire acknowledge listeners then Count Active listeners 
			level.toAck = level.stackAck.size();
			level.nToAck.setValue(level.toAck);
			
			level.count = level.listAlert.size();
			level.nCount.setValue(level.count);
			
			me._checkMasterLamps(level);
			
		}else{
			#print("NO Alert found to raise.");
		
		}
	},
	_checkMasterLamps : func(level){
		if(level.type == CAS_LEVEL.WARNING){
			level.active = !((level.count == 0) and (level.toAck==0));
		}else{
			level.active = !((level.count == 0) or (level.toAck==0));
		}
		
		level.nActive.setBoolValue(level.active);
	},
	getLeftAckAlert : func(){
		var index = nil;
		var alert = nil;

		index = me._level[CAS_LEVEL.ADVISORY].stackAck.first();
	
		if( index != nil){
			alert = me._alert[index];
		}
		
		return alert;
	},
	getLeftAlert : func(){
		var index = nil;
		var alert = nil;

		index = me._level[CAS_LEVEL.ADVISORY].listAlert.first();
	
		if( index != nil){
			alert = me._alert[index];
		}
		
		return alert;
	},
	getRightAckAlert : func(){
		var index = nil;
		var alert = nil;
					
		index = me._level[CAS_LEVEL.WARNING].stackAck.first();
		
		if(index == nil){
			index = me._level[CAS_LEVEL.CAUTION].stackAck.first();
		}
		
		if( index != nil){
			alert = me._alert[index];
		}
		
		return alert;
	},
	getRightAlert : func(){
		var index = nil;
		var alert = nil;
					
		index = me._level[CAS_LEVEL.WARNING].listAlert.first();
		
		if(index == nil){
			index = me._level[CAS_LEVEL.CAUTION].listAlert.first();
		}
		
		if( index != nil){
			alert = me._alert[index];
		}
		
		return alert;
	},
	ack : func(type){
		#print(sprintf("SystemCAS::ack(%s) ... ",type));
		var level = me._level[type];
		var index = level.stackAck.first();
		if(index){
			var casAlert = me._alert[index];
			casAlert.setAcknowledged(1);
			level.stackAck.pop(0);
			level.toAck = level.stackAck.size();
			level.nToAck.setValue(level.toAck);
		}
		me._checkMasterLamps(level);
		
	},
	show : func(type){
		#print(sprintf("SystemCAS::show(%s) ... ",type));
		me.ack(type);
	}
	
};







 
