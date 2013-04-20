var FlapSystem = {
	new : func{
		var m = {parents:[
			FlapSystem
		]};
		
		
		m.nFlaps = props.globals.getNode("/controls/flight/flaps",1);
		m.nFlapPosition = props.globals.getNode("/surface-positions/flap-pos-norm",1);
		m.listener = nil;
		
		m.flaps = 0;
		m.flapPosition = 0;
		
		m.GND = Part.ElectricConnector.new("GND");
		m.FlapTransition = Part.ElectricConnector.new("FlapTransition");
		m.Flap15 = Part.ElectricConnector.new("Flap15");
		m.Flap30 = Part.ElectricConnector.new("Flap30");
		
		m.GND.solder(m);
		m.FlapTransition.solder(m);
		m.Flap15.solder(m);
		m.Flap30.solder(m);
		
		return m;
		
	},applyVoltage : func(electron,name=""){
		
		
		
		if (name == "FlapTransition"){
			me.flaps = me.nFlaps.getValue();
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition != me.flaps){
				me.GND.applyVoltage(electron);
			}
		}elsif (name == "Flap15"){
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition == 0.5){
				me.GND.applyVoltage(electron);
			}
		}elsif (name == "Flap30"){
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition == 1.0){
				me.GND.applyVoltage(electron);
			}
		}
	}
	
};

var flapSystem = FlapSystem.new();