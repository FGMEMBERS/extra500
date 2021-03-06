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
#	Authors: 	Eric van den Berg
#	Date: 	10.10.2015
#
#	Last change:	Dirk Dittmann
#	Date:		08.01.18	
#

var COLORfd = {};
COLORfd["opaque"] = "#ffffff01";
COLORfd["menuns"] = "#009400ff";
COLORfd["menuse"] = "#0055d4ff";
COLORfd["AilOk"] = "#c7f291ff";
COLORfd["EleOk"] = "#7af4b9ff";
COLORfd["RudOk"] = "#00f4ffff";
COLORfd["TriOk"] = "#7ad2b9ff";
COLORfd["FlaOk"] = "#c7f2dfff";
COLORfd["GeaOk"] = "#00a2ffff";
COLORfd["BraOk"] = "#bba9ffff";
COLORfd["TyrOk"] = "#8cd0ffff";
COLORfd["auxOk"] = "#d4aa00ff";
COLORfd["mainOk"] = "#ffcc00ff";
COLORfd["colOk"] = "#ffdd55ff";
COLORfd["CVOk"] = "#00ff004a";
COLORfd["SVok"] = "#00800059";
COLORfd["pitotOk"] = "#bc9be3ff";
COLORfd["stallwOk"] = "#7248d9ff";
COLORfd["inletOk"] = "#3296b5ff";
COLORfd["propOk"] = "#aa9bb5ff";
COLORfd["windShOk"] = "#9b48b5ff";
COLORfd["boot1Ok"] = "#80b3f1ff";
COLORfd["boot2Ok"] = "#1d79e8ff";
COLORfd["Failed"] = "#ff8080ff";
COLORfd["randomA"] = "#d45d00ff";
COLORfd["randomB"] = "#fffa00ff";
COLORfd["randomC"] = "#d40000ff";
COLORfd["pitotOk"] = "#2bb200ff";
COLORfd["staticOk"] = "#75c3ffff";
COLORfd["gpsOk"] = "#97bcdaaa";
COLORfd["navOk"] = "#1897ffaa";
COLORfd["dmeOk"] = "#0a6ab8aa";
COLORfd["insOk"] = "#00ccffff";
COLORfd["black"] = "#000000ff";
COLORfd["attOK"] = "#1ec6f60a";
COLORfd["ptsOK"] = "#a3e51eff";
COLORfd["rtsOK"] = "#1ee55fff";
COLORfd["pttsOK"] = "#1ee5d8ff";
COLORfd["altsOK"] = "#1e71e5ff";

var FailureClass = {
	new : func(){
		var m = {parents:[FailureClass]};

		m._title = 'Extra500 Failure Dialog';
		m._gfd 	= nil;
		m._canvas	= nil;
		m._timer 	= maketimer(1.0,m,FailureClass._timerf );
                m._listeners = [];
                
		return m;
	},
        toggle : func(){
		if(me._gfd != nil){
			me.close();
		}else{
			me.openDialog();
		}
	},
	close : func(){
#                 print("FailureClass.close() ... ");
                
                me._timer.stop();
                
		me.removeListeners();
                        
		me._gfd.del();
                me._gfd = nil;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	openDialog : func(){
		# making window
                var scale = getprop("extra500/config/dialog/failure/scale");
		var size = [750*scale,512*scale];
                
            
		me._gfd = canvas.extra500Window.new(size,[750,512],"dialog");
                me._gfd.onClose = func(){Failuredialog.close();}
#  		me._gfd.onClose = func(){Failuredialog.onClose();}
#		me._gfd.onClose = func(){me.onClose();}
#		me._gfd.onClose = func(){me._gfd.del();}

		me._gfd.set('title',me._title);
                me._gfd.move(10,20);
                
		me._canvas = me._gfd.createCanvas().set("background", "dcdcdcff");
#		me._canvas = me._gfd.createCanvas().set("background", canvas.style.getColor("bg_color"));
           	me._root = me._canvas.createGroup();
		
		# parsing svg-s
		me._filename = "/Dialogs/MenuFaildialog.svg";
		me._svg_menu = me._root.createChild('group');
		canvas.parsesvg(me._svg_menu, me._filename);

		me._filename = "/Dialogs/LowerMenuFaildialog.svg";
		me._svg_lmenu = me._root.createChild('group');
		canvas.parsesvg(me._svg_lmenu, me._filename);

		me._filename = "/Dialogs/welcomeFaildialog.svg";
		me._svg_welcome = me._root.createChild('group');
		canvas.parsesvg(me._svg_welcome, me._filename);

		me._filename = "/Dialogs/GearFaildialog.svg";
		me._svg_gear = me._root.createChild('group');
		canvas.parsesvg(me._svg_gear, me._filename);

		me._filename = "/Dialogs/FuelFaildialog.svg";
		me._svg_fuel = me._root.createChild('group');
		canvas.parsesvg(me._svg_fuel, me._filename);

		me._filename = "/Dialogs/ControlsFaildialog.svg";
		me._svg_contr = me._root.createChild('group');
		canvas.parsesvg(me._svg_contr, me._filename);

		me._filename = "/Dialogs/DeiceFaildialog.svg";
		me._svg_deice = me._root.createChild('group');
		canvas.parsesvg(me._svg_deice, me._filename);

		me._filename = "/Dialogs/AvionicFaildialog.svg";
		me._svg_avionic = me._root.createChild('group');
		canvas.parsesvg(me._svg_avionic, me._filename);

		me._filename = "/Dialogs/AutopilotFaildialog.svg";
		me._svg_ap = me._root.createChild('group');
		canvas.parsesvg(me._svg_ap, me._filename);


# defining clickable fields and other elements from svg files
	# menu
		me._gear		= me._svg_menu.getElementById("field_gear");
		me._gear_ind	= me._svg_menu.getElementById("gearfailind").hide();
		me._gear_active	= me._svg_menu.getElementById("gear_active").hide();
		me._fuel		= me._svg_menu.getElementById("field_fuel");
		me._fuel_ind	= me._svg_menu.getElementById("fuelfailind").hide();
		me._fuel_active	= me._svg_menu.getElementById("fuel_active").hide();
		me._controls	= me._svg_menu.getElementById("field_controls");
		me._controls_ind	= me._svg_menu.getElementById("controlsfailind").hide();
		me._controls_active 	= me._svg_menu.getElementById("controls_active").hide();
		me._deice		= me._svg_menu.getElementById("field_deice");
		me._deice_ind	= me._svg_menu.getElementById("deicefailind").hide();
		me._deice_active	= me._svg_menu.getElementById("deice_active").hide();
		me._avionic		= me._svg_menu.getElementById("field_avionic");
		me._avionic_ind	= me._svg_menu.getElementById("avionicfailind").hide();
		me._avionic_active	= me._svg_menu.getElementById("avionic_active").hide();
		me._autopilot		= me._svg_menu.getElementById("field_autopilot");
		me._autopilot_ind	= me._svg_menu.getElementById("autopilotfailind").hide();
		me._autopilot_active	= me._svg_menu.getElementById("autopilot_active").hide();
		me._frame		= me._svg_menu.getElementById("frame");	

		me._repair		= me._svg_menu.getElementById("field_repairall");

	# lower menu
		me._lmfielddelay	= me._svg_lmenu.getElementById("field_delay");
		me._lmvaluedelay 	= me._svg_lmenu.getElementById("value_delay");

	# welcome
		me._ranfail		= me._svg_welcome.getElementById("field_ranfail");
		me._randombackgr	= me._svg_welcome.getElementById("backgr_ranfail");
		me._fielddelay	= me._svg_welcome.getElementById("field_faildelay");
		me._valuedelay 	= me._svg_welcome.getElementById("value_faildelay");

	# gear
		me._LHgear		= me._svg_gear.getElementById("LHgear");
		me._RHgear		= me._svg_gear.getElementById("RHgear");
		me._Ngear		= me._svg_gear.getElementById("Ngear");
		me._LHbrake		= me._svg_gear.getElementById("LHbrake");
		me._RHbrake		= me._svg_gear.getElementById("RHbrake");
		me._LHtyre		= me._svg_gear.getElementById("LHtyre");
		me._RHtyre		= me._svg_gear.getElementById("RHtyre");
		me._Ntyre		= me._svg_gear.getElementById("Ntyre");

		me._Text_LHgear		= me._svg_gear.getElementById("text_LHgear").hide();
		me._Text_RHgear		= me._svg_gear.getElementById("text_RHgear").hide();
		me._Text_Ngear		= me._svg_gear.getElementById("text_Ngear").hide();
		me._Text_LHbrake		= me._svg_gear.getElementById("text_LHbrake").hide();
		me._Text_RHbrake		= me._svg_gear.getElementById("text_RHbrake").hide();
		me._Text_LHtyre		= me._svg_gear.getElementById("text_LHtyre").hide();
		me._Text_RHtyre		= me._svg_gear.getElementById("text_RHtyre").hide();
		me._Text_Ntyre		= me._svg_gear.getElementById("text_Ntyre").hide();

	# fuel
		me._Laux		= me._svg_fuel.getElementById("Laux");
		me._Lmain		= me._svg_fuel.getElementById("Lmain");
		me._Lcol		= me._svg_fuel.getElementById("Lcol");
		me._Rcol		= me._svg_fuel.getElementById("Rcol");
		me._Rmain		= me._svg_fuel.getElementById("Rmain");
		me._Raux		= me._svg_fuel.getElementById("Raux");
		me._LCV		= me._svg_fuel.getElementById("LHcheckvalve");
		me._RCV		= me._svg_fuel.getElementById("RHcheckvalve");
		me._LCV_field	= me._svg_fuel.getElementById("LHcvfield");
		me._RCV_field	= me._svg_fuel.getElementById("RHcvfield");
		me._SelValve	= me._svg_fuel.getElementById("selectorValve");
		me._Filter		= me._svg_fuel.getElementById("filter");
		me._pump1		= me._svg_fuel.getElementById("pump1");
		me._pump2		= me._svg_fuel.getElementById("pump2");
		me._pumpcv1		= me._svg_fuel.getElementById("pumpcv1");
		me._pumpcv2		= me._svg_fuel.getElementById("pumpcv2");
		me._FFtransd	= me._svg_fuel.getElementById("fftransd");
		me._LMFilter	= me._svg_fuel.getElementById("LHmotivefilter");
		me._RMFilter	= me._svg_fuel.getElementById("RHmotivefilter");
		me._LMpump		= me._svg_fuel.getElementById("LHmotivepump");
		me._RMpump		= me._svg_fuel.getElementById("RHmotivepump");
		me._LauxJpump	= me._svg_fuel.getElementById("LHauxjetpump");
		me._RauxJpump	= me._svg_fuel.getElementById("RHauxjetpump");
		me._LmainOutJpump	= me._svg_fuel.getElementById("LHmainoutjetpump");
		me._RmainOutJpump	= me._svg_fuel.getElementById("RHmainoutjetpump");
		me._LmainInJpump	= me._svg_fuel.getElementById("LHmaininjetpump");
		me._RmainInJpump	= me._svg_fuel.getElementById("RHmaininjetpump");

		me._Text_Laux		= me._svg_fuel.getElementById("text_Laux").hide();
		me._Text_Lmain		= me._svg_fuel.getElementById("text_Lmain").hide();
		me._Text_Lcol		= me._svg_fuel.getElementById("text_Lcol").hide();
		me._Text_Raux		= me._svg_fuel.getElementById("text_Raux").hide();
		me._Text_Rmain		= me._svg_fuel.getElementById("text_Rmain").hide();
		me._Text_Rcol		= me._svg_fuel.getElementById("text_Rcol").hide();
		me._Text_LCV		= me._svg_fuel.getElementById("text_LCV").hide();
		me._Text_RCV		= me._svg_fuel.getElementById("text_RCV").hide();
		me._Text_SelValve		= me._svg_fuel.getElementById("text_selectorValve").hide();
		me._Text_pump1		= me._svg_fuel.getElementById("text_pump1").hide();
		me._Text_pump2		= me._svg_fuel.getElementById("text_pump2").hide();
		me._Text_pumpcv1		= me._svg_fuel.getElementById("text_pumpcv1").hide();
		me._Text_pumpcv2		= me._svg_fuel.getElementById("text_pumpcv2").hide();
		me._Text_LMpump		= me._svg_fuel.getElementById("text_LMpump").hide();
		me._Text_RMpump		= me._svg_fuel.getElementById("text_RMpump").hide();

	# control system
		me._LAileron	= me._svg_contr.getElementById("LAileron");
		me._RAileron	= me._svg_contr.getElementById("RAileron");
		me._Elevator	= me._svg_contr.getElementById("layer4");
		me._LElevator	= me._svg_contr.getElementById("Lelevator");
		me._RElevator	= me._svg_contr.getElementById("Relevator");
		me._LFlap		= me._svg_contr.getElementById("LHFlap");
		me._RFlap		= me._svg_contr.getElementById("RHFlap");
		me._ElevatorTrim	= me._svg_contr.getElementById("elevatorTrim");
		me._Rudder		= me._svg_contr.getElementById("rudder");

		me._Text_LAil	= me._svg_contr.getElementById("text_LHAil");
		me._Text_RAil	= me._svg_contr.getElementById("text_RHAil");
		me._Text_Elevator	= me._svg_contr.getElementById("text_Elevator").hide();
		me._Text_LFlap	= me._svg_contr.getElementById("text_LHFlap").hide();
		me._Text_RFlap	= me._svg_contr.getElementById("text_RHFlap").hide();
		me._Text_Rudder	= me._svg_contr.getElementById("text_Rudder").hide();
		me._Text_Trim	= me._svg_contr.getElementById("text_Trim").hide();

	# deice system
		me._ROBoot		= me._svg_deice.getElementById("RHouterB");
		me._LOBoot		= me._svg_deice.getElementById("LHouterB");
		me._RIBoot		= me._svg_deice.getElementById("RHinnerB");
		me._LIBoot		= me._svg_deice.getElementById("LHinnerB");
		me._RHSBoot		= me._svg_deice.getElementById("RHhstabB");
		me._LHSBoot		= me._svg_deice.getElementById("LHhstabB");
		me._VSBoot		= me._svg_deice.getElementById("VstabB");
		me._RPitot		= me._svg_deice.getElementById("RHpitot");
		me._LPitot		= me._svg_deice.getElementById("LHpitot");
		me._StallWarner	= me._svg_deice.getElementById("StallWarner");
		me._WindshHeat	= me._svg_deice.getElementById("WindshHeat");
		me._PropH		= me._svg_deice.getElementById("propH");
		me._EngInletHeat	= me._svg_deice.getElementById("EngInletHeat");

		me._Text_ROBoot	= me._svg_deice.getElementById("text_ROBoot").hide();
		me._Text_LOBoot	= me._svg_deice.getElementById("text_LOBoot").hide();
		me._Text_RIBoot	= me._svg_deice.getElementById("text_RIBoot").hide();
		me._Text_LIBoot	= me._svg_deice.getElementById("text_LIBoot").hide();
		me._Text_RHSBoot	= me._svg_deice.getElementById("text_RHSBoot").hide();
		me._Text_LHSBoot	= me._svg_deice.getElementById("text_LHSBoot").hide();
		me._Text_VSBoot	= me._svg_deice.getElementById("text_VSBoot").hide();
		me._Text_LPitot	= me._svg_deice.getElementById("text_LPitot").hide();
		me._Text_RPitot	= me._svg_deice.getElementById("text_RPitot").hide();
		me._Text_WindSh	= me._svg_deice.getElementById("text_WindSh").hide();
		me._Text_PropH	= me._svg_deice.getElementById("text_PropH").hide();
		me._Text_StallWarner	= me._svg_deice.getElementById("text_StallWarner");
		me._Text_EngInletHeat	= me._svg_deice.getElementById("text_EngInletHeat");

	# avionic system
		me._ASInd		= me._svg_avionic.getElementById("STBYIASIND");
		me._AttInd		= me._svg_avionic.getElementById("STBYATTIND");
		me._AltInd		= me._svg_avionic.getElementById("STBYALTIND");
		me._LHStatic	= me._svg_avionic.getElementById("LHSTATIC");
		me._LHPitot1	= me._svg_avionic.getElementById("LHPITOT1");
		me._LHPitot2	= me._svg_avionic.getElementById("LHPITOT2");
		me._GPS1		= me._svg_avionic.getElementById("LHGPS");
		me._NAV1		= me._svg_avionic.getElementById("LHNAV");
		me._GS1		= me._svg_avionic.getElementById("LHGS");
		me._DME		= me._svg_avionic.getElementById("DME");
		me._HDG1		= me._svg_avionic.getElementById("LHHDG");
		me._PITCH1		= me._svg_avionic.getElementById("LHPITCH");
		me._ROLL1		= me._svg_avionic.getElementById("LHROLL");
		me._TAS		= me._svg_avionic.getElementById("TAS");
		me._KBD		= me._svg_avionic.getElementById("KBD").hide();
		me._XPDR		= me._svg_avionic.getElementById("XPDR");

		me._RHStatic	= me._svg_avionic.getElementById("RHSTATIC");
		me._RHPitot1	= me._svg_avionic.getElementById("RHPITOT1");
		me._RHPitot2	= me._svg_avionic.getElementById("RHPITOT2");
		me._GPS2		= me._svg_avionic.getElementById("RHGPS");
		me._NAV2		= me._svg_avionic.getElementById("RHNAV");
		me._GS2		= me._svg_avionic.getElementById("RHGS");
		me._HDG2		= me._svg_avionic.getElementById("RHHDG");
		me._PITCH2		= me._svg_avionic.getElementById("RHPITCH");
		me._ROLL2		= me._svg_avionic.getElementById("RHROLL");

		me._Text_ASInd	= me._svg_avionic.getElementById("text_STBYIASIND").hide();
		me._Text_AttInd	= me._svg_avionic.getElementById("text_STBYATTIND").hide();
		me._Text_AltInd	= me._svg_avionic.getElementById("text_STBYALTIND").hide();
		me._Text_LHStatic	= me._svg_avionic.getElementById("text_LHSTATIC").hide();
		me._Text_LHPitot1	= me._svg_avionic.getElementById("text_LHPITOT1").hide();
		me._Text_LHPitot2	= me._svg_avionic.getElementById("text_LHPITOT2").hide();
		me._Text_GPS1	= me._svg_avionic.getElementById("text_LHGPS").hide();
		me._Text_NAV1	= me._svg_avionic.getElementById("text_LHNAV").hide();
		me._Text_GS1	= me._svg_avionic.getElementById("text_LHGS").hide();
		me._Text_DME	= me._svg_avionic.getElementById("text_DME").hide();
		me._Text_HDG1	= me._svg_avionic.getElementById("text_LHHDG").hide();
		me._Text_PITCH1	= me._svg_avionic.getElementById("text_LHPITCH").hide();
		me._Text_ROLL1	= me._svg_avionic.getElementById("text_LHROLL").hide();
		me._Text_TAS	= me._svg_avionic.getElementById("text_TAS").hide();
		me._Text_KBD	= me._svg_avionic.getElementById("text_KBD").hide();
		me._Text_XPDR	= me._svg_avionic.getElementById("text_XPDR").hide();

		me._Text_RHStatic	= me._svg_avionic.getElementById("text_RHSTATIC").hide();
		me._Text_RHPitot1	= me._svg_avionic.getElementById("text_RHPITOT1").hide();
		me._Text_RHPitot2	= me._svg_avionic.getElementById("text_RHPITOT2").hide();
		me._Text_GPS2	= me._svg_avionic.getElementById("text_RHGPS").hide();
		me._Text_NAV2	= me._svg_avionic.getElementById("text_RHNAV").hide();
		me._Text_GS2	= me._svg_avionic.getElementById("text_RHGS").hide();
		me._Text_HDG2	= me._svg_avionic.getElementById("text_RHHDG").hide();
		me._Text_PITCH2	= me._svg_avionic.getElementById("text_RHPITCH").hide();
		me._Text_ROLL2	= me._svg_avionic.getElementById("text_RHROLL").hide();

	# autopilot
		me._TurnInd		= me._svg_ap.getElementById("turnind");
		me._PitchServo	= me._svg_ap.getElementById("pitchServo");
		me._RollServo	= me._svg_ap.getElementById("rollServo");
		me._PitchTrimServo	= me._svg_ap.getElementById("pitchTrimServo");
		me._altSens		= me._svg_ap.getElementById("altSens");

		me._Text_TurnInd	= me._svg_ap.getElementById("text_TURNIND").hide();
		me._Text_PitchServo	= me._svg_ap.getElementById("text_pitchServo").hide();
		me._Text_RollServo	= me._svg_ap.getElementById("text_rollServo").hide();
		me._Text_PitchTrimServo	= me._svg_ap.getElementById("text_pitchTrimServo").hide();
		me._Text_altSens	= me._svg_ap.getElementById("text_altSens").hide();

# additional elements
	#number of failure indication in menu
		me._gearfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)         
      		.setAlignment("center-center") 
      		.setTranslation(91, 23);

		me._fuelfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)        
      		.setAlignment("center-center") 
      		.setTranslation(165, 23);

		me._controlsfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)  
      		.setAlignment("center-center") 
      		.setTranslation(277, 23);

		me._deicefailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)  
      		.setAlignment("center-center") 
      		.setTranslation(350, 23);  

		me._avionicfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)  
      		.setAlignment("center-center") 
      		.setTranslation(437, 23);  

		me._autopilotfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)  
      		.setAlignment("center-center") 
      		.setTranslation(526, 23);  

	# fuel text elements
		me._Text_Filter = me._root.createChild("text")
      		.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(410, 325) 
			.setColor(0,0,0,1);

		me._Text_FFtransd = me._root.createChild("text")
      		.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(410, 415) 
			.setColor(0,0,0,1);

		me._Text_LMFilter = me._root.createChild("text")
      		.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(200, 50) 
			.setColor(0,0,0,1);

		me._Text_RMFilter = me._root.createChild("text")
      		.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(400, 50) 
			.setColor(0,0,0,1);

		me._Text_LmainInJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(150, 250) 
			.setColor(0,0,0,1);

		me._Text_RmainInJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(450, 250) 
			.setColor(0,0,0,1);

		me._Text_LmainOutJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(100, 270) 
			.setColor(0,0,0,1);

		me._Text_RmainOutJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(525, 270) 
			.setColor(0,0,0,1);

		me._Text_LauxJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(50, 290) 
			.setColor(0,0,0,1);

		me._Text_RauxJpump = me._root.createChild("text")
     			.setFontSize(12, 1.5)  
      		.setAlignment("left-center") 
      		.setTranslation(560, 290) 
			.setColor(0,0,0,1);

# listeners
		me.setListeners(instance = me);

# initialisation
		me._menuReset();
		me._updateMenu();
		me._hideAll();
		me._svg_welcome.show();
		me._welcome_update();
		me._svg_menu.show();
		me._frame.setColorFill(COLORfd["menuns"]);

	},
	onClose : func(){
		me.close();	
	},
	setListeners : func(instance) {
	# menu
		me._gear.addEventListener("click",func(){me._onGearClick();});
		me._fuel.addEventListener("click",func(){me._onFuelClick();});
		me._controls.addEventListener("click",func(){me._onControlsClick();});
		me._deice.addEventListener("click",func(){me._onDeiceClick();});
		me._avionic.addEventListener("click",func(){me._onAvionicClick();});
		me._autopilot.addEventListener("click",func(){me._onAutopilotClick();});
		me._repair.addEventListener("click",func(){
			events.failure_reset();					# nasal/failurescenarios.nas
			me._updateMenu();
			me._welcome_update();
		});

	# lower menu
		me._lmfielddelay.addEventListener("wheel",func(e){me._onDelayChange(e);});

	# welcome
		me._ranfail.addEventListener("click",func(){me._onRandomClick();});	
		me._fielddelay.addEventListener("wheel",func(e){me._onRandomDelayChange(e);});

	# gear
		me._LHgear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/LMG-free",0,"LMG_jammed","gear");});
		me._RHgear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/RMG-free",0,"RMG_jammed","gear");});
		me._Ngear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/NG-free",0,"NG_jammed","gear");});
		me._LHbrake.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[1]/brakeFail",1,"Lbrake","gear");});
		me._RHbrake.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[2]/brakeFail",1,"Rbrake","gear");});
		me._LHtyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[1]/flatTire",1,"LMG_flat","gear");});
		me._RHtyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[2]/flatTire",1,"RMG_flat","gear");});
		me._Ntyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[0]/flatTire",1,"NG_flat","gear");});

	# fuel
		me._Laux.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/aux/leakage/state",1,"LAux_leakage","fuel");});
		me._Lmain.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/main/leakage/state",1,"LMain_leakage","fuel");});
		me._Lcol.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/collector/leakage/state",1,"LCol_leakage","fuel");});
		me._Raux.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/aux/leakage/state",1,"RAux_leakage","fuel");});
		me._Rmain.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/main/leakage/state",1,"RMain_leakage","fuel");});
		me._Rcol.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/collector/leakage/state",1,"RCol_leakage","fuel");});
		me._LCV.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/checkvalve/serviceable",0,"LcheckvalveFail","fuel");});
		me._RCV.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/checkvalve/serviceable",0,"RcheckvalveFail","fuel");});
		me._Filter.addEventListener("click",func(){me._onValueClick("/systems/fuel/fuelfilter/clogged","filterFail","fuel");});
		me._SelValve.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/selectorValve/serviceable",0,"SelectorValveFail","fuel");});
		me._pump1.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FuelPump1/serviceable",0,"fuelPump1Fail","fuel");});
		me._pump2.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FuelPump2/serviceable",0,"fuelPump2Fail","fuel");});
		me._pumpcv1.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FP1checkvalve/serviceable",0,"fuelPumpCV1Fail","fuel");});
		me._pumpcv2.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FP2checkvalve/serviceable",0,"fuelPumpCV2Fail","fuel");});
		me._FFtransd.addEventListener("click",func(){me._onValueClick("/systems/fuel/FFtransducer/blocked","fftransdFail","fuel");});

		me._LMFilter.addEventListener("click",func(){me._onValueClick("/systems/fuel/LHtank/motivefilter/clogged","LtransfilterFail","fuel");});	
		me._RMFilter.addEventListener("click",func(){me._onValueClick("/systems/fuel/RHtank/motivefilter/clogged","RtransfilterFail","fuel");});	
		me._LMpump.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/motivepump/serviceable",0,"LtransferPumpFail","fuel");});		
		me._RMpump.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/motivepump/serviceable",0,"RtransferPumpFail","fuel");});		
		me._LmainInJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/LHtank/main/innerjetpump/clogged","LMinnerjetpumpFail","fuel");});	
		me._RmainInJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/RHtank/main/innerjetpump/clogged","RMinnerjetpumpFail","fuel");});	
		me._LmainOutJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/LHtank/main/outerjetpump/clogged","LMouterjetpumpFail","fuel");});	
		me._RmainOutJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/RHtank/main/outerjetpump/clogged","RMouterjetpumpFail","fuel");});	
		me._LauxJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/LHtank/aux/jetpump/clogged","LAjetpumpFail","fuel");});	
		me._RauxJpump.addEventListener("click",func(){me._onValueClick("/systems/fuel/RHtank/aux/jetpump/clogged","RAjetpumpFail","fuel");});	

	# control system
		me._LAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/L-aileron",1,"LAil","contr");});
		me._RAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/R-aileron",1,"RAil","contr");});
		me._Elevator.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/elevator",1,"Elevator","contr");});
		me._LFlap.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/L-flap",1,"LFlap","contr");});
		me._RFlap.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/R-flap",1,"RFlap","contr");});
		me._Rudder.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/rudder",1,"Rudder","contr");});
		me._ElevatorTrim.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/trim",1,"Trim","contr");});
	# deice system
		me._ROBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/RHouterBoot/serviceable",0,"RHouterBootFail","deice");});		
		me._LOBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/LHouterBoot/serviceable",0,"LHouterBootFail","deice");});		
		me._RIBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/RHinnerBoot/serviceable",0,"RHinnerBootFail","deice");});		
		me._LIBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/LHinnerBoot/serviceable",0,"LHinnerBootFail","deice");});
		me._RHSBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/RHHStabBoot/serviceable",0,"RHHStabBootFail","deice");});		
		me._LHSBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/LHHStabBoot/serviceable",0,"LHHStabBootFail","deice");});		
		me._VSBoot.addEventListener("click",func(){me._onGeneralClick("/systems/pneumatic/VStabBoot/serviceable",0,"VStabBootFail","deice");});		
		me._LPitot.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/PitotHeatLeft/service/serviceable",0,"LHPitotHeatFail","deice");});		
		me._RPitot.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/PitotHeatRight/service/serviceable",0,"RHPitotHeatFail","deice");});		
		me._WindshHeat.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/WindshieldHeat/service/serviceable",0,"WindshieldHeatFail","deice");});	
		me._StallWarner.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/StallHeat/service/serviceable",0,"StallHeatFail","deice");});
		me._PropH.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/Propeller/service/serviceable",0,"PropHeatFail","deice");});		
		me._EngInletHeat.addEventListener("click",func(){me._onGeneralClick("/extra500/system/deice/IntakeHeat/serviceable",0,"InletAntiIceFail","deice");});		
	# avionic system
		me._ASInd.addEventListener("click",func(){me._onGeneralClick("/extra500/instrumentation/StbyASI/fail",1,"BackupAirInd","avionic");});			
		me._AttInd.addEventListener("click",func(){me._onGeneralClick("/extra500/instrumentation/StbyHSI/fail",1,"BackupAttInd","avionic");});	
		me._AltInd.addEventListener("click",func(){me._onGeneralClick("/extra500/instrumentation/StbyALT/fail",1,"BackupAltInd","avionic");});			
		me._LHStatic.addEventListener("click",func(){me._onGeneralClick("/systems/staticL/leaking",1,"LHStaticLeak","avionic");});		
		me._LHPitot1.addEventListener("click",func(){me._onGeneralClick("/systems/pitotL/leaking1",1,"LHPitotLeak1","avionic");});		
		me._LHPitot2.addEventListener("click",func(){me._onGeneralClick("/systems/pitotL/leaking2",1,"LHPitotLeak2","avionic");});		
		me._GPS1.addEventListener("click",func(){me._onGeneralClick("/instrumentation/gps/serviceable",0,"GPS1Fail","avionic");});		
		me._NAV1.addEventListener("click",func(){me._onGeneralClick("/instrumentation/nav/serviceable",0,"NAV1Fail","avionic");});			
		me._GS1.addEventListener("click",func(){me._onGeneralClick("/instrumentation/nav/gs/serviceable",0,"GS1Fail","avionic");});			
		me._DME.addEventListener("click",func(){me._onGeneralClick("/instrumentation/dme/serviceable",0,"DMEFail","avionic");});			
		me._HDG1.addEventListener("click",func(){me._onProgessiveClick("LHHeading",0.05,0,30,"/extra500/instrumentation/IFD-LH/heading/error","avionic");});			
		me._PITCH1.addEventListener("click",func(){me._onProgessiveClick("LHPitch",0.05,0,30,"/extra500/instrumentation/IFD-LH/attitude/pitch-error","avionic");});			
		me._ROLL1.addEventListener("click",func(){me._onProgessiveClick("LHRoll",0.05,0,30,"/extra500/instrumentation/IFD-LH/attitude/roll-error","avionic");});			
		me._RHStatic.addEventListener("click",func(){me._onGeneralClick("/systems/staticR/leaking",1,"RHStaticLeak","avionic");});		
		me._RHPitot1.addEventListener("click",func(){me._onGeneralClick("/systems/pitotR/leaking1",1,"RHPitotLeak1","avionic");});		
		me._RHPitot2.addEventListener("click",func(){me._onGeneralClick("/systems/pitotR/leaking2",1,"RHPitotLeak2","avionic");});		
		me._GPS2.addEventListener("click",func(){me._onGeneralClick("/instrumentation/gps[1]/serviceable",0,"GPS2Fail","avionic");});		
		me._NAV2.addEventListener("click",func(){me._onGeneralClick("/instrumentation/nav[1]/serviceable",0,"NAV2Fail","avionic");});			
		me._GS2.addEventListener("click",func(){me._onGeneralClick("/instrumentation/nav[1]/gs/serviceable",0,"GS2Fail","avionic");});			
		me._HDG2.addEventListener("click",func(){me._onProgessiveClick("RHHeading",0.05,0,30,"/extra500/instrumentation/IFD-RH/heading/error","avionic");});			
		me._PITCH2.addEventListener("click",func(){me._onProgessiveClick("RHPitch",0.05,0,30,"/extra500/instrumentation/IFD-RH/attitude/pitch-error","avionic");});			
		me._ROLL2.addEventListener("click",func(){me._onProgessiveClick("RHRoll",0.05,0,30,"/extra500/instrumentation/IFD-RH/attitude/roll-error","avionic");});			
		me._TAS.addEventListener("click",func(){me._onGeneralClick("/instrumentation/tcas/fail",1,"TASFail","avionic");});			
#		me._KBD.addEventListener("click",func(){me._onGeneralClick("/extra500/instrumentation/Keypad/serviceable",0,"KBDFail","avionic");});			
		me._XPDR.addEventListener("click",func(){me._onGeneralClick("/extra500/instrumentation/xpdr/fail",1,"XPDRFail","avionic");});			

	# autopilot
		me._TurnInd.addEventListener("click",func(){me._onGeneralClick("/instrumentation/turn-indicator/serviceable",0,"TurnInd","autopilot");});
		me._PitchServo.addEventListener("click",func(){me._onGeneralClick("/autopilot/runaway/pitch",1,"PitchRunaway","autopilot");});
		me._RollServo.addEventListener("click",func(){me._onGeneralClick("/autopilot/runaway/roll",1,"RollRunaway","autopilot");});
		me._PitchTrimServo.addEventListener("click",func(){me._onGeneralClick("/autopilot/runaway/pitchtrim",1,"PitchtrimRunaway","autopilot");});
		me._altSens.addEventListener("click",func(){me._onGeneralClick("/autopilot/altsensor/serviceable",0,"APaltSensFail","autopilot");});
	},
	_timerf : func(){
		setprop("/extra500/failurescenarios/delay",getprop("/extra500/failurescenarios/delay")-1);
		var delay = getprop("/extra500/failurescenarios/delay");
		me._lm_update(delay);
		if (delay != 0) {
			me._lmfielddelay.setColorFill(COLORfd["randomB"]);
		} else {
			me._lmfielddelay.setColorFill(COLORfd["menuns"]);
		}
	},
	_onDelayChange : func(e){
		var delay = getprop("/extra500/failurescenarios/delay")+ e.deltaY;
		delay = math.clamp(delay,0,60);
		setprop("/extra500/failurescenarios/delay",delay);
		if (delay != 0) {
			me._lmfielddelay.setColorFill(COLORfd["randomC"]);
		} else {
			me._lmfielddelay.setColorFill(COLORfd["menuns"]);
		}
		me._lm_update();
	},
	_onRandomClick : func() {
		events.randomfail(); # nasal/failurescenarios.nas
		me._welcome_update();
	},
	_onRandomDelayChange : func(e){
		var delay = getprop("/extra500/failurescenarios/randommaxdelay") + e.deltaY;
		delay = math.clamp(delay,0,60);
		setprop("/extra500/failurescenarios/randommaxdelay",delay);
		me._welcome_update();
	},
	_menuReset : func() {
		me._gear.setColorFill(COLORfd["menuns"]);
		me._fuel.setColorFill(COLORfd["menuns"]);
		me._controls.setColorFill(COLORfd["menuns"]);
		me._deice.setColorFill(COLORfd["menuns"]);
		me._avionic.setColorFill(COLORfd["menuns"]);
		me._autopilot.setColorFill(COLORfd["menuns"]);
	},
	_hideAll : func() {   # except for menu 
		me._svg_gear.hide();
		me._svg_fuel.hide();
		me._svg_contr.hide();
		me._svg_deice.hide();
		me._svg_avionic.hide();
		me._svg_ap.hide();
		me._svg_welcome.hide();
		me._svg_lmenu.hide();

		me._gear_active.hide();
		me._fuel_active.hide();
		me._controls_active.hide();
		me._deice_active.hide();
		me._avionic_active.hide();
		me._autopilot_active.hide();

		me._Text_Filter.hide();
		me._Text_FFtransd.hide();
		me._Text_LMFilter.hide();
		me._Text_RMFilter.hide();
		me._Text_LmainInJpump.hide();
		me._Text_RmainInJpump.hide();
		me._Text_LmainOutJpump.hide();
		me._Text_RmainOutJpump.hide();
		me._Text_LauxJpump.hide();
		me._Text_RauxJpump.hide();
	},
	_updateMenu : func() {
		me._gearButtons_update();
		me._fuelButtons_update();
		me._contrButtons_update();
		me._deiceButtons_update();
		me._avionicButtons_update();
		me._autopilotButtons_update();
	},
	_onGearClick : func() {
		me._menuReset();
		me._gear.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_lmenu.show();
		me._gear_active.show();
		me._svg_gear.show();
		me._gearButtons_update();
	},
	_onFuelClick : func() {
		me._menuReset();
		me._fuel.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._fuel_active.show();
		me._svg_fuel.show();
		me._svg_lmenu.show();
		me._fuelButtons_update();
	},
	_onControlsClick : func() {
		me._menuReset();
		me._controls.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_lmenu.show();
		me._controls_active.show();
		me._svg_contr.show();
		me._contrButtons_update();
	},
	_onDeiceClick : func() {
		me._menuReset();
		me._deice.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_lmenu.show();
		me._deice_active.show();
		me._svg_deice.show();
		me._deiceButtons_update();
	},
	_onAvionicClick : func() {
		me._menuReset();
		me._avionic.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_lmenu.show();
		me._avionic_active.show();
		me._svg_avionic.show();
		me._avionicButtons_update();
	},
	_onAutopilotClick : func() {
		me._menuReset();
		me._autopilot.setColorFill(COLORfd["menuse"]);
		me._frame.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_lmenu.show();
		me._autopilot_active.show();
		me._svg_ap.show();
		me._autopilotButtons_update();
	},
	_genButtons_update : func(gfailprop,glogic,gfield,gtext,gcolor,gfail) {			# for 'servicable' values, so glogic 0 or 1
		if ( getprop(gfailprop) == glogic ) {
			gfield.setColorFill(COLORfd[gcolor]);
			gtext.hide();
		} else {
			gfield.setColorFill(COLORfd["Failed"]);
			gtext.show();
			setprop(gfail,getprop(gfail) + 1);
		}
	},
	_valButtons_update : func(gfailprop,gfield,gtext,gcolor,gfail,fixedtext1,fixedtext2) {				# for step values between 0-1
		if ( getprop(gfailprop) == 0 ) {
			gfield.setColorFill(COLORfd[gcolor]);
			gtext.hide();
		} else {
			gfield.setColorFill(COLORfd["Failed"]);
			var full_text = fixedtext1 ~ math.round(getprop(gfailprop)*100) ~ fixedtext2;
			gtext.show();
			gtext.setText(full_text);					
			setprop(gfail,getprop(gfail) + 1);
		}
	},
	_lm_update : func(delay=nil) {
		if (delay == nil) {
			var delay = getprop("/extra500/failurescenarios/delay");
		}
		me._lmvaluedelay.setText(sprintf("%i",delay));
	},
	_welcome_update : func() {
		var randomactive = getprop("/extra500/failurescenarios/random_active");
		me._valuedelay.setText(sprintf("%i",getprop("/extra500/failurescenarios/randommaxdelay")));
		if (randomactive == 1) {
			me._randombackgr.setColorFill(COLORfd["randomA"]);
		} else {
			me._randombackgr.setColorFill(COLORfd["menuns"]);
		}

	},
	_fuelButtons_update : func() {
		setprop("/extra500/failurescenarios/fuel",0);
		me._genButtons_update("/systems/fuel/LHtank/aux/leakage/state",0,me._Laux,me._Text_Laux,"auxOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/main/leakage/state",0,me._Lmain,me._Text_Lmain,"mainOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/collector/leakage/state",0,me._Lcol,me._Text_Lcol,"colOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/aux/leakage/state",0,me._Raux,me._Text_Raux,"auxOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/main/leakage/state",0,me._Rmain,me._Text_Rmain,"mainOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/collector/leakage/state",0,me._Rcol,me._Text_Rcol,"colOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/checkvalve/serviceable",1,me._LCV_field,me._Text_LCV,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/checkvalve/serviceable",1,me._RCV_field,me._Text_RCV,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/selectorValve/serviceable",1,me._SelValve,me._Text_SelValve,"CVOk","/extra500/failurescenarios/fuel");
		me._valButtons_update("/systems/fuel/fuelfilter/clogged",me._Filter,me._Text_Filter,"CVOk","/extra500/failurescenarios/fuel","Fuel filter is ","% clogged");
		me._genButtons_update("/systems/fuel/FuelPump1/serviceable",1,me._pump1,me._Text_pump1,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FuelPump2/serviceable",1,me._pump2,me._Text_pump2,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FP1checkvalve/serviceable",1,me._pumpcv1,me._Text_pumpcv1,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FP2checkvalve/serviceable",1,me._pumpcv2,me._Text_pumpcv2,"CVOk","/extra500/failurescenarios/fuel");
		me._valButtons_update("/systems/fuel/FFtransducer/blocked",me._FFtransd,me._Text_FFtransd,"CVOk","/extra500/failurescenarios/fuel","Fuel flow transducer is ","% blocked");
		me._valButtons_update("/systems/fuel/LHtank/motivefilter/clogged",me._LMFilter,me._Text_LMFilter,"CVOk","/extra500/failurescenarios/fuel","Motive flow filter is ","% blocked");
		me._valButtons_update("/systems/fuel/RHtank/motivefilter/clogged",me._RMFilter,me._Text_RMFilter,"CVOk","/extra500/failurescenarios/fuel","Motive flow filter is ","% blocked");
		me._genButtons_update("/systems/fuel/LHtank/motivepump/serviceable",1,me._LMpump,me._Text_LMpump,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/motivepump/serviceable",1,me._RMpump,me._Text_RMpump,"CVOk","/extra500/failurescenarios/fuel");
		me._valButtons_update("/systems/fuel/LHtank/main/innerjetpump/clogged",me._LmainInJpump,me._Text_LmainInJpump,"CVOk","/extra500/failurescenarios/fuel","Inner Jetpump is ","% clogged");
		me._valButtons_update("/systems/fuel/RHtank/main/innerjetpump/clogged",me._RmainInJpump,me._Text_RmainInJpump,"CVOk","/extra500/failurescenarios/fuel","Inner Jetpump is ","% clogged");
		me._valButtons_update("/systems/fuel/LHtank/main/outerjetpump/clogged",me._LmainOutJpump,me._Text_LmainOutJpump,"CVOk","/extra500/failurescenarios/fuel","Middle Jetpump is ","% clogged");
		me._valButtons_update("/systems/fuel/RHtank/main/outerjetpump/clogged",me._RmainOutJpump,me._Text_RmainOutJpump,"CVOk","/extra500/failurescenarios/fuel","Middle Jetpump is ","% clogged");
		me._valButtons_update("/systems/fuel/LHtank/aux/jetpump/clogged",me._LauxJpump,me._Text_LauxJpump,"CVOk","/extra500/failurescenarios/fuel","Outer Jetpump is ","% clogged");
		me._valButtons_update("/systems/fuel/RHtank/aux/jetpump/clogged",me._RauxJpump,me._Text_RauxJpump,"CVOk","/extra500/failurescenarios/fuel","Outer Jetpump is ","% clogged");	

	# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/fuel") > 0) {
			me._fuel_ind.show();
			me._fuelfailnumber.setText(getprop("/extra500/failurescenarios/fuel"))
				.setColor(1,1,1,1);		
		} else {
			me._fuel_ind.hide();
			me._fuelfailnumber.setColor(1,1,1,0);
		}

	},
	_gearButtons_update : func() {
		setprop("/extra500/failurescenarios/gear",0);
		me._genButtons_update("/systems/gear/NG-free",1,me._Ngear,me._Text_Ngear,"GeaOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/systems/gear/RMG-free",1,me._RHgear,me._Text_RHgear,"GeaOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/systems/gear/LMG-free",1,me._LHgear,me._Text_LHgear,"GeaOk","/extra500/failurescenarios/gear");

		me._genButtons_update("/fdm/jsbsim/gear/unit[0]/flatTire",0,me._Ntyre,me._Text_Ntyre,"TyrOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/flatTire",0,me._LHtyre,me._Text_LHtyre,"TyrOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/flatTire",0,me._RHtyre,me._Text_RHtyre,"TyrOk","/extra500/failurescenarios/gear");

		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/brakeFail",0,me._LHbrake,me._Text_LHbrake,"BraOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/brakeFail",0,me._RHbrake,me._Text_RHbrake,"BraOk","/extra500/failurescenarios/gear");

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/gear") > 0) {
			me._gear_ind.show();
			me._gearfailnumber.setText(getprop("/extra500/failurescenarios/gear"))
				.setColor(1,1,1,1);		
		} else {
			me._gear_ind.hide();
			me._gearfailnumber.setColor(1,1,1,0);
		}

	},
	_contrButtons_update : func() {
		setprop("/extra500/failurescenarios/contr",0);
		me._genButtons_update("/extra500/failurescenarios/controls/L-aileron",0,me._LAileron,me._Text_LAil,"AilOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/R-aileron",0,me._RAileron,me._Text_RAil,"AilOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/rudder",0,me._Rudder,me._Text_Rudder,"RudOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/trim",0,me._ElevatorTrim,me._Text_Trim,"TriOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/L-flap",0,me._LFlap,me._Text_LFlap,"FlaOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/R-flap",0,me._RFlap,me._Text_RFlap,"FlaOk","/extra500/failurescenarios/contr");

		if ( getprop("/extra500/failurescenarios/controls/elevator") == 0 ) {
			me._LElevator.setColorFill(COLORfd["EleOk"]);
			me._RElevator.setColorFill(COLORfd["EleOk"]);
			me._Text_Elevator.hide();
		} else {
			me._LElevator.setColorFill(COLORfd["Failed"]);
			me._RElevator.setColorFill(COLORfd["Failed"]);
			me._Text_Elevator.show();
			setprop("/extra500/failurescenarios/contr",getprop("/extra500/failurescenarios/contr") + 1);
		}

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/contr") > 0) {
			me._controls_ind.show();
			me._controlsfailnumber.setText(getprop("/extra500/failurescenarios/contr"))
				.setColor(1,1,1,1);
		} else {
			me._controls_ind.hide();
			me._controlsfailnumber.setColor(1,1,1,0);
		}

	},
	_deiceButtons_update : func() {
		setprop("/extra500/failurescenarios/deice",0);

		me._genButtons_update("/systems/pneumatic/RHouterBoot/serviceable",1,me._ROBoot,me._Text_ROBoot,"boot2Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/systems/pneumatic/LHouterBoot/serviceable",1,me._LOBoot,me._Text_LOBoot,"boot2Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/systems/pneumatic/RHinnerBoot/serviceable",1,me._RIBoot,me._Text_RIBoot,"boot1Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/systems/pneumatic/LHinnerBoot/serviceable",1,me._LIBoot,me._Text_LIBoot,"boot1Ok","/extra500/failurescenarios/deice");
		me._genButtons_update("/systems/pneumatic/RHHStabBoot/serviceable",1,me._RHSBoot,me._Text_RHSBoot,"boot2Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/systems/pneumatic/LHHStabBoot/serviceable",1,me._LHSBoot,me._Text_LHSBoot,"boot2Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/systems/pneumatic/VStabBoot/serviceable",1,me._VSBoot,me._Text_VSBoot,"boot2Ok","/extra500/failurescenarios/deice");		
		me._genButtons_update("/extra500/system/deice/PitotHeatLeft/service/serviceable",1,me._LPitot,me._Text_LPitot,"pitotOk","/extra500/failurescenarios/deice");		
		me._genButtons_update("/extra500/system/deice/PitotHeatRight/service/serviceable",1,me._RPitot,me._Text_RPitot,"pitotOk","/extra500/failurescenarios/deice");		
		me._genButtons_update("/extra500/system/deice/WindshieldHeat/service/serviceable",1,me._WindshHeat,me._Text_WindSh,"windShOk","/extra500/failurescenarios/deice");	
		me._genButtons_update("/extra500/system/deice/StallHeat/service/serviceable",1,me._StallWarner,me._Text_StallWarner,"stallwOk","/extra500/failurescenarios/deice");
		me._genButtons_update("/extra500/system/deice/Propeller/service/serviceable",1,me._PropH,me._Text_PropH,"propOk","/extra500/failurescenarios/deice");		
		me._genButtons_update("/extra500/system/deice/IntakeHeat/serviceable",1,me._EngInletHeat,me._Text_EngInletHeat,"inletOk","/extra500/failurescenarios/deice");	

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/deice") > 0) {
			me._deice_ind.show();
			me._deicefailnumber.setText(getprop("/extra500/failurescenarios/deice"))
				.setColor(1,1,1,1);		
		} else {
			me._deice_ind.hide();
			me._deicefailnumber.setColor(1,1,1,0);
		}

	},
	_avionicButtons_update : func() {
		setprop("/extra500/failurescenarios/avionic",0);

		me._genButtons_update("/extra500/instrumentation/StbyASI/fail",0,me._ASInd,me._Text_ASInd,"opaque","/extra500/failurescenarios/avionic");	
		me._genButtons_update("/extra500/instrumentation/StbyHSI/fail",0,me._AttInd,me._Text_AttInd,"opaque","/extra500/failurescenarios/avionic");	
		me._genButtons_update("/extra500/instrumentation/StbyALT/fail",0,me._AltInd,me._Text_AltInd,"opaque","/extra500/failurescenarios/avionic");	
		me._genButtons_update("/systems/staticL/leaking",0,me._LHStatic,me._Text_LHStatic,"staticOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/systems/pitotL/leaking1",0,me._LHPitot1,me._Text_LHPitot1,"pitotOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/systems/pitotL/leaking2",0,me._LHPitot2,me._Text_LHPitot2,"pitotOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/gps/serviceable",1,me._GPS1,me._Text_GPS1,"gpsOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/nav/serviceable",1,me._NAV1,me._Text_NAV1,"navOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/nav/gs/serviceable",1,me._GS1,me._Text_GS1,"navOk","/extra500/failurescenarios/avionic");			
		me._genButtons_update("/extra500/instrumentation/IFD-LH/heading/error",0,me._HDG1,me._Text_HDG1,"black","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/extra500/instrumentation/IFD-LH/attitude/pitch-error",0,me._PITCH1,me._Text_PITCH1,"attOK","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/extra500/instrumentation/IFD-LH/attitude/roll-error",0,me._ROLL1,me._Text_ROLL1,"attOK","/extra500/failurescenarios/avionic");		

		me._genButtons_update("/systems/staticR/leaking",0,me._RHStatic,me._Text_RHStatic,"staticOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/systems/pitotR/leaking1",0,me._RHPitot1,me._Text_RHPitot1,"pitotOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/systems/pitotR/leaking2",0,me._RHPitot2,me._Text_RHPitot2,"pitotOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/gps[1]/serviceable",1,me._GPS2,me._Text_GPS2,"gpsOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/nav[1]/serviceable",1,me._NAV2,me._Text_NAV2,"navOk","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/instrumentation/nav[1]/gs/serviceable",1,me._GS2,me._Text_GS2,"navOk","/extra500/failurescenarios/avionic");			
		me._genButtons_update("/extra500/instrumentation/IFD-RH/heading/error",0,me._HDG2,me._Text_HDG2,"black","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/extra500/instrumentation/IFD-RH/attitude/pitch-error",0,me._PITCH2,me._Text_PITCH2,"attOK","/extra500/failurescenarios/avionic");		
		me._genButtons_update("/extra500/instrumentation/IFD-RH/attitude/roll-error",0,me._ROLL2,me._Text_ROLL2,"attOK","/extra500/failurescenarios/avionic");		

		me._genButtons_update("/instrumentation/dme/serviceable",1,me._DME,me._Text_DME,"dmeOk","/extra500/failurescenarios/avionic");	
		me._genButtons_update("/instrumentation/tcas/fail",0,me._TAS,me._Text_TAS,"dmeOk","/extra500/failurescenarios/avionic");		
#		me._genButtons_update("/extra500/instrumentation/Keypad/serviceable",1,me._KBD,me._Text_KBD,"dmeOk","/extra500/failurescenarios/avionic");			
		me._genButtons_update("/extra500/instrumentation/xpdr/fail",0,me._XPDR,me._Text_XPDR,"dmeOk","/extra500/failurescenarios/avionic");		

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/avionic") > 0) {
			me._avionic_ind.show();
			me._avionicfailnumber.setText(getprop("/extra500/failurescenarios/avionic"))
				.setColor(1,1,1,1);		
		} else {
			me._avionic_ind.hide();
			me._avionicfailnumber.setColor(1,1,1,0);
		}

	},
	_autopilotButtons_update : func() {
		setprop("/extra500/failurescenarios/autopilot",0);

		me._genButtons_update("/instrumentation/turn-indicator/serviceable",1,me._TurnInd,me._Text_TurnInd,"opaque","/extra500/failurescenarios/autopilot");		
		me._genButtons_update("/autopilot/runaway/pitch",0,me._PitchServo,me._Text_PitchServo,"ptsOK","/extra500/failurescenarios/autopilot");		
		me._genButtons_update("/autopilot/runaway/roll",0,me._RollServo,me._Text_RollServo,"rtsOK","/extra500/failurescenarios/autopilot");		
		me._genButtons_update("/autopilot/runaway/pitchtrim",0,me._PitchTrimServo,me._Text_PitchTrimServo,"pttsOK","/extra500/failurescenarios/autopilot");		
		me._genButtons_update("/autopilot/altsensor/serviceable",1,me._altSens,me._Text_altSens,"altsOK","/extra500/failurescenarios/autopilot");		

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/autopilot") > 0) {
			me._autopilot_ind.show();
			me._autopilotfailnumber.setText(getprop("/extra500/failurescenarios/autopilot"))
				.setColor(1,1,1,1);		
		} else {
			me._autopilot_ind.hide();
			me._autopilotfailnumber.setColor(1,1,1,0);
		}

	},
	_onGeneralClick : func(property,logic,failname,system){			# for 'servicable' values, so logic 0 or 1
		setprop("/extra500/failurescenarios/name",failname);
		if (getprop(property) == logic) {
			setprop("/extra500/failurescenarios/activate",0);
		} else {
			setprop("/extra500/failurescenarios/activate",1);
		}
		me._update_page(system);
	},
	_onValueClick : func(property,failname,system){				# for step values between 0-1
		setprop("/extra500/failurescenarios/name",failname);
		var value = getprop(property) + 0.1;
		if (value>1) {value = 0;}
		setprop("/extra500/failurescenarios/activate",value);
		me._update_page(system);
	},
	_onProgessiveClick : func(failname,speed,initial,maxValue,property,system){			# for 'progressive' failures
		if (getprop(property) == initial) {
#			setprop("/extra500/failurescenarios/name",failname);				# FIXME:
#			setprop("/extra500/failurescenarios/activate",0.001);				# FIXME: evil hack only to trick the detection system there is a failure
			events.addProgFailure(failname,speed,initial,maxValue);
		} else {
			events.delProgFailure(failname);
		}
		me._update_page_prog(system);	# no delay possible on progressive failures
	},
	_update_page_prog : func(system) {
		settimer(func(){
			me._update_page_direct(system);
			},1.2);			# waiting for at least 1 seconds so page update notices the failure
	},
	_update_page : func(system) {
		var delay = getprop("/extra500/failurescenarios/delay");
		if (delay != 0) {
			me._timer.start();
			settimer(func(){
				me._timer.stop();
				me._update_page_direct(system);
				setprop("/extra500/failurescenarios/delay",0);
				me._lmfielddelay.setColorFill(COLORfd["menuns"]);
				me._lm_update();
			},delay+0.2);
		} else {
			me._update_page_direct(system);
		}
	},
	_update_page_direct : func(system) {
		if (system == "deice") {me._deiceButtons_update(); } 
		else if (system == "fuel") {me._fuelButtons_update(); } 
		else if (system == "gear") {me._gearButtons_update(); }
		else if (system == "contr") {me._contrButtons_update();}
		else if (system == "avionic") {me._avionicButtons_update();}
		else if (system == "autopilot") {me._autopilotButtons_update();}
	}

};

var Failuredialog = FailureClass.new();




