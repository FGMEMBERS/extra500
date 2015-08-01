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
#      Date: 27.07.15
#
#	Last change:	Dirk Dittmann
#	Date:		27.07.15
#


var ServiceClass = {
	new : func(root,name,sn=nil,lifetime=72000000){
		var m = { 
			parents 	: [ServiceClass] ,
			_path		: root,
			_nRoot		: props.globals.initNode(root),
			_name		: name,
		};
		
		
		m._listeners = [];
		m._nService = m._nRoot.getNode("service",1);
		
		m._serialNumber 	= sn==nil ? "ATA-13-000" : sn ;
		m._buildin	 	= 0 ;
		m._lifetime		= lifetime;
		m._qos 			= 1.0;
		m._damage		= 0;
		m._failureCode		= 0;
		m._failureString	= "";
		
		m._failureOverStress	= 0;
		m._failureStressMap 	= {}; # {0.1:1,0.2,2} 
		m._failureStringMap 	= {};
		
		
		m._nSerialNumber 	= m._nService.initNode("SerialNumber",m._serialNumber,"STRING",1);
		m._nBuildin 		= m._nService.initNode("buildin",m._buildin,"INT");
		m._nLifetime 		= m._nService.initNode("lifetime",m._lifetime,"INT",1);
		m._nQos  		= m._nService.initNode("qos",m._qos,"DOUBLE");
		m._nDamage		= m._nService.initNode("damage",m._damage,"DOUBLE");
		m._nFailureCode		= m._nService.initNode("failureCode",m._failureCode,"INT",1);
		m._nFailureString	= m._nService.initNode("failureString",m._failureString,"STRING",1);
		
				
		m._buildin	 	= m._nBuildin.getValue() ;
		m._qos 			= m._nQos.getValue() ;
		m._damage		= m._nDamage.getValue() ;
# 		m._failureCode		= m._nFailureCode.getValue() ;
# 		m._failureString	= m._nFailureString.getValue() ;
		
		 
		
		return m;
	},
	getName : func(){
		return me._name;
	},
	getPath : func(){
		return me._path;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		#print("Service init\t" ~me._name);
		
		me._initFailure();
		
		me._failureStressMapIndex = sort ( keys(me._failureStressMap) , func(a,b) a-b ) ;
		
		me.resetFailure();
		
		extraService.register(instance);
		
		me.setListeners(instance);
		
		
	},
	deinit : func(){
		me.removeListeners();
	},
	setListeners  :func(instance){
		#print("ServiceClass.setListeners() ... " ~me._name);
		append(me._listeners, setlistener(me._nFailureCode,func(n){instance._onFailureCodeChange(n);},1,1) );
		append(me._listeners, setlistener(me._nDamage,func(n){instance._onDamageChange(n);},1,0) );
		
	},
	removeListeners  :func(){
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	# need override in component to refelect the errorCodes
	_initFailure : func(){
		me._failureStressMap 	= {
			0   : 0,
			0.1 : 1,
			0.2 : 2,
			0.4 : 3,
			0.5 : 4
		};
		me._failureStringMap 	= {
			0:"",
			1:"loose connection",
			2:"increased resistance",
			3:"overheating",
			4:"complete failure",
		};
	},
	resetFailure : func(){
		me._nFailureCode.setValue(0);
		me._nFailureString.setValue("");
		
		me.checkQos();
		
	},
	checkQos : func(){
		
		var wear = (systime() - me._buildin) / me._lifetime;
		me._qos = 1.0 - (wear * wear * wear * wear);
		me._qos -= me._damage;
		me._qos = global.clamp(me._qos,0,1.0);
		
		me._nQos.setValue(me._qos);
	},
	stressTest : func(){
		
		var stress = rand();
		
		if (stress > me._qos){
			me._failureOverStress = stress - me._qos;
			#print("ServiceClass::stressTest(" ~me._name ~") ... FAILURE overStress: "~me._failureOverStress);
			
			me.raiseFailure(me._failureOverStress);
		}else{
			#print(me.getPartName() ~ " ... OK");
		}
	},
	raiseFailure : func(overStress){
		
		foreach (var stressIndex; me._failureStressMapIndex) {
			if (stressIndex <= overStress ){
				me._failureCode = me._failureStressMap[stressIndex];
			}else{
				#we are above the map stressIndex
				break;
			}
		}
		
		me.setFailureCode(me._failureCode);
	},
	setBuildin : func(t){
		me._buildin = t;
		me._nBuildin.setValue(me._buildin);
		
	},
	getBuildin : func(){
		me._buildin = me._nBuildin.getValue();
		return me._buildin;
	},
	getPartName : func(){
		return sprintf("%s - %s",me._serialNumber,me._name);
	},
	getFailureString : func(){
		return me._failureString;
	},
	getFailureCode : func(){
		return me._failureCode;
	},
	setFailureCode : func(nr){
		me._nFailureCode.setValue(nr);
	},
	getDamage : func(){
		me._damage = me._nDamage.getValue();
		me._damage = global.clamp(me._damage,0,1.0);
		return me._damage;
	},
	setDamage : func(v){
		me._damage = v;
		me._damage = global.clamp(me._damage,0,1.0);
		me._nDamage.setValue(me._damage);
	},
	addDamage : func(v){
		me._damage += v;
		me._damage = global.clamp(me._damage,0,1.0);
		me._nDamage.setValue(me._damage);
	},
	repairPart : func(){
		me._damage = 0.0;
		me._nDamage.setValue(me._damage);
	},
	replacePart : func(){
		me._damage = 0.0;
		me._buildin = systime();
		
		me._nDamage.setValue(me._damage);
		me._nBuildin.setValue(me._buildin);
	},
	_onDamageChange : func(n){
		me._damage =  n.getValue();
		me.checkQos();
		me.stressTest();
	},
	_onFailureCodeChange : func(n){
		
		me._failureCode = n.getValue();
		
		me._failureString = me._failureStringMap[me._failureCode];

		#print(sprintf("ServiceClass._onFailureCodeChange() ... %i : %s",me._failureCode,me._failureString));
		
		me._nFailureString.setValue(me._failureString);
		
		#raise the failure event on the component
		me._onFailure();
	},
	# abstract every component should do the failure handling
	_onFailure : func(){
		print(sprintf("ServiceClass._onFailure() ... %s | %s | overstress: %4.1f%% | failure [%i] %s",
			me.parents[0],
			me.getPartName(),
			me._failureOverStress*100,
			me._failureCode,
			me._failureString
		));
	},
};





var ExtraService = {
	new : func(root,name){
		var m = { 
			parents : [
				ExtraService,
			],
			_path		: root,
			_nRoot		: props.globals.initNode(root),
			_name		: name,
		};
		m._listeners = [];
		
		m._timerIntervall 	= 0.1;
		
		m._nTimerIntervall = m._nRoot.initNode("timerIntervall",m._timerIntervall,"DOUBLE");
		
		m._count 	= 0;
		m._partsA	= std.Vector.new();
		m._partsB	= std.Vector.new();
		m._partOut 	= m._partsA;
		m._partIn 	= m._partsB;
		
		m._timer 	= nil;
		
		m._now 	= systime();
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		
		
		me._timer = maketimer(me._timerIntervall,me,ExtraService.update);
		
		append(me._listeners, setlistener(me._nTimerIntervall,func(n){instance._onTimerIntervallChange(n);},1,1) );
		
	},
	_onTimerIntervallChange : func(n){
		me._timerIntervall = n.getValue();
		me._timer.restart(me._timerIntervall);
	},
	register : func(part){
		
		#print("ExtraService::register(" ~part._name ~")");
				
		if(part.getBuildin() == 0) {
			part.setBuildin(me._now);
			part.setDamage(0);
			debug.dump("ExtraService::register(" ~part._nService.getPath() ~") ... "~part._name~" buildin: "~me._now);
		}
		me._partOut.append(part);
		
		print(sprintf("%3i = %s",me._partOut.size(),part._name));
		
		me._count += 1;
		
		part.checkQos();
	},
	checkPart : func(index){
		
		me._count = me._partOut.size();
					
		if ( index >= 0 and index < me._count){
			
			var part = me._partOut.pop(index);
			
			part.stressTest();
			
			me._partIn.append(part);
			
			#var countAfter = me._partOut.size();
		
			
			#print("ExtraService::checkPart(" ~index ~") ... "~me._count~" -> "~countAfter~"");
		}else{
			print("ExtraService::checkPart(" ~index ~") ... no part found.");
		}
	},
	update : func(){
		var random = rand();
		var partCount = me._partOut.size();
		if(partCount == 0){
			# swap the dubble buffer
			print("ExtraService::update() ... swap dubble Buffer.");
			var partTemp = me._partOut;
			me._partOut 	= me._partIn;
			me._partIn 	= partTemp;
		
			partCount = me._partOut.size();
			
		}
		var index = int(global.roundInt(random * (partCount-1)));
		
		me.checkPart(index);
	},
	
	
};

extraService = ExtraService.new("/extra500/service","extraService");