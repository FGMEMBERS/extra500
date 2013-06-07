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
#      Date: May 05 2013
#
#      Last change:      Dirk Dittmann
#      Date:             05.05.13
#

# MM Page 597
# EA-9B41160_3_3-PCB-Board2 

var GearWarningBoard = {
	new : func(nRoot,name){
		var m = {parents:[
			GearWarningBoard,
			Part.Part.new(nRoot,name),
			
		]};
		m.electron = Part.Electron.new();
		m.nGearHorn		= props.globals.initNode("/extra500/sound/gearWarning",0,"BOOL");
		
		m.capacitorHorn = Part.Capacitor.new(3);
		
# 		m._isDoorClosed 	= 0;
# 		m._isGearLeft 		= 0;
# 		m._isGearNose 		= 0;
# 		m._isGearRight 		= 0;
# 		m._isPowerIdle 		= 0;
# 		m._isFlap15 		= 0;
# 		m._isWarning = 0;
# 		
		m.GND 			= Part.ElectricPin.new("GND");			# Pin 1-15
		m.VDC28 		= Part.ElectricPin.new("VDC28"); 		# Pin 1-8 	+28V
		m.DoorClosed 		= Part.ElectricPin.new("DoorClosed"); 		# Pin 1-5
		m.GearLeft		= Part.ElectricPin.new("GearLeft"); 		# Pin 1-3
		m.GearNose		= Part.ElectricPin.new("GearNose"); 		# Pin 1-6
		m.GearRight 		= Part.ElectricPin.new("GearRight"); 		# Pin 1-10
		m.GearWaringLight 	= Part.ElectricPin.new("GearWaringLight"); 	# Pin 1-13
		m.PowerIdle 		= Part.ElectricPin.new("PowerIdle"); 		# Pin 1-1
		m.Flap15 		= Part.ElectricPin.new("Flap15"); 		# Pin 1-4
		m.TCAD	 		= Part.ElectricPin.new("TCAD"); 		# Pin 1-7
		m._GearHorn 		= Part.ElectricConnector.new("_GearHorn");	# Pin 1-14 	internal Horn
		m._VDC28 		= Part.ElectricConnector.new("_VDC28");		# 	 	internal VDC
		
		
		m.ClearHorn = Part.ElectricSwitchDT.new(m.nRoot.initNode("ClearHorn"),"Clear Horn",1);
		m.ClearHorn.setPoles(1);
		
		
		m.K11 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K11"),"K11 Relais");
		m.K11.setPoles(2);
		
		m.K21 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K21"),"K21 Relais");
		m.K21.setPoles(2);
		
		m.K31 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K31"),"K31 Relais");
		m.K31.setPoles(2);
		
		m.K31 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K31"),"K31 Relais");
		m.K31.setPoles(2);
		
		m.K41 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K41"),"K41 Relais");
		m.K41.setPoles(1);
		
		m.K51 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K51"),"K51 Relais");
		m.K51.setPoles(5);
		
		m.K61 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K61"),"K61 Relais");
		m.K61.setPoles(3);
		
		m.K71 = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("K71"),"K71 Relais");
		m.K71.setPoles(2);
		
		
		m.GNDBus 	= Part.ElectricBusDiode.new("GNDBus");
		m.VDC28Bus 	= Part.ElectricBus.new("VDC28Bus");
		m.ClearHornBus	= Part.ElectricBus.new("ClearHornBus");
		m.GearGNDBus1	= Part.ElectricBus.new("GearGNDBus1");
		m.GearGNDBus2	= Part.ElectricBus.new("GearGNDBus2");
		m.HornBus	= Part.ElectricBus.new("HornBus");
		m.LightBus	= Part.ElectricBus.new("LightBus");
		m.PowerIdleBus1	= Part.ElectricBus.new("PowerIdleBus1");
		m.PowerIdleBus2	= Part.ElectricBus.new("PowerIdleBus2");
		
		
 		m._GearHorn.solder(m);
# 		m.GND.solder(m);
 		m._VDC28.solder(m);
# 		m.DoorClosed.solder(m);
# 		m.GearLeft.solder(m);
# 		m.GearNose.solder(m);
# 		m.GearRight.solder(m);
# 		m.GearWaringLight.solder(m);
# 		m.PowerIdle.solder(m);
# 		m.Flap15.solder(m);
		
		
		
		append(Part.aListSimStateAble,m);
		return m;
	},
	plugElectric : func(){
		me.GNDBus.Minus.plug(me.GND);
		me.VDC28.plug(me.VDC28Bus.con());
		
		me.ClearHorn.Com1.plug(me.GNDBus.con());
		me.ClearHorn.L12.plug(me.ClearHornBus.con());
		
		me.GearWaringLight.plug(me.LightBus.con());
		me.GearRight.plug(me.K11.A2);
		me.GearNose.plug(me.K21.A2);
		me.GearLeft.plug(me.K31.A2);
		me.DoorClosed.plug(me.K41.A2);
		me.PowerIdle.plug(me.K61.A2);
		me.Flap15.plug(me.K71.A2);
		me._GearHorn.plug(me.HornBus.con());
		me._VDC28.plug(me.VDC28Bus.con());
		
		
		me.K11.A1.plug(me.VDC28Bus.con());
		#me.K11.A2.plug(me.GearRight);
		me.K11.P11.plug(me.GearGNDBus1.con());
		me.K11.P12.plug(me.GNDBus.con());
		me.K11.P21.plug(me.GearGNDBus2.con());
		me.K11.P22.plug(me.GNDBus.con());
		
		me.K21.A1.plug(me.VDC28Bus.con());
		#me.K21.A2.plug(me.GearNose);
		me.K21.P11.plug(me.GearGNDBus1.con());
		me.K21.P12.plug(me.GNDBus.con());
		me.K21.P21.plug(me.GearGNDBus2.con());
		me.K21.P22.plug(me.GNDBus.con());
		
		me.K31.A1.plug(me.VDC28Bus.con());
		#me.K31.A2.plug(me.GearLeft);
		me.K31.P11.plug(me.GearGNDBus1.con());
		me.K31.P12.plug(me.GNDBus.con());
		me.K31.P21.plug(me.GearGNDBus2.con());
		me.K31.P22.plug(me.GNDBus.con());
		
		me.K41.A1.plug(me.VDC28Bus.con());
		#me.K41.A2.plug(me.DoorClosed);
		me.K41.P11.plug(me.GearGNDBus1.con());
		me.K41.P12.plug(me.LightBus.con());
		
		me.K51.A1.plug(me.VDC28Bus.con());
		me.K51.A2.plug(me.ClearHornBus.con());
		me.K51.P11.plug(me.LightBus.con());
		me.K51.P12.plug(me.PowerIdleBus1.con());
		me.K51.P21.plug(me.HornBus.con());
		me.K51.P22.plug(me.PowerIdleBus2.con());
		me.K51.P31.plug(me.ClearHornBus.con());
		me.K51.P34.plug(me.K61.P31);
		#me.K51.P41.plug(me.TCAD);
		
		
		me.K61.A1.plug(me.VDC28Bus.con());
		#me.K61.A2.plug(me.PowerIdle);
		me.K61.P11.plug(me.PowerIdleBus1.con());
		me.K61.P14.plug(me.GearGNDBus1.con());
		me.K61.P21.plug(me.PowerIdleBus2.con());
		me.K61.P24.plug(me.GearGNDBus2.con());
		
		me.K61.P34.plug(me.GNDBus.con());
		
		me.K71.A1.plug(me.VDC28Bus.con());
		#me.K71.A2.plug(me.Flap15);
		me.K71.P11.plug(me.LightBus.con());
		me.K71.P14.plug(me.PowerIdleBus1.con());
		me.K71.P21.plug(me.HornBus.con());
		me.K71.P24.plug(me.PowerIdleBus2.con());
				
	},
	simReset : func(){
		me.capacitorHorn.load(-1);
		me.nGearHorn.setValue(me.capacitorHorn.value);
	},
	simUpdate : func(){
		
	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("GearWarningBoard",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			if (name == "_VDC28"){
				#print("GearWarningBoard._VDC28 ... "~electron.timestamp);
# 				me.electron.copy(electron);
# 				me.electron.resistor += 20000.0;
# 								
# 				GND = me.GND.applyVoltage(me.electron);
# 				if (GND){
# 					
# 				}
# 				
# 				me._isDoorClosed	= me.DoorClosed.applyVoltage(me.electron);
# 				me._isGearLeft 		= me.GearLeft.applyVoltage(me.electron);
# 				me._isGearNose 		= me.GearNose.applyVoltage(me.electron);
# 				me._isGearRight 	= me.GearRight.applyVoltage(me.electron);
# 				me._isPowerIdle 	= me.PowerIdle.applyVoltage(me.electron);
# 				me._isFlap15 		= me.Flap15.applyVoltage(me.electron);
# 						
# 				if (me._isDoorClosed == 1 and (me._isPowerIdle == 1 or me._isFlap15 ==1) ){
# 					me._isWarning = 1;
# 				}else{
# 					me._isWarning = 0;
# 				}
# 				
# 				if (me._isWarning == 1 and me.ClearHorn.state == 0){
# 					me.nGearHorn.setValue(1);
# 				}else{
# 					me.nGearHorn.setValue(0);
# 				}
				
				electron.resistor += 20000.0;
				GND = me._GearHorn.applyVoltage(electron);
				if (GND){
					me.capacitorHorn.load(10);
				}
				
			}elsif (name == "GearWaringLight"){
# 				if (me._isWarning == 1){
# 					GND = me.GND.applyVoltage(electron);
# 				}
			}elsif (name == "_GearHorn"){
				print("GearWarningBoard._GearHorn ... "~electron.timestamp);
				
			}
		}
		Part.etd.out("GearWarningBoard",me.name,name,electron);
		return GND;
	},
	initUI : func(){
		UI.register("Gear Clear Horn", 		func{extra500.gearWarningBoard.ClearHorn.toggle(); } 	);
		UI.register("Gear Clear Horn off", 	func{extra500.gearWarningBoard.ClearHorn.off(); } 	);
		UI.register("Gear Clear Horn on",	func{extra500.gearWarningBoard.ClearHorn.on(); } 	);
	},
};

var gearWarningBoard = GearWarningBoard.new(props.globals.initNode("/extra500/electric/GearWarningBoard"),"Gear Warning Board");
