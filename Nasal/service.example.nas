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
#      Date: 05.08.15
#
#	Last change:	Dirk Dittmann
#	Date:		05.08.15
#

var TireExample = {
	new : func(root,name,unitIndex,sn="ATA-32-001",lifetime=72000000){
		var m = { 
			parents : [
				TireExample,
				ServiceClass.new(root,name,sn,lifetime),
				
			]
		};
		
		m._nRollingFrictionCoeff 	= props.globals.getNode("/fdm/jsbsim/gear/unit["~unitIndex~"]/rolling_friction_coeff",1);
		m._nStaticFrictionCoeff 	= props.globals.getNode("/fdm/jsbsim/gear/unit["~unitIndex~"]/static_friction_coeff",1);
		m._nZPosition		 	= props.globals.getNode("/fdm/jsbsim/gear/unit["~unitIndex~"]/z-position",1);
		m._nWow			 	= props.globals.getNode("/gear/gear["~unitIndex~"]/wow",1);
		m._nCompression		 	= props.globals.getNode("/gear/gear["~unitIndex~"]/compression-norm",1);
		
		
		m._rollingFrictionCoeff 	= m._nRollingFrictionCoeff.getValue();
		m._staticFrictionCoeff 		= m._nStaticFrictionCoeff.getValue();
		m._zPosition	 		= m._nZPosition.getValue();
		
		m._additionalRollingCoeff 	= 0.5;
		m._additionalStaticCoeff 	= 0.4;
		m._additionalZPosition		= 3.0;
		
		m._pressure			= 1.0;
		m._nPressure 			= m._nRoot.initNode("pressure",m._pressure,"DOUBLE");
		m._pressure 			= global.clamp(m._nPressure.getValue(),0.0,1.0);
		
		m._pressureRate 		= 0;
		m._animationDt			= 0;
		
		m._ground = {
			solid : 0,
			load_resistance : 0.0,
			friction_factor : 0.0,
			bumpiness : 0.0,
			rolling_friction : 0.0
		};
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		
		#config ServiceClass
		me.parents[1]._raisOnEveryTest 	= 1;
		me.parents[1]._onlyIncreasableFailure 	= 1;
				
		me.parents[1].init(instance);
		
		
		
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nPressure,func(n){instance._onPressureChange(n);},1,1) );
		append(me._listeners, setlistener(me._nWow,func(n){instance._onWowChange(n);},0,0) );
		
	},
	#override ServiceClass
	_initFailure : func(){
		me._failureStressMap 	= {
			0   : 0,
			0.2 : 1,
			0.4 : 2,
			0.6 : 3,
			0.8 : 4
		};
		me._failureStringMap 	= {
			0:"",
			1:"slow puncture",
			2:"medium puncture",
			3:"heavy puncture",
			4:"burst tire",
		};
	},
	#override ServiceClass
	_onFailure : func(){
		print(sprintf("TireExample._onFailure() ... %s | %s | overstress: %4.1f%% | failure [%i] %s",
			me.parents[0],
			me.getPartName(),
			me._failureOverStress*100,
			me._failureCode,
			me._failureString
		));
		
		me._animationDt = extraService._dt;
		
		if (me._failureCode == 0){
			#me._pressureRate = 0;
			
		}elsif(me._failureCode == 1){
			
			me._pressureRate = -0.001;
			
		}elsif(me._failureCode == 2){
			
			me._pressureRate = -0.005;
			
		}elsif(me._failureCode == 3){
			
			me._pressureRate = -0.05;
			
		}elsif(me._failureCode == 4){
			
			me._pressureRate = -1.0;
			me._animationDt = 2.0;
		}
		
		me._nPressure.setValue(me._pressure);
	},
	#override ServiceClass
	repairPart : func(){
		
		me._pressureRate = 0.0;
		me._pressure = 1.0;
		
		me._nPressure.setValue(me._pressure);
		
		#call super ServiceClass
		me.parents[1].replacePart();
		
	},
	#override ServiceClass
	replacePart : func(){
		
		me._pressureRate = 0.0;
		me._pressure = 1.0;
		
		me._nPressure.setValue(me._pressure);
		
		#call super ServiceClass
		me.parents[1].replacePart();

	},
	
	_onPressureChange : func(n){
		me._pressure = n.getValue();
		
		me.checkPressure();
		
		
		var newRolling	= me._rollingFrictionCoeff + (me._additionalRollingCoeff * (1.0-me._pressure));
		var newStatic	= me._staticFrictionCoeff + (me._additionalStaticCoeff * (1.0-me._pressure));
		var newZPos	= me._zPosition + (me._additionalZPosition * (1.0-me._pressure));
		
		interpolate(me._nRollingFrictionCoeff,newRolling,me._animationDt);
		interpolate(me._nStaticFrictionCoeff,newStatic,me._animationDt);
		interpolate(me._nZPosition,newZPos,me._animationDt);
	},
	
	checkPressure : func(){
		
		me._pressure += me._pressureRate * extraService._dt;
		me._pressure = global.clamp(me._pressure,0.0,1.0);
				
	},
	_onWowChange : func(n){
		if(n.getValue()){
			var wear = 0.0;
			var damage = 0.0;
			
			me.getGeodInfo();
			
			if(me._ground.solid == 1 ){
				#wear += 0.001 * me._ground.load_resistance;
				wear += 0.001 * me._ground.friction_factor * me._ground.rolling_friction;
				wear += 0.001 * me._ground.bumpiness ;
				
				# TODO : by force adding damge
				if(me._nCompression.getValue() > 0.14){
					damage += 0.01 * me._ground.bumpiness ;
				}
				me.addWear(wear);
				me.addDamage(damage);
				
			}
			
			print(sprintf("TireExample._onWowChange() ... compression: %f, wear: %f, damage: %f",
				me._nCompression.getValue(),
				wear,
				damage
			));
		
		}
	},
	getGeodInfo : func(){
		var lat = getprop("/position/latitude-deg");
		var lon = getprop("/position/longitude-deg");
		var info = geodinfo(lat, lon);
		if (info != nil) {
			#debug.dump(info);
			 if (info[1] != nil){
				 me._ground.solid = info[1].solid;
				 me._ground.load_resistance = info[1].load_resistance;
				 me._ground.friction_factor = info[1].friction_factor;
				 me._ground.bumpiness = info[1].bumpiness;
				 me._ground.rolling_friction = info[1].rolling_friction;
			 }
			
		}
		
		
	},
};


var tireNose = TireExample.new("/extra500/system/gear/nose","Tire-Front",0,"ATA-32-001");
var tireLeft = TireExample.new("/extra500/system/gear/left","Tire-Left",1,"ATA-32-002");
var tireRight = TireExample.new("/extra500/system/gear/right","Tire-Right",2,"ATA-32-003");

