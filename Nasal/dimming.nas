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
#      Last change:      Eric van den Berg
#      Date:             13.09.13
#

# MM Page 607

var DimmingSystemClass = {
	new : func(root,name){
		var m = {parents:[
			DimmingSystemClass,
			ServiceClass.new(root,name)
		]};
		
		m.nKeypad 	= m._nRoot.initNode("Keypad",0.0,"DOUBLE");
		m.nGlare 	= m._nRoot.initNode("Glare",0.0,"DOUBLE");
		m.nInstrument 	= m._nRoot.initNode("Instrument",0.0,"DOUBLE");
		m.nSwitch 	= m._nRoot.initNode("Switch",0.0,"DOUBLE");
		m.nAnnunciator 	= m._nRoot.initNode("Annunciator",0.0,"DOUBLE");
		
		m._nTest	= m._nRoot.initNode("Test",0,"BOOL");
		
		m.keypad 	= 0.0;
		m.glare 	= 0.0;
		m.instrument 	= 0.0;
		m.switch 	= 0.0;
		m.annuciator 	= 0.0;
		
		
		
		eSystem.switch.Instrument.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
			lumi.setState(me._state);
			stbyHSI.setBacklight(me._state);
			stbyIAS.setBacklight(me._state);
			stbyALT.setBacklight(me._state);
			fuelQuantity.setBacklight(me._state);
			fuelFlow.setBacklight(me._state);
			propellerHeat.setBacklight(me._state);
			turnCoordinator.setBacklight(me._state);
			cabincontroller.setBacklight(me._state);
			cabinaltimeter.setBacklight(me._state);
			cabinclimb.setBacklight(me._state);
			dmeInd.setBacklight(me._state);
			audiopanel.setBacklight(me._state);
		};
		eSystem.switch.Night.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		eSystem.switch.DimmingKeypad.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		eSystem.switch.DimmingGlare.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		eSystem.switch.DimmingInstrument.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		eSystem.switch.DimmingSwitch.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		eSystem.switch.DimmingAnnunciator.onStateChange = func(n){
			me._state = n.getValue();
			m.checkDimming();
		};
		
	
		return m;
	},
	checkDimming : func(){
				
			me.keypad 	= 1.0;
			me.glare 	= 1.0;
			me.instrument 	= 1.0;
			me.switch 	= 1.0;
			me.annuciator 	= 1.0;
		
		
		if (eSystem.switch.Night._state == 1){
				if (eSystem.switch.Instrument._state == 1){
					me.keypad 	= 0.2+eSystem.switch.DimmingKeypad._state*0.8;
					me.glare 	= 0.2+eSystem.switch.DimmingGlare._state*0.8;
					me.instrument 	= 0.2+eSystem.switch.DimmingInstrument._state*0.8;
					me.switch 	= 0.2+eSystem.switch.DimmingSwitch._state*0.8;
					me.annuciator 	= 0.2+eSystem.switch.DimmingAnnunciator._state*0.8;
				}
				me._nTest.setValue(0);
				
		}elsif (eSystem.switch.Night._state == -1){
							
			me._nTest.setValue(1);
		}else{
							
			me._nTest.setValue(0);
		}
			
		
		me.nKeypad.setValue(me.keypad);
		me.nGlare.setValue(me.glare);
		me.nInstrument.setValue(me.instrument);
		me.nSwitch.setValue(me.switch);
		me.nAnnunciator.setValue(me.annuciator);
				
		
	},
	init : func(instance){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);		
	},
	
};

var dimmingSystem = DimmingSystemClass.new("extra500/system/dimming","Dimming Control");
