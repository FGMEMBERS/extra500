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
#	Authors: 	Dirk Dittmann
#	Date: 		Mai 02 2015
#
#	Last change:	Dirk Dittmann
#	Date:		08.01.18
#


var COLOR = {};
COLOR["Red"] 			= "rgb(244,28,33)";
COLOR["Green"] 			= "#008000";
COLOR["Black"] 			= "#000000";
COLOR["btnActive"] 		= "#9ec5ffff";
COLOR["btnPassive"] 		= "#003ea2ff";
COLOR["btnEnable"] 		= "#2a7fffff";
COLOR["btnBorderEnable"] 	= "#0000ffff";
COLOR["btnDisable"] 		= "#8c939dff";
COLOR["btnBorderDisable"] 	= "#69697bff";


var SvgWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[SvgWidget]};
		m._class = "SvgWidget";
		m._dialog 	= dialog;
		m._listeners 	= [];
		m._name 	= name;
		m._group	= canvasGroup;
		return m;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	
};

var TankWidget = {
	new: func(dialog,canvasGroup,name,lable,index,refuelable=1){
		var m = {parents:[TankWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TankWidget";
		m._index 	= index;
		m._refuelable 	= refuelable;
		m._lable 	= lable;
		m._nLevel 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/level-gal_us",0.0,"DOUBLE");
		m._nCapacity 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/capacity-gal_us",0.0,"DOUBLE");
		
		m._level	= m._nLevel.getValue();
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._level / m._capacity;
			
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Fuel_Level");
		m._cDataName 	= m._group.getElementById(m._name~"_Data_Name");
		m._cDataMax 	= m._group.getElementById(m._name~"_Data_Max");
		m._cDataLevel 	= m._group.getElementById(m._name~"_Data_Level");
		m._cDataPercent	= m._group.getElementById(m._name~"_Data_Percent");
				
		m._cDataName.setText(m._lable);
		m._cDataMax.setText(sprintf("%3.0f",m._capacity * global.CONST.JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.0f",m._level * global.CONST.JETA_LBGAL));
		m._cDataPercent.setText(sprintf("%3.1f",m._fraction*100.0));
		
		
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		return m;
	},
	setListeners : func(instance) {
		
		append(me._listeners, setlistener(me._nLevel,func(n){me._onFuelLevelChange(n);},1,0) );
		if(me._refuelable == 1){
			me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
			me._cLevel.addEventListener("drag",func(e){me._onFuelInputChange(e);});
			me._cFrame.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
			me._cLevel.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
			
		}
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onFuelLevelChange : func(n){
		me._level	= n.getValue();
		me._fraction	= me._level / me._capacity;
		
		me._cDataLevel.setText(sprintf("%3.0f",me._level * global.CONST.JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.1f",me._fraction*100.0));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
			
	},
	_onFuelInputChange : func(e){
		var newFraction = 0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._height);
		}else{
			newFraction = me._fraction - (e.deltaY/me._height);
		}
		newFraction = global.clamp(newFraction,0.0,1.0);
		me._nLevel.setValue(me._capacity * newFraction);
		
	},
};

var TankerWidget = {
	new: func(dialog,canvasGroup,name,lable,widgets){
		var m = {parents:[TankerWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TankerWidget";
		m._lable 	= lable;
		m._widget	= {};
		m._nLevel 	= props.globals.initNode("/fdm/jsbsim/propulsion/total-fuel-lbs",0.0,"DOUBLE");
		
		m._level		= 0;
		m._capacity		= 0;
		m._levelTotal		= 0;
		m._capacityTotal	= 0;
		
		#debug.dump(m._widget);
		foreach(tank;keys(widgets)){
			if(widgets[tank] != nil){
				if(widgets[tank]._class == "TankWidget"){
					m._widget[tank] = widgets[tank];
				}
			}
		}
		
		foreach(tank;keys(m._widget)){
			
			if (m._widget[tank]._refuelable == 1){
			#print ("TankerWidget.new() ... "~tank);
				
				m._capacity 	+= m._widget[tank]._capacity;
				m._level	+= m._widget[tank]._level;
			}
			m._capacityTotal 	+= m._widget[tank]._capacity;
			m._levelTotal		+= m._widget[tank]._level;
			
		}
		m._fraction		= m._level / m._capacity;
		m._fractionTotal	= m._levelTotal / m._capacityTotal;
		
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Level");
		m._cDataName 	= m._group.getElementById(m._name~"_Data_Name");
		m._cDataMax 	= m._group.getElementById(m._name~"_Data_Max");
		m._cDataLevel 	= m._group.getElementById(m._name~"_Data_Level");
		m._cDataPercent	= m._group.getElementById(m._name~"_Data_Percent");
		
		m._cTotalDataName 	= m._group.getElementById(m._name~"_Total_Data_Name");
		m._cTotalDataMax 	= m._group.getElementById(m._name~"_Total_Data_Max");
		m._cTotalDataLevel 	= m._group.getElementById(m._name~"_Total_Data_Level");
		m._cTotalDataPercent	= m._group.getElementById(m._name~"_Total_Data_Percent");
		
		m._cWeightFuel		 	= m._group.getElementById("Weight_Fuel");
		
		m._cDataName.setText(m._lable);
		m._cDataMax.setText(sprintf("%3.0f",m._capacity * global.CONST.JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.0f",m._level * global.CONST.JETA_LBGAL));
		m._cDataPercent.setText(sprintf("%3.1f",m._fraction*100.0));
		
		m._cTotalDataName.setText("Total");
		m._cTotalDataMax.setText(sprintf("%3.0f",m._capacityTotal * global.CONST.JETA_LBGAL));
		m._cTotalDataLevel.setText(sprintf("%3.0f",m._levelTotal * global.CONST.JETA_LBGAL));
		m._cTotalDataPercent.setText(sprintf("%3.1f",m._fractionTotal*100.0));
		
		
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nLevel,func(n){me._onLevelChange(n);},1,0) );
		
		me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onFuelInputChange(e);});
		me._cFrame.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onFuelInputChange(e);});

	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onLevelChange : func(n){
		me._level 	= 0;
		me._levelTotal 	= 0;
		foreach(tank;keys(me._widget)){
			if (me._widget[tank]._refuelable == 1){
				me._level	+= me._widget[tank]._level;
			}
			me._levelTotal		+= me._widget[tank]._level;
		}
		
		me._fraction		= me._level / me._capacity;
		me._fractionTotal	= me._levelTotal / me._capacityTotal;
		
		me._cDataLevel.setText(sprintf("%3.0f",me._level * global.CONST.JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.1f",me._fraction*100.0));
		
		me._cTotalDataLevel.setText(sprintf("%3.0f",me._levelTotal * global.CONST.JETA_LBGAL));
		me._cTotalDataPercent.setText(sprintf("%3.1f",me._fractionTotal*100.0));
		
		me._cWeightFuel.setText(sprintf("%3.0f",me._levelTotal * global.CONST.JETA_LBGAL));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
	
	},
	_onFuelInputChange : func(e){
		var newFraction = 0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._height);
		}else{
			newFraction = me._fraction - (e.deltaY/me._height);
		}
		newFraction = global.clamp(newFraction,0.0,1.0);
		
# 		foreach(tank;keys(me._widget)){
# 			if (me._widget[tank]._refuelable == 1){
# 				me._widget[tank]._nLevel.setValue(me._widget[tank]._capacity * newFraction);
# 			}
# 			
# 		}
		
		me.orderFuel(me._capacity * newFraction);
		
	},
	
	orderFuel : func(amount){
		var fuelamount  = (amount) /2;
		var fuelAux	= fuelamount - me._widget.LeftMain._capacity;
		if (fuelAux > me._widget.LeftAux._capacity){
			fuelAux = me._widget.LeftAux._capacity;
		}
		
		if (fuelAux > 0){
			me._widget.LeftMain._nLevel.setValue(me._widget.LeftMain._capacity);
			me._widget.RightMain._nLevel.setValue(me._widget.RightMain._capacity);
						
			me._widget.LeftAux._nLevel.setValue(fuelAux);
			me._widget.RightAux._nLevel.setValue(fuelAux);
		}else{
			me._widget.LeftMain._nLevel.setValue(fuelamount);
			me._widget.RightMain._nLevel.setValue(fuelamount);
			
			me._widget.LeftAux._nLevel.setValue(0);
			me._widget.RightAux._nLevel.setValue(0);
			
		}
		
	}
};

COLOR["TabActive"] = "#f2f2f2";
COLOR["TabPassive"] = "#cccccc";

var TabWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[TabWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TabWidget";
		m._cTabFuel	 	= m._group.getElementById("Tab_Fuel").set("z-index",3);
		m._cTabFuelBack	 	= m._group.getElementById("Tab_Fuel_Back").setColorFill(COLOR["TabActive"]);
		m._cTabPayload	 	= m._group.getElementById("Tab_Payload").set("z-index",1);
		m._cTabPayloadBack	= m._group.getElementById("Tab_Payload_Back").setColorFill(COLOR["TabPassive"]);
		m._cTabWeight	 	= m._group.getElementById("Tab_Weight").set("z-index",3);
		m._cTabWeightBack	= m._group.getElementById("Tab_Weight_Back").setColorFill(COLOR["TabActive"]);
		m._cTabTrip	 	= m._group.getElementById("Tab_Trip").set("z-index",1);
		m._cTabTripBack		= m._group.getElementById("Tab_Trip_Back").setColorFill(COLOR["TabPassive"]);
		
		m._cLayerFuel		= m._group.getElementById("layer2").set("z-index",2.0);
		m._cLayerPayload	= m._group.getElementById("layer4").set("z-index",2.0).hide();
		m._cLayerWeight		= m._group.getElementById("layer5").set("z-index",2.0);
		m._cLayerTrip		= m._group.getElementById("layer6").set("z-index",2.0).hide();
		
		m._cTabFrameUpper	= m._group.getElementById("TabFrameUpper").set("z-index",2);
		m._cTabFrameLower	= m._group.getElementById("TabFrameLower").set("z-index",2);
		
		return m;
	},
	setListeners : func(instance) {
		me._cTabFuel.addEventListener("click",func(e){me._onTabFuelClick(e);});
		me._cTabPayload.addEventListener("click",func(e){me._onTabPayloadClick(e);});
		me._cTabWeight.addEventListener("click",func(e){me._onTabWeightClick(e);});
		me._cTabTrip.addEventListener("click",func(e){me._onTabTripClick(e);});
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onTabFuelClick : func(e){
		me._cTabFuel.set("z-index",3);
		me._cTabFuelBack.set("fill",COLOR["TabActive"]);
		me._cLayerFuel.setVisible(1);
		me._cTabPayload.set("z-index",1);
		me._cTabPayloadBack.set("fill",COLOR["TabPassive"]);
		me._cLayerPayload.setVisible(0);
	},
	_onTabPayloadClick : func(e){
		me._cTabPayload.set("z-index",3);
		me._cTabPayloadBack.set("fill",COLOR["TabActive"]);
		me._cLayerPayload.setVisible(1);
		me._cTabFuel.set("z-index",1);
		me._cTabFuelBack.set("fill",COLOR["TabPassive"]);
		me._cLayerFuel.setVisible(0);
		
	},
	_onTabWeightClick : func(e){
		me._cTabWeight.set("z-index",3);
		me._cTabWeightBack.set("fill",COLOR["TabActive"]);
		me._cLayerWeight.setVisible(1);
		me._cTabTrip.set("z-index",1);
		me._cTabTripBack.set("fill",COLOR["TabPassive"]);
		me._cLayerTrip.setVisible(0);
	},
	_onTabTripClick : func(e){
		me._cTabTrip.set("z-index",3);
		me._cTabTripBack.set("fill",COLOR["TabActive"]);
		me._cLayerTrip.setVisible(1);
		me._cTabWeight.set("z-index",1);
		me._cTabWeightBack.set("fill",COLOR["TabPassive"]);
		me._cLayerWeight.setVisible(0);
	},
	
};

var WeightWidget = {
	new: func(dialog,canvasGroup,name,widgets){
		var m = {parents:[WeightWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "WeightWidget";
		m._widget = {};
		
		foreach(w;keys(widgets)){
			if(widgets[w] != nil){
				if(widgets[w]._class == "PayloadWidget"){
					m._widget[w] = widgets[w];
				}
			}
		}
		
		
# 		m._cCenterGravityX	 	= m._group.getElementById("CenterGravity_X");
# 		m._cCenterGravityY	 	= m._group.getElementById("CenterGravity_Y");
# 		m._cCenterGravityBall	 	= m._group.getElementById("CenterGravity_Ball").updateCenter();
		m._cWeightEmpty		 	= m._group.getElementById("Weight_Empty");
		m._cWeightGross	 		= m._group.getElementById("Weight_Gross");
		m._cWeightPayload	 	= m._group.getElementById("Weight_Payload");
		m._cWeightMaxRamp	 	= m._group.getElementById("Weight_Max_Ramp");
		m._cWeightMaxTakeoff	 	= m._group.getElementById("Weight_Max_Takeoff");
		m._cWeightMaxLanding	 	= m._group.getElementById("Weight_Max_Landing");
		m._cWeightMACPercent	 	= m._group.getElementById("Weight_MAC_Percent");
		
# 		m._cCenterGravityXMax	 	= m._group.getElementById("CenterGravity_X_Max");
# 		m._cCenterGravityXMin	 	= m._group.getElementById("CenterGravity_X_Min");
# 		m._cCenterGravityYMax	 	= m._group.getElementById("CenterGravity_Y_Max");
# 		m._cCenterGravityYMin	 	= m._group.getElementById("CenterGravity_Y_Min");
		m._cWeight_Limits_lbs	 	= m._group.getElementById("Weight_Limits_lbs");
		m._cWeight_Limits_in	 	= m._group.getElementById("Weight_Limits_in");
		
		
		
		m._nCGx 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-x-in");
		m._nCGy 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-y-in");
		m._nGross 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nEmpty 	= props.globals.initNode("/fdm/jsbsim/inertia/empty-weight-lbs");
		m._nRamp 	= props.globals.initNode("/limits/mass-and-balance/maximum-ramp-mass-lbs");
		m._nTakeoff 	= props.globals.initNode("/limits/mass-and-balance/maximum-takeoff-mass-lbs");
		m._nLanding 	= props.globals.initNode("/limits/mass-and-balance/maximum-landing-mass-lbs");
# 		m._nCGxMax 	= props.globals.initNode("/limits/mass-and-balance/cg-x-max-in",120.0,"DOUBLE");
# 		m._nCGxMin 	= props.globals.initNode("/limits/mass-and-balance/cg-x-min-in",150.0,"DOUBLE");
# 		m._nCGyMax 	= props.globals.initNode("/limits/mass-and-balance/cg-y-max-in",100.0,"DOUBLE");
# 		m._nCGyMin 	= props.globals.initNode("/limits/mass-and-balance/cg-y-min-in",-100.0,"DOUBLE");
		m._nMac 	= props.globals.initNode("/limits/mass-and-balance/mac-mm",1322.0,"DOUBLE");
		m._nMac0 	= props.globals.initNode("/limits/mass-and-balance/mac-0-mm",3200.0,"DOUBLE");
		
		
		m._cgX  	= 0;
		m._cgY  	= 0;
		m._empty 	= 0;
		m._payload 	= 0;
		m._gross 	= 0;
		m._ramp  	= 0;
		m._takeoff  	= 0;
		m._landing 	= 0;
		m._MACPercent 	= 0.0; # %
		m._MAC 			= m._nMac.getValue(); # mm
		m._MAC_0 		= m._nMac0.getValue(); # mm
		m._MAC_Limit_Min	= 0.17; #%
		m._MAC_Limit_Max	= 0.35; #%
		m._WeightLimit_lbs_x0 	= m._cWeight_Limits_lbs.get("coord[2]");
		m._WeightLimit_lbs_y0 	= m._cWeight_Limits_lbs.get("coord[1]");
		m._WeightLimit_in_x0 	= m._cWeight_Limits_in.get("coord[0]");
		m._WeightLimit_in_y0 	= m._cWeight_Limits_in.get("coord[3]");
		
		m._WeightLimit_lbs_pixel 	= 0;
		m._WeightLimit_in_pixel 	= 0;
		
		
# 		m._cgXMax	= m._nCGxMax.getValue();
# 		m._cgXMin	= m._nCGxMin.getValue();
# 		m._cgYMax	= m._nCGyMax.getValue();
# 		m._cgYMin	= m._nCGyMin.getValue();
		
		
		m._ramp = m._nRamp.getValue();
		m._cWeightMaxRamp.setText(sprintf("%.0f",m._ramp));
		m._takeoff = m._nTakeoff.getValue();
		m._cWeightMaxTakeoff.setText(sprintf("%.0f",m._takeoff));
		m._landing = m._nLanding.getValue();
		m._cWeightMaxLanding.setText(sprintf("%.0f",m._landing));
		
# 		m._cCenterGravityXMax.setText(sprintf("%.2f",m._cgXMax));
# 		m._cCenterGravityXMin.setText(sprintf("%.2f",m._cgXMin));
# 		m._cCenterGravityYMax.setText(sprintf("%.2f",m._cgYMax));
# 		m._cCenterGravityYMin.setText(sprintf("%.2f",m._cgYMin));
		
		m._empty = m._nEmpty.getValue() + getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[7]") + getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[8]");
		m._cWeightEmpty.setText(sprintf("%.0f",m._empty));
		
		
		m._cWeightMACPercent.setText(sprintf("%.2f",m._MACPercent));
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fuelPayload._nGrossWeight,func(n){me._onGrossWeightChange(n);},1,0) );
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onGrossWeightChange : func(n){
		
		me._cgX = me._nCGx.getValue();
# 		me._cCenterGravityX.setText(sprintf("%.2f",me._cgX));
# 		me._cgY = me._nCGy.getValue();
# 		me._cCenterGravityY.setText(sprintf("%.2f",me._cgY));
		
		me._gross = me._nGross.getValue();
		me._cWeightGross.setText(sprintf("%.0f",me._gross));
		
		me._WeightLimit_lbs_pixel 	= ((me._gross - 3000) * (21.0 / 250.0));
		me._WeightLimit_in_pixel 	= ((me._cgX - 133.7913) * (51.0 / 2.602362205));
		
		
		me._cWeight_Limits_lbs.set("coord[1]",me._WeightLimit_lbs_y0 - me._WeightLimit_lbs_pixel);
		me._cWeight_Limits_lbs.set("coord[2]",me._WeightLimit_lbs_x0 + me._WeightLimit_in_pixel);
		
		me._cWeight_Limits_in.set("coord[0]",me._WeightLimit_in_x0 + me._WeightLimit_in_pixel);
		me._cWeight_Limits_in.set("coord[3]",me._WeightLimit_in_y0 - me._WeightLimit_lbs_pixel);
		
		me._payload = 0;
		foreach(w;keys(me._widget)){
			me._payload	+= me._widget[w]._weight;
		}
		#print("WeightWidget._onGrossWeightChange() ... _payload="~me._payload);
		me._cWeightPayload.setText(sprintf("%.0f",me._payload));
		
		
		#me._cCenterGravityBall.setTranslation(me._cgX * (64/13), (me._cgY - 136.0) * (64/13) );
		#me._cCenterGravityBall.setTranslation((me._cgY - 136.0) , me._cgX);
		
		var y = (me._cgX - 135.0) * (64/18);
		var x = (me._cgY ) * (64/13);
# 		me._cCenterGravityBall.setTranslation(x ,y );
		
		
		me._MACPercent = ( (me._cgX * global.CONST.INCH2METER * 1000) - me._MAC_0 ) / me._MAC;
		me._cWeightMACPercent.setText(sprintf("%.2f",me._MACPercent*100));
		
		if (me._gross > me._takeoff){
			me._cWeightGross.setColor(COLOR["Red"]);
		}else{
			me._cWeightGross.setColor(COLOR["Black"]);
		}
		if (me._MACPercent < me._MAC_Limit_Min or me._MACPercent > me._MAC_Limit_Max){
			me._cWeightMACPercent.setColor(COLOR["Red"]);
		}else{
			me._cWeightMACPercent.setColor(COLOR["Black"]);
		}
		
	},
	
	
	
};

var PayloadWidget = {
	new: func(dialog,canvasGroup,name,lable,index,listCategory=nil){
		var m = {parents:[PayloadWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "PayloadWidget";
		m._index 	= index;
		m._lable 	= lable;
		m._listCategory	= listCategory;
		m._listCategoryKeys = sort(keys(m._listCategory),func(a, b){return -cmp(a,b)} );
		
		#debug.dump(m._listCategoryKeys);
		
		m._nRoot	= props.globals.getNode("/payload/weight["~m._index~"]");
		m._nLable 	= m._nRoot.initNode("name","","STRING");
		
		### HACK : listener on /payload/weight[0]/weight-lb not working
		###	   two props one for fdm(weight-lb) one for dialog(nt-weight-lb) listener
		m._nWeightFdm 	= m._nRoot.initNode("weight-lb",0.0,"DOUBLE");
		m._weight	= m._nWeightFdm.getValue(); # lbs
		m._nWeight 	= m._nRoot.initNode("nt-weight-lb",m._weight,"DOUBLE");
		
		m._nCapacity 	= m._nRoot.initNode("max-lb",0.0,"DOUBLE");
		m._nCategory 	= m._nRoot.initNode("category","","STRING");
		
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._weight / m._capacity;
		m._category	= m._nCategory.getValue();
		
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Level");
		m._cLBS 	= m._group.getElementById(m._name~"_Lbs");
		m._cName 	= m._group.getElementById(m._name~"_Name");
		
		m._cCats	= {
			Cat1	: nil,
			Cat2	: nil,
			Cat3	: nil,
		};
		
		if (m._listCategory!=nil){
			foreach(cat;keys(m._listCategory)){
				m._cCats[cat]	= m._group.getElementById(m._name~"_"~cat);
			}
		}
		m._cLBS.setText(sprintf("%3.0f",m._weight));
		m._cName.setText(m._lable);
				
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		
		return m;
	},
	setListeners : func(instance) {
		### FIXME : use one property remove the HACK
		append(me._listeners, setlistener(me._nWeight,func(n){me._onWeightChange(n);},1,0) );
				
		me._cFrame.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cFrame.addEventListener("wheel",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onInputChange(e);});
		if (me._listCategory!=nil){
			if(me._cCats["Cat1"] != nil){
				me._cCats["Cat1"].addEventListener("click",func(e){me._onCatClick(e,"Cat1");});
			}
			if(me._cCats["Cat2"] != nil){
				me._cCats["Cat2"].addEventListener("click",func(e){me._onCatClick(e,"Cat2");});
			}
			if(me._cCats["Cat3"] != nil){
				me._cCats["Cat3"].addEventListener("click",func(e){me._onCatClick(e,"Cat3");});
			}
		}
			
		
	},
	init : func(instance=me){
		me.setListeners(instance);
		me._checkCat();
	},
	deinit : func(){
		me.removeListeners();	
	},
	_checkCat : func(){
		
		me._category = "";
		if(me._weight > 0){
			me._category = me._listCategoryKeys[-1];
			foreach(cat;me._listCategoryKeys){
				if (me._weight <= me._listCategory[cat]*me._capacity){
					me._category = cat;
					me._nCategory.setValue(me._category);
					break;
				}
			}
		}
		
		if(me._category == "Cat1"){
			if(me._cCats["Cat1"] != nil){
				me._cCats["Cat1"].set("fill",COLOR["Green"]);
			}
			if(me._cCats["Cat2"] != nil){
				me._cCats["Cat2"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat3"] != nil){
				me._cCats["Cat3"].set("fill",COLOR["TabPassive"]);
			}
		}elsif(me._category == "Cat2"){
			if(me._cCats["Cat1"] != nil){
				me._cCats["Cat1"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat2"] != nil){
				me._cCats["Cat2"].set("fill",COLOR["Green"]);
			}
			if(me._cCats["Cat3"] != nil){
				me._cCats["Cat3"].set("fill",COLOR["TabPassive"]);
			}
			
		}elsif(me._category == "Cat3"){
			if(me._cCats["Cat1"] != nil){
				me._cCats["Cat1"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat2"] != nil){
				me._cCats["Cat2"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat3"] != nil){
				me._cCats["Cat3"].set("fill",COLOR["Green"]);
			}
			
		}else{
			if(me._cCats["Cat1"] != nil){
				me._cCats["Cat1"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat2"] != nil){
				me._cCats["Cat2"].set("fill",COLOR["TabPassive"]);
			}
			if(me._cCats["Cat3"] != nil){
				me._cCats["Cat3"].set("fill",COLOR["TabPassive"]);
			}
			
		}
	},
	setWeight : func(weight){
		me._weight = weight;
		
		### HACK : set two props 
		me._nWeight.setValue(me._weight);
		me._nWeightFdm.setValue(me._weight);
		
	},
	_onCatClick : func(e,cat){
		#print("PayloadWidget._onCatClick() ... "~cat);
		if(me._category == cat){
			me._category = "";
		}else{
			me._category = cat;
		}
		if(me._category != ""){
			me._weight = me._listCategory[me._category]*me._capacity;
		}else{
			me._weight = 0;
		}
		me._nCategory.setValue(me._category);
		
		me.setWeight(me._weight);
				
	},
	_onWeightChange : func(n){
		me._weight	= me._nWeight.getValue();
		#print("PayloadWidget._onWeightChange() ... "~me._weight);
		
		me._fraction	= me._weight / me._capacity;
		
		me._cLBS.setText(sprintf("%3.0f",me._weight));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
		
		
		
		me._checkCat();
			
	},
	_onInputChange : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._height);
		}else{
			newFraction = me._fraction - (e.deltaY/me._height);
		}
		newFraction = global.clamp(newFraction,0.0,1.0);
		me._weight = me._capacity * newFraction;
		
		me.setWeight(me._weight);

	},
};


var TripWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[TripWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TripWidget";
		
		m._ptree = {
			taxi : {
				fuel 	: m._dialog._nRoot.initNode("taxi/fuel",30.0,"DOUBLE"),
			},
			climb : {
				vs	: m._dialog._nRoot.initNode("climb/vs",1000.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("climb/gs",150.0,"DOUBLE"),
			},
			cruise : {
				alt	: m._dialog._nRoot.initNode("cruise/alt",12000.0,"DOUBLE"),
				nm	: m._dialog._nRoot.initNode("cruise/nm",100.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("cruise/gs",200.0,"DOUBLE"),
				power	: m._dialog._nRoot.initNode("cruise/power","maxpow","STRING")
			},
			descent : {
				vs	: m._dialog._nRoot.initNode("descent/vs",-1000.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("descent/gs",180.0,"DOUBLE"),
			},
			reserve : {
				fl	: m._dialog._nRoot.initNode("reserve/fl",30.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("reserve/gs",180.0,"DOUBLE"),
				nm	: m._dialog._nRoot.initNode("reserve/nm",50.0,"DOUBLE"),
			},
			trip : {
				nm		: m._dialog._nRoot.initNode("trip/nm",250.0,"DOUBLE"),
				departureAlt 	: m._dialog._nRoot.initNode("trip/departure/alt",250.0,"DOUBLE"),
				destinationAlt 	: m._dialog._nRoot.initNode("trip/destination/alt",250.0,"DOUBLE"),
				wind	: m._dialog._nRoot.initNode("trip/wind",0.0,"DOUBLE"),
				isa	: m._dialog._nRoot.initNode("trip/isa",0.0,"DOUBLE"),
				
			},
		};
		
		m._can = {
			taxi : {
				fuelFrame: m._group.getElementById(m._name~"_Taxi_Fuel"),
				fuel	: m._group.getElementById(m._name~"_Taxi_Fuel_Value"),
			},
			climb : {
				nm	: m._group.getElementById(m._name~"_Climb_NM_Value"),
				time	: m._group.getElementById(m._name~"_Climb_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Climb_Fuel_Value"),
			},
			cruise : {
				nm	: m._group.getElementById(m._name~"_Cruise_NM_Value"),
				time	: m._group.getElementById(m._name~"_Cruise_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Cruise_Fuel_Value"),
			},
			descent : {
				nm	: m._group.getElementById(m._name~"_Descent_NM_Value"),
				time	: m._group.getElementById(m._name~"_Descent_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Descent_Fuel_Value"),
			},
			reserve : {
				nmFrame	: m._group.getElementById(m._name~"_Reserve_NM"),
				nm	: m._group.getElementById(m._name~"_Reserve_NM_Value"),
				time	: m._group.getElementById(m._name~"_Reserve_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Reserve_Fuel_Value"),
			},
			trip : {
				nmFrame		: m._group.getElementById(m._name~"_NM"),
				nm		: m._group.getElementById(m._name~"_NM_Value"),
				time		: m._group.getElementById(m._name~"_Time_Value"),
				fuel		: m._group.getElementById(m._name~"_Fuel_Value"),
				departureFrame 	: m._group.getElementById(m._name~"_Departure"),
				departure 	: m._group.getElementById(m._name~"_Departure_Value"),
				destinationFrame: m._group.getElementById(m._name~"_Destination"),
				destination 	: m._group.getElementById(m._name~"_Destination_Value"),
				windFrame	: m._group.getElementById(m._name~"_Wind"),
				wind 		: m._group.getElementById(m._name~"_Wind_Value"),
				isaFrame	: m._group.getElementById(m._name~"_ISA"),
				isa 		: m._group.getElementById(m._name~"_ISA_Value"),
				
				
			},
			graph : {
				x0	: m._group.getElementById(m._name~"_NM_000"),
				x25	: m._group.getElementById(m._name~"_NM_025"),
				x50	: m._group.getElementById(m._name~"_NM_050"),
				x75	: m._group.getElementById(m._name~"_NM_075"),
				x100	: m._group.getElementById(m._name~"_NM_100"),
				flFrame	: m._group.getElementById(m._name~"_FL"),
				fl	: m._group.getElementById(m._name~"_FL_Value"),
				toc	: m._group.getElementById(m._name~"_TOC"),
				tod	: m._group.getElementById(m._name~"_TOD"),
				profile	: m._group.getElementById("layer6").createChild("path",m._name~"_FlightProfile")
				.setStrokeLineWidth(3)
				.setColor("#225500ff")
				.moveTo(64,24)
				.lineTo(100,100)
				.lineTo(300,100)
				.lineTo(578,24)
				.set("z-index",-1)
				,
				grid	: m._group.getElementById(m._name~"_Graph").set("z-index",-2),
			},
			btn : {
				fromFpl 	: m._group.getElementById(m._name~"_FromFPL"),
				fromFplFrame 	: m._group.getElementById(m._name~"_FromFPL_Frame"),
				orderFuel 	: m._group.getElementById(m._name~"_OrderFuel"),
				orderFuelFrame 	: m._group.getElementById(m._name~"_OrderFuel_Frame"),
				powerMin	: m._group.getElementById(m._name~"_CruisePower_Min"),
				powerMinFrame	: m._group.getElementById(m._name~"_CruisePower_Min_Frame"),
				powerMax	: m._group.getElementById(m._name~"_CruisePower_Max"),
				powerMaxFrame	: m._group.getElementById(m._name~"_CruisePower_Max_Frame"),
				advisedFL	: m._group.getElementById(m._name~"_AdvisedFL"),
				advisedFLFrame	: m._group.getElementById(m._name~"_AdvisedFL_Frame"),
				
			}
		};
		
		
		
		m._data = {
			
			taxi : {
				fuel	: m._ptree.taxi.fuel.getValue()
			},
			climb : {
# 				vs	: m._ptree.climb.vs.getValue(),
# 				gs	: m._ptree.climb.gs.getValue(),
				nm	: 65,
				time	: 0,
				fuel	: 0,
# 				burnrate: 230/3600, # lbs/sec
			},
			cruise : {
				alt	: m._ptree.cruise.alt.getValue(),
# 				gs	: m._ptree.cruise.gs.getValue(),
				nm	: m._ptree.cruise.nm.getValue(),
				time	: 0,
				fuel	: 0,
# 				burnrate: 221/3600,
				power 	: m._ptree.cruise.power.getValue()
			},
			descent : {
# 				vs	: m._ptree.descent.vs.getValue(),
# 				gs	: m._ptree.descent.gs.getValue(),
				nm	: 50,
				time	: 0,
				fuel	: 0,
# 				burnrate: 145/3600, # lbs/sec
			},
			reserve : {
# 				fl	: m._ptree.reserve.fl.getValue(),
# 				gs	: m._ptree.reserve.gs.getValue(),
				nm	: m._ptree.reserve.nm.getValue(),
				time	: 0,
				fuel	: 0,
# 				burnrate: 180/3600, # lbs/sec
			},
			trip : {
				nm		: m._ptree.trip.nm.getValue(),
				time		: 0,
				fuel		: 0,
				departure	: {alt : m._ptree.trip.departureAlt.getValue()},
				destination	: {alt : m._ptree.trip.destinationAlt.getValue()},
				cruisePower 	: "maxpow",
				wind		: m._ptree.trip.wind.getValue(),
				isa		: m._ptree.trip.isa.getValue(),
				
			},
			graph : {
				x0	: 0,
				x25	: 0,
				x50	: 0,
				x75	: 0,
				x100	: 0,
				toc	: 0,
				tod	: 0,
				axisX	: {min:64,max:578},
				axisY	: {min:744,max:550},
				altScale : (744-550)/30000,
				nmScale : (578-64)/100,
				
			},
			
			
		};
		
		m._perf = extra500.PerfClass.new(m._dialog._nRoot.getPath() ~"/perf","performance");
		
		
		return m;
	},
	setListeners : func(instance) {
		
		me._can.graph.flFrame.addEventListener("drag",func(e){me._onCruiseAltChange(e);});
		
		me._can.trip.nmFrame.addEventListener("drag",func(e){me._onTripNmChange(e);});
		me._can.trip.nmFrame.addEventListener("wheel",func(e){me._onTripNmChange(e);});
		
		me._can.trip.departureFrame.addEventListener("drag",func(e){me._onDepartureAltChange(e);});
		me._can.trip.destinationFrame.addEventListener("drag",func(e){me._onDestinationAltChange(e);});
		
		me._can.trip.windFrame.addEventListener("drag",func(e){me._onWindChange(e);});
		me._can.trip.windFrame.addEventListener("wheel",func(e){me._onWindChange(e);});
		
		me._can.trip.isaFrame.addEventListener("drag",func(e){me._onIsaChange(e);});
		me._can.trip.isaFrame.addEventListener("wheel",func(e){me._onIsaChange(e);});
		
		
		me._can.reserve.nmFrame.addEventListener("drag",func(e){me._onReserveNmChange(e);});
		me._can.reserve.nmFrame.addEventListener("wheel",func(e){me._onReserveNmChange(e);});
		
		me._can.taxi.fuelFrame.addEventListener("drag",func(e){me._onTaxiFuelChange(e);});
		me._can.taxi.fuelFrame.addEventListener("wheel",func(e){me._onTaxiFuelChange(e);});
				
		
		me._can.btn.fromFpl.addEventListener("click",func(e){me._onFromFplClicked(e);});
		me._can.btn.orderFuel.addEventListener("click",func(e){me._onOrderFuelClicked(e);});
		
		me._can.btn.powerMin.addEventListener("click",func(e){me._onPowerMinClicked(e);});
		me._can.btn.powerMax.addEventListener("click",func(e){me._onPowerMaxClicked(e);});
		
		me._can.btn.advisedFL.addEventListener("click",func(e){me._onAdvisedFlClicked(e);});
		
		
		append(me._listeners, setlistener("/autopilot/route-manager/total-distance",func(n){me._onFlightPlanChange(n);},1,0) );
		
	},
	init : func(instance=me){
		me.setListeners(instance);
		me._draw();
	},
	
	
	setCruiseAlt : func(v){
		me._data.cruise.alt = v;
		me._data.cruise.alt = global.clamp(me._data.cruise.alt,0,25000.0);
		me._data.cruise.alt = math.floor(me._data.cruise.alt/100) * 100 ;
		me._ptree.cruise.alt.setValue(me._data.cruise.alt);
	},
	setDepartureAlt: func(v){
		me._data.trip.departure.alt = v;
		me._data.trip.departure.alt = math.floor(me._data.trip.departure.alt);
		me._data.trip.departure.alt = global.clamp(me._data.trip.departure.alt,0,14000.0);
		me._ptree.trip.departureAlt.setValue(me._data.trip.departure.alt);
	},
	setDestinationAlt: func(v){
		me._data.trip.destination.alt = v;
		me._data.trip.destination.alt = math.floor(me._data.trip.destination.alt);
		me._data.trip.destination.alt = global.clamp(me._data.trip.destination.alt,0,14000.0);
		me._ptree.trip.destinationAlt.setValue(me._data.trip.destination.alt);
	},
	setTripNm: func(v){
		me._data.trip.nm = v;
		me._data.trip.nm = global.clamp(me._data.trip.nm,20,8000.0);
		me._ptree.trip.nm.setValue(me._data.trip.nm);
		
	},
	setReserveNm: func(v){
		me._data.reserve.nm = v;
		me._data.reserve.nm = global.clamp(me._data.reserve.nm,0,1000.0);
		me._ptree.reserve.nm.setValue(me._data.reserve.nm);
	},
	setTaxiFuel : func(v){
		me._data.taxi.fuel = v;
		me._data.taxi.fuel = global.clamp(me._data.taxi.fuel,0,150.0);
		me._ptree.taxi.fuel.setValue(me._data.taxi.fuel);
		
	},
	setCruisePower : func(v){
		me._data.cruise.power = v;
		me._ptree.cruise.power.setValue(me._data.cruise.power);
	},
	setWind : func(v){
		me._data.trip.wind = v;
		me._data.trip.wind = global.clamp(me._data.trip.wind,-100.0,100.0);
		
		me._ptree.trip.wind.setValue(me._data.trip.wind);
	},
	setISA : func(v){
		me._data.trip.isa = v;
		me._data.trip.isa = global.clamp(me._data.trip.isa,-20,30);
		
		me._ptree.trip.isa.setValue(me._data.trip.isa);
	},
	
	
	_onCruiseAltChange : func(e){
		if(e.type == "wheel"){
			me._data.cruise.alt += e.deltaY / me._data.graph.altScale;
		}else{
			me._data.cruise.alt -= e.deltaY / me._data.graph.altScale;
		}
		
		me.setCruiseAlt(me._data.cruise.alt);
		
		me._draw();
	},
	_onDepartureAltChange : func(e){
		if(e.type == "wheel"){
			me._data.trip.departure.alt += e.deltaY / me._data.graph.altScale;
		}else{
			me._data.trip.departure.alt -= e.deltaY / me._data.graph.altScale;
		}
		me.setDepartureAlt(me._data.trip.departure.alt);
		me._draw();
	},
	_onDestinationAltChange : func(e){
		if(e.type == "wheel"){
			me._data.trip.destination.alt += e.deltaY / me._data.graph.altScale;
		}else{
			me._data.trip.destination.alt -= e.deltaY / me._data.graph.altScale;
		}
		me.setDestinationAlt(me._data.trip.destination.alt);
		me._draw();
	},
	_onTripNmChange: func(e){
		
		var factor = 1;
		factor = e.shiftKey ? 10 : factor;
		factor = e.shiftKey and e.ctrlKey ? 100 : factor;
		
		if(e.type == "wheel"){
			me._data.trip.nm += e.deltaY * factor;
		}else{
			me._data.trip.nm -= e.deltaY * factor;
		}
		me.setTripNm(me._data.trip.nm);
		me._draw();
	},
	_onReserveNmChange: func(e){
		if(e.type == "wheel"){
			me._data.reserve.nm += e.deltaY;
		}else{
			me._data.reserve.nm -= e.deltaY;
		}
		me.setReserveNm(me._data.reserve.nm);
		me._draw();
	},
	_onTaxiFuelChange: func(e){
		if(e.type == "wheel"){
			me._data.taxi.fuel += e.deltaY;
		}else{
			me._data.taxi.fuel -= e.deltaY;
		}
		me.setTaxiFuel(me._data.taxi.fuel);
		me._draw();
	},
	_onFromFplClicked: func(e){
		
		var totalDistance = getprop("/autopilot/route-manager/total-distance");
		
		if (totalDistance > 0){
						
			var groundTemp = 15.0;
			groundTemp = getprop("/environment/temperature-degc");
			# target for /environment/temperature-degc interpolation 
			groundTemp = getprop("/environment/config/boundary/entry[0]/temperature-degc");
						
			me.setISA(me._perf.D_ISA(getprop("/instrumentation/altimeter/pressure-alt-ft"),groundTemp));
			me.setWind(me.getTailWind(getprop("/autopilot/route-manager/departure/airport"),getprop("/autopilot/route-manager/destination/airport")));
			
			
			me.setTripNm(totalDistance);
#			me.setCruiseAlt(getprop("/autopilot/route-manager/cruise/altitude-ft"));
			me.setDepartureAlt(getprop("/autopilot/route-manager/departure/field-elevation-ft"));
			me.setDestinationAlt(getprop("/autopilot/route-manager/destination/field-elevation-ft"));
			me.setCruiseAlt(me._perf.RecomAlt(me._data.trip.nm,me._data.trip.departure.alt,me._data.trip.destination.alt,me._data.trip.isa));
			
			
			
			
			
		}
		me._draw();
	},
	_onOrderFuelClicked: func(e){
		me._draw();
		me._dialog._widget.tanker.orderFuel(me._data.trip.fuel / global.CONST.JETA_LBGAL);
		
	},
	_onPowerMinClicked: func(e){
		me.setCruisePower("minpow");	
		me._draw();
		
	},
	_onPowerMaxClicked: func(e){
		me.setCruisePower("maxpow");
		me._draw();
		
	},
	_onFlightPlanChange : func(n){
		var totalDistance = getprop("/autopilot/route-manager/total-distance");
		if (totalDistance > 0 ){
			me._can.btn.fromFplFrame.set("fill",COLOR["btnEnable"]);
			me._can.btn.fromFplFrame.set("stroke",COLOR["btnBorderEnable"]);
		}else{
			me._can.btn.fromFplFrame.set("fill",COLOR["btnDisable"]);
			me._can.btn.fromFplFrame.set("stroke",COLOR["btnBorderDisable"]);
			
		}
	},
	_onAdvisedFlClicked : func(e){
		var cruiseAlt = me._perf.RecomAlt(me._data.trip.nm,me._data.trip.departure.alt,me._data.trip.destination.alt,me._data.trip.isa);
		
		me.setCruiseAlt(cruiseAlt);
		
		me._draw();
	},
	_onWindChange : func(e){
		if(e.type == "wheel"){
			me._data.trip.wind += e.deltaY;
		}else{
			me._data.trip.wind -= e.deltaY;
		}
		me.setWind(me._data.trip.wind);
		me._draw();
	},
	_onIsaChange : func(e){
		if(e.type == "wheel"){
			me._data.trip.isa += e.deltaY;
		}else{
			me._data.trip.isa -= e.deltaY;
		}
		me.setISA(me._data.trip.isa);
		me._draw();
	},
	
	getTailWind : func(departure,destination) {
		var tailWind = 0;
		if (getprop("/environment/metar/valid") == 1){
			var depInfo 	= airportinfo(departure);
			var destInfo 	= airportinfo(destination);
			
			# course is reverse to get tail wind
			var (course, dist) 	= courseAndDistance(destInfo, depInfo);
			
			var windDirection	= getprop("/environment/wind-from-heading-deg");
			var windSpeed		= getprop("/environment/wind-speed-kt");
			var temperature_C 	= getprop("/environment/temperature-degc");
			var elevation_ft 	= 0;
			
			var aloftTable = props.globals.getNode("/environment/config/aloft");
			
#			print("--- aloft table ---");
#			print("\t  Alt\ttemp\twind\tspeed");
			
			foreach(var entry ; aloftTable.getChildren("entry")){
				
				if (entry.getNode("elevation-ft").getValue() >= me._data.cruise.alt){
					break;
				}
				elevation_ft 	= entry.getNode("elevation-ft").getValue();
				temperature_C	= entry.getNode("temperature-degc").getValue();
				windDirection 	= entry.getNode("wind-from-heading-deg").getValue();
				windSpeed	= entry.getNode("wind-speed-kt").getValue();
#				print (sprintf("\t%5ift\t%3.1f°C\t%3i°\t%3.1fkn",elevation_ft,temperature_C,windDirection,windSpeed));
				
				
			}
			
			var distanceSpeedError = (0.5 * dist/100);
			distanceSpeedError = 0;
			
			tailWind = (windSpeed * math.cos((windDirection - course) * D2R)) - distanceSpeedError;
			
#			print (sprintf("cruise aloft: alt: %5ift, temp: %3.1f°C, direction: %3i°, speed: %3.1fkn, course: %3i° = TailWind: %3.1fkn ",elevation_ft,temperature_C,windDirection,windSpeed,course,tailWind));
		
		}else{
#			print("aloft : metar not valid. no TailWind calculation.");
		}
		
		return tailWind;
	},
	
	getTime : func(time){
		var text = "00:00";
		if(time > 0){
			var hour = math.mod(time,86400.0) / 3600.0;
			var min = math.mod(time,3600.0) / 60.0;
			var sec = math.mod(time,60.0);
			
			if (hour > 1){
				text = sprintf("%02i:%02i:%02i",hour,min,sec);
			}else{
				text = sprintf("%02i:%02i",min,sec);
			}
		}
		return text;
	},
	_calculate : func(){
		
		var minFL = (math.max(me._data.trip.departure.alt,me._data.trip.destination.alt)) + 1500;
		
		me._data.cruise.alt = math.floor(me._data.cruise.alt/100) * 100 ;
		me._data.cruise.alt = global.clamp(me._data.cruise.alt,minFL,25000.0);
				
		me._perf.trip(
				"off",				# phase
				me._data.taxi.fuel, 		# startupfuel
				me._data.cruise.power,		# power
				"distance",			# flightMode
				me._data.trip.departure.alt,	# currentAlt
				me._data.cruise.alt,		# cruiseAlt
				me._data.trip.destination.alt,  # destAlt
				me._data.trip.nm,		# totalFlight
				0,				# currentGS
				0,				# currentFF
				me._data.trip.wind,		# windSp
				me._data.trip.isa		# Delta ISA in degC
     			);
		
		me._data.climb.nm	= me._perf.data.climb.distance;
		me._data.climb.time	= me._perf.data.climb.time;
		me._data.climb.fuel	= me._perf.data.climb.fuel;
		
		me._data.cruise.nm	= me._perf.data.cruise.distance;
		me._data.cruise.time	= me._perf.data.cruise.time;
		me._data.cruise.fuel	= me._perf.data.cruise.fuel;
		
		me._data.descent.nm	= me._perf.data.descent.distance;
		me._data.descent.time	= me._perf.data.descent.time;
		me._data.descent.fuel	= me._perf.data.descent.fuel;
		
		me._data.trip.time	= me._data.climb.time + me._data.cruise.time + me._data.descent.time;
		
		me._data.graph.x25	= me._data.trip.nm * 0.25;
		me._data.graph.x50	= me._data.trip.nm * 0.50;
		me._data.graph.x75	= me._data.trip.nm * 0.75;
		me._data.graph.x100	= me._data.trip.nm;
		
		me._data.graph.nmScale =  512 / me._data.trip.nm;
		
		
		### calcucate the reserve Trip
		
		var cruiseAlt = me._perf.RecomAlt(me._data.reserve.nm,me._data.trip.destination.alt,me._data.trip.destination.alt,me._data.trip.isa);
		
		me._perf.trip(
				"off",				# phase
				0, 				# startupfuel
				me._data.cruise.power,		# power
				"distance",			# flightMode
				me._data.trip.destination.alt,	# currentAlt
				cruiseAlt,			# cruiseAlt
				me._data.trip.destination.alt,  # destAlt
				me._data.reserve.nm,		# totalFlight
				0,				# currentGS
				0,				# currentFF
				me._data.trip.wind,		# windSp
				me._data.trip.isa		# Delta ISA in degC
     			);
		
		
		me._data.reserve.time	= me._perf.data.climb.time +  me._perf.data.cruise.time + me._perf.data.descent.time;
		me._data.reserve.fuel	= me._perf.data.climb.fuel +  me._perf.data.cruise.fuel + me._perf.data.descent.fuel;
		
		me._data.trip.fuel	= me._data.taxi.fuel + me._data.climb.fuel + me._data.cruise.fuel + me._data.descent.fuel + me._data.reserve.fuel;
		
		
	},
	_draw : func(){
		
		me._calculate();
		
		
		if (me._data.cruise.power == "maxpow"){
			
			me._can.btn.powerMaxFrame.set("fill",COLOR["btnActive"]);
			#me._can.btn.powerMaxFrame.set("stroke",COLOR["btnBorderEnable"]);
			
			me._can.btn.powerMinFrame.set("fill",COLOR["btnPassive"]);
			#me._can.btn.powerMinFrame.set("stroke",COLOR["btnBorderDisable"]);
			
			
		}else{
			
			me._can.btn.powerMinFrame.set("fill",COLOR["btnActive"]);
			#me._can.btn.powerMinFrame.set("stroke",COLOR["btnBorderEnable"]);
			
			me._can.btn.powerMaxFrame.set("fill",COLOR["btnPassive"]);
			#me._can.btn.powerMaxFrame.set("stroke",COLOR["btnBorderDisable"]);
			
		}
		
		
		
		me._can.graph.flFrame.setTranslation(0,-me._data.cruise.alt*me._data.graph.altScale);
		me._can.graph.fl.setText(sprintf("%3i",math.floor(me._data.cruise.alt/100)));
		
		me._can.taxi.fuel.setText(sprintf("%.0f",me._data.taxi.fuel));
				
		me._can.climb.nm.setText(sprintf("%i",me._data.climb.nm));
		me._can.climb.time.setText(me.getTime(me._data.climb.time));
		me._can.climb.fuel.setText(sprintf("%.0f",me._data.climb.fuel));
		
		me._can.cruise.nm.setText(sprintf("%i",me._data.cruise.nm));
		me._can.cruise.time.setText(me.getTime(me._data.cruise.time));
		me._can.cruise.fuel.setText(sprintf("%.0f",me._data.cruise.fuel));
		
		me._can.descent.nm.setText(sprintf("%i",me._data.descent.nm));
		me._can.descent.time.setText(me.getTime(me._data.descent.time));
		me._can.descent.fuel.setText(sprintf("%.0f",me._data.descent.fuel));
		
		me._can.reserve.nm.setText(sprintf("%i",me._data.reserve.nm));
		me._can.reserve.time.setText(me.getTime(me._data.reserve.time));
		me._can.reserve.fuel.setText(sprintf("%.0f",me._data.reserve.fuel));
		
		me._can.trip.nm.setText(sprintf("%i",me._data.trip.nm));
		me._can.trip.time.setText(me.getTime(me._data.trip.time));
		me._can.trip.fuel.setText(sprintf("%.0f",me._data.trip.fuel));
		
		me._can.trip.departure.setText(sprintf("%i",me._data.trip.departure.alt));
		me._can.trip.destination.setText(sprintf("%i",me._data.trip.destination.alt));
		
		me._can.trip.wind.setText(sprintf("%i",me._data.trip.wind));
		me._can.trip.isa.setText(sprintf("%i",me._data.trip.isa));
		
		me._can.graph.x0.setText(sprintf("%i",me._data.graph.x0));
		me._can.graph.x25.setText(sprintf("%i",me._data.graph.x25));
		me._can.graph.x50.setText(sprintf("%i",me._data.graph.x50));
		me._can.graph.x75.setText(sprintf("%i",me._data.graph.x75));
		me._can.graph.x100.setText(sprintf("%i",me._data.graph.x100));
		
		
		var departureAlt = (me._data.trip.departure.alt);
		var destinationAlt = (me._data.trip.destination.alt);
		
		# Departure
		me._can.graph.profile.set("coord[1]",me._data.graph.axisY.min - (departureAlt)*me._data.graph.altScale);
		
		# TOC
		me._can.graph.profile.set("coord[2]",me._data.graph.axisX.min + (me._data.climb.nm) * me._data.graph.nmScale);
		me._can.graph.profile.set("coord[3]",me._data.graph.axisY.min - (me._data.cruise.alt) * me._data.graph.altScale);
		
		# TOD
		me._can.graph.profile.set("coord[4]",me._data.graph.axisX.min + (me._data.climb.nm + me._data.cruise.nm) * me._data.graph.nmScale);
		me._can.graph.profile.set("coord[5]",me._data.graph.axisY.min - (me._data.cruise.alt) * me._data.graph.altScale);
		
		# Destination
		#me._can.graph.profile.set("coord[6]",me._data.graph.axisX.min + (me._data.climb.nm + me._data.cruise.nm + me._data.descent.nm) * me._data.graph.nmScale);
		me._can.graph.profile.set("coord[7]",me._data.graph.axisY.min - (destinationAlt) * me._data.graph.altScale);
		
				
		me._can.graph.toc.setTranslation(me._data.climb.nm * me._data.graph.nmScale,-me._data.cruise.alt*me._data.graph.altScale);
		me._can.graph.tod.setTranslation((me._data.climb.nm+me._data.cruise.nm) * me._data.graph.nmScale,-me._data.cruise.alt*me._data.graph.altScale);
		
		me._can.trip.departureFrame.setTranslation(0,-(departureAlt)*me._data.graph.altScale);
		me._can.trip.destinationFrame.setTranslation(0,-(destinationAlt)*me._data.graph.altScale);
		
	},
};


var FuelPayloadClass = {
	new : func(){
		var m = {parents:[FuelPayloadClass]};
		m._nRoot 	= props.globals.initNode("/extra500/dialog/fuel");
		
		m._nGrossWeight	= props.globals.initNode("/fdm/jsbsim/inertia/nt-weight-lbs",0.0,"DOUBLE");
		
		m._name  = "Fuel and Payload";
		m._title = "Fuel and Payload Settings";
		m._fdmdata = {
			grosswgt : "/fdm/jsbsim/inertia/weight-lbs",
			payload  : "/payload",
			cg       : "/fdm/jsbsim/inertia/cg-x-in",
		};
		m._tankIndex = [
			"LeftAuxiliary",
			"LeftMain",
			"LeftCollector",
			"Engine",
			"RightCollector",
			"RightMain",
			"RightAuxiliary"
			];
		
		
		m._listeners = [];
		m._dlg 		= nil;
		m._canvas 	= nil;
		
		m._isOpen = 0;
		m._isNotInitialized = 1;
		
		m._widget = {
			LeftAux 	: nil,
			LeftMain 	: nil,
			LeftCol 	: nil,
			RightAux 	: nil,
			RightMain 	: nil,
			RightCol 	: nil,
		
			Seat1A	 	: nil,
			Seat1B 		: nil,
			Seat2A 		: nil,
			Seat2B 		: nil,
			Seat3A 		: nil,
			Seat3B 		: nil,
			Seat4A 		: nil,
		   
			tanker		: nil,
			selector	: nil,
			weight		: nil,
			trip		: nil,
		};
		

		return m;
	},
	toggle : func(){
		if(me._dlg != nil){

			me.close();

		}else{
			me.open();
		}
	},
	close : func(){
#                 print("FuelPayloadClass._onClose() ... ");
		me.removeListeners();
		
                
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
				me._widget[widget] = nil;
			}
		}
                        
		me._dlg.del();
                me._dlg = nil;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
	
		
	},
	open : func(){
		if(getprop("/gear/gear[0]/wow") == 1){
			me.openFuel();
		}else{
			me.openMsg();
		}
		
	},
	openMsg : func(){
		me._dlg = canvas.extra500Window.new([512,384],[512,384], "dialog");
		me._dlg.onClose = func(){
#                         print("@Overload MyWindow.onClose() ... ");
			fuelPayload.close();
		}
		me._dlg.set("title", "Unable to refuel in Air");
		me._dlg.move(10,20);
                
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#3F3D38");
                
                
		me._group = me._canvas.createGroup();
                
                
		canvas.parsesvg(me._group, "Dialogs/FuelPayload_msg.svg",{"font-mapper": global.canvas.FontMapper});
		
		var apt = airportinfo();
		
		
		var airportCoord = geo.Coord.new();
		airportCoord.set_latlon(apt.lat, apt.lon,apt.elevation);
		
		var aicraftCoord = geo.aircraft_position();
		
		
		me._group.getElementById("ICAO").setText(apt.id);
		me._group.getElementById("Name").setText(apt.name);
		me._group.getElementById("Lat").setText(sprintf("%.2f",apt.lat));
		me._group.getElementById("Lon").setText(sprintf("%.2f",apt.lon));
		me._group.getElementById("Course").setText(sprintf("%.2f",aicraftCoord.course_to(airportCoord)));
		me._group.getElementById("Distance").setText(sprintf("%.2f",aicraftCoord.distance_to(airportCoord) * global.CONST.METER2NM));
		me._group.getElementById("Elevation").setText(sprintf("%.2f",apt.elevation * global.CONST.METER2FEET));
		
		
		
		
		
		
	},
	openFuel : func(){
                var scale = getprop("extra500/config/dialog/fuelpayload/scale");
		var size = [1024*scale,768*scale];
                
		me._dlg = canvas.extra500Window.new(size,[1024,768], "dialog");
		me._dlg.onClose = func(){
#                         print("@Overload MyWindow.onClose() ... ");
                        fuelPayload.close();
		}
		me._dlg.set("title", me._title);
		me._dlg.move(10,20);
                
		
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#3F3D38");

		
		me._group = me._canvas.createGroup();
#                 me._group.scale(0.5,0.5);
                
		canvas.parsesvg(me._group, "Dialogs/FuelPayload.svg",{"font-mapper": global.canvas.FontMapper});
		
		me._widget.selector = TabWidget.new(me,me._group,"Tab Selector");
		
		
		me._widget.LeftAux 		= TankWidget.new(me,me._group,"Left_Aux","Auxiliary",0,1);
		me._widget.LeftMain 		= TankWidget.new(me,me._group,"Left_Main","Main",1,1);
		me._widget.LeftCol 		= TankWidget.new(me,me._group,"Left_Collector","Collector",2,0);
		me._widget.RightCol 		= TankWidget.new(me,me._group,"Right_Collector","Collector",4,0);
		me._widget.RightMain 		= TankWidget.new(me,me._group,"Right_Main","Main",5,1);
		me._widget.RightAux 		= TankWidget.new(me,me._group,"Right_Aux","Auxiliary",6,1);
		
		me._widget.tanker		= TankerWidget.new(me,me._group,"Tanker","Tanker",me._widget);

		me._widget.Seat1A		= PayloadWidget.new(me,me._group,"Seat_1A","Pilot",0,{"Cat1":0.55});
		me._widget.Seat1B		= PayloadWidget.new(me,me._group,"Seat_1B","Co-Pilot",1,{"Cat1":0.55});
		me._widget.Seat2A		= PayloadWidget.new(me,me._group,"Seat_2A","Seat 2A",2,{"Cat1":0.6,"Cat2":0.4,"Cat3":0.1});
		me._widget.Seat2B		= PayloadWidget.new(me,me._group,"Seat_2B","Seat 2B",3,{"Cat1":0.6,"Cat2":0.4,"Cat3":0.1});
		me._widget.Seat3A		= PayloadWidget.new(me,me._group,"Seat_3A","Seat 3A",4,{"Cat1":0.6,"Cat2":0.4,"Cat3":0.1});
		me._widget.Seat3B		= PayloadWidget.new(me,me._group,"Seat_3B","Seat 3B",5,{"Cat1":0.6,"Cat2":0.4,"Cat3":0.1});
		me._widget.Seat4A		= PayloadWidget.new(me,me._group,"Seat_4A","Baggage",6,{"Cat1":0.8,"Cat2":0.5,"Cat3":0.2});
		
		me._widget.weight = WeightWidget.new(me,me._group,"Weight",me._widget);
		me._widget.trip = TripWidget.new(me,me._group,"Trip");
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].init();
			}
		}
		
		#me.setListeners();
		
                # make the canvas viewport again to full svg viewport
                # HACK: the timer moves this call in the execution queue behind the dialog calls!!!
#                 settimer(func {
#                     me._canvas.set("view[0]",1024);
#                     me._canvas.set("view[1]",768);
#                     
#                 }, 1);
                
	},
	_onNotifyChange : func(n){

	},
	_onFuelTotalChange : func(n){
		
	}
	
};

var fuelPayload = FuelPayloadClass.new();

