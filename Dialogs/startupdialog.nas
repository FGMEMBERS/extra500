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
#	Date: 	17.06.2018
#
#	Last change: Eric van den Berg	
#	Date:		05.07.2018
#

var COLORid = {};
COLORid["menuns"] = "#009400ff";
COLORid["menuse"] = "#4293d1ff";

var InitDialogClass = {
	new : func(){
		var m = {parents:[InitDialogClass]};

		m._title = 'Extra500 startup Dialog';
		m._gfd 	= nil;
		m._canvas	= nil;
		m._timer 	= maketimer(2.0,m,InitDialogClass._timerf );
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
	_timerf : func(){
		me.close();
	},
	close : func(){
#                 print("InitDialogClass.close() ... ");    
             
		me.removeListeners();
                        
		me._gfd.del();
                me._gfd = nil;
		setprop("/extra500/exit/updatePos",1);	# after dialog is closed, start updating position
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	openDialog : func(){
		# making window
            var scale = getprop("extra500/config/dialog/init/scale");
		var size = [300*scale,200*scale];           
            
		me._gfd = canvas.extra500Window.new(size,[300,200],"dialog");
            me._gfd.onClose = func(){Initdialog.close();}
#  		me._gfd.onClose = func(){Initdialog.onClose();}
#		me._gfd.onClose = func(){me.onClose();}
#		me._gfd.onClose = func(){me._gfd.del();}

		me._gfd.set('title',me._title);
                me._gfd.move(10,20);
                
		me._canvas = me._gfd.createCanvas().set("background","dcdcdcff");
           	me._root = me._canvas.createGroup();
		
		# parsing svg-s
		me._filename = "/Dialogs/Initdialog.svg";
		me._svg_menu = me._root.createChild('group');
		canvas.parsesvg(me._svg_menu, me._filename);

		# additional text elements
		me._lastAirportId = me._root.createChild("text")
      		.setFontSize(18, 1)         
      		.setAlignment("left-center") 
      		.setTranslation(230, 60)
			.setText(getprop("/extra500/exit/airport-id"))
			.setColor(0,0,0,1);	

		me._lastLon = me._root.createChild("text")
      		.setFontSize(15, 1)         
      		.setAlignment("left-center") 
      		.setTranslation(230, 94)
			.setText(sprintf("%3.3f",getprop("/extra500/exit/longitude-deg")))
			.setColor(0,0,0,1);

		me._lastLat = me._root.createChild("text")
      		.setFontSize(15, 1)         
      		.setAlignment("left-center") 
      		.setTranslation(230, 114)
			.setText(sprintf("%3.3f",getprop("/extra500/exit/latitude-deg")))
			.setColor(0,0,0,1);			


# defining clickable fields and other elements from svg file
	# menu
		me._lastAirport		= me._svg_menu.getElementById("last-Airport");
		me._lastLonLat		= me._svg_menu.getElementById("last-LonLat");
		me._continue		= me._svg_menu.getElementById("continue");

	# backgrounds
		me._lastAirportbg		= me._svg_menu.getElementById("last-Airport-bg");
		me._lastLonLatbg		= me._svg_menu.getElementById("last-LonLat-bg");
		me._continuebg		= me._svg_menu.getElementById("continue-bg");




# listeners
		me.setListeners(instance = me);

# initialisation


	},
	setListeners : func(instance) {
	# menu
		me._lastAirport.addEventListener("click",func(){me._onlastAirport();});
		me._lastLonLat.addEventListener("click",func(){me._onlastLonLat();});		
		me._continue.addEventListener("click",func(){me._oncontinue();});
	},
	_onlastAirport : func() {
		me._lastAirportbg.setColorFill(COLORid["menuse"]);
		setprop("/sim/presets/airport-id", getprop("/extra500/exit/airport-id"));
		fgcommand("reposition");
		me._timer.singleShot = 1;
		me._timer.start();
	},
	_onlastLonLat : func() {
		me._lastLonLatbg.setColorFill(COLORid["menuse"]);
		setprop("/sim/presets/latitude-deg", getprop("/extra500/exit/latitude-deg"));
      	setprop("/sim/presets/longitude-deg", getprop("/extra500/exit/longitude-deg"));
      	setprop("/sim/presets/heading-deg", getprop("/extra500/exit/heading-deg"));
		setprop("/sim/presets/airport-id", " ");
		fgcommand("reposition");
		me._timer.singleShot = 1;
		me._timer.start();
	},
	_oncontinue : func() {
		me._continuebg.setColorFill(COLORid["menuse"]);
		me._timer.singleShot = 1;
		me._timer.start();
	}

};

var Initdialog = InitDialogClass.new();




