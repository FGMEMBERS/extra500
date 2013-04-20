var GearSystem = {
	new : func{
		var m = {parents:[
			GearSystem
		]};
		
		
		m.nGearNose = props.globals.getNode("/gear/gear[0]/position-norm",1);
		m.nGearLeft = props.globals.getNode("/gear/gear[1]/position-norm",1);
		m.nGearRight = props.globals.getNode("/gear/gear[2]/position-norm",1);
		m.listener = nil;
		
		m.GND = Part.ElectricConnector.new("GND");
		m.GearNose = Part.ElectricConnector.new("GearNose");
		m.GearLeft = Part.ElectricConnector.new("GearLeft");
		m.GearRight = Part.ElectricConnector.new("GearRight");
		
		m.GND.solder(m);
		m.GearNose.solder(m);
		m.GearLeft.solder(m);
		m.GearRight.solder(m);
		
		return m;
		
	},applyVoltage : func(electron,name=""){
				
		if (name == "GearNose" and me.nGearNose.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "GearLeft" and me.nGearLeft.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "GearRight" and me.nGearRight.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}
	}
	
};

var gearSystem = GearSystem.new();