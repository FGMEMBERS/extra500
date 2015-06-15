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
#      Author: Eric van den Berg, Dirk Dittmann
#      Date:   12.06.2015
#
#      Last change:       
#      Date:             
#

setlistener("/extra500/weather/smooth", func {
	init_weather();
});

setlistener("/extra500/weather/ready", func {
	if (getprop("/extra500/weather/ready") == 1) {
		settimer(func{ local_metar(); }, 5);
#		local_metar();
	}
});

var init_weather = func() {
    if (getprop("/extra500/weather/smooth") == 1)  {
		open();
		setprop("sim/gui/dialogs/metar/mode/manual-weather",1);
            setprop("sim/gui/dialogs/metar/source-selection", "Manual input" );
		apply();
    } else {
		setprop("sim/gui/dialogs/metar/mode/manual-weather",0);
            setprop("sim/gui/dialogs/metar/source-selection", "Live input" );
		apply();
    }
}

# taken from fgdata/gui/dialogs/weather.xml

var open = func() {
        
	# Determine the weather mode.
	if ( getprop("/nasal/local_weather/enabled") == 1) {
		# Local weather mode
		setprop("sim/gui/dialogs/metar/mode/global-weather", "0" );
		setprop("sim/gui/dialogs/metar/mode/local-weather", "1" );
		setprop("sim/gui/dialogs/metar/mode/manual-weather", "0" );          
	} else if ( getprop( "environment/params/metar-updates-environment" ) == 0 ) {
		# Manual weather mode
		setprop("sim/gui/dialogs/metar/mode/global-weather", "1" );
            setprop("sim/gui/dialogs/metar/mode/local-weather", "0" );
            setprop("sim/gui/dialogs/metar/mode/manual-weather", "1" );
	} else {
            # Global weather mode
            setprop("sim/gui/dialogs/metar/mode/global-weather", "1" );
            setprop("sim/gui/dialogs/metar/mode/local-weather", "0" );
            setprop("sim/gui/dialogs/metar/mode/manual-weather", "0" );
	}
           
      # initialize the METAR source selection
	if( getprop( "environment/realwx/enabled" ) ) {
		setprop("sim/gui/dialogs/metar/source-selection", "Live data" );
	} else {
		# preset configured scenario
		var wsn = props.globals.getNode( "/environment/weather-scenarios" );
            var current = getprop("/environment/weather-scenario", "");
            var found = 0;
            if( wsn != nil ) {
			var scenarios = wsn.getChildren("scenario");
			forindex (var i; scenarios ) {
				var metarN = scenarios[i].getNode("metar");
				metarN == nil and continue;
           				if( scenarios[i].getNode("name").getValue() == current ) {
            				setprop("sim/gui/dialogs/metar/source-selection", scenarios[i].getNode("name").getValue() );
                  			found = 1;
                  		break;
            			}
			}
		}
            if( found == 0 )
            setprop("sim/gui/dialogs/metar/source-selection", "Manual input" );
	}
          
      setprop("sim/gui/dialogs/metar/metar-string", normalize_string(getprop("environment/metar/data")) );
#      gui.findElementByName( me.dlgRoot, "metar-string" ).getNode("legend", 1).setValue(normalize_string(getprop("environment/metar/data")));

          # fill the METAR source combo box
#         var combo = gui.findElementByName( me.dlgRoot, "source-selection" );
#         var wsn = props.globals.getNode( "/environment/weather-scenarios" );
#          if( wsn != nil ) {
#            var scenarios = wsn.getChildren("scenario");
#            forindex (var i; scenarios ) {
#              combo.getChild("value", i, 1).setValue(scenarios[i].getNode("name").getValue());
#            }
#          }

#          me.scenarioListenerId = setlistener("sim/gui/dialogs/metar/source-selection", func(n) { me.scenarioListener(n); }, 1, 1 );
#          me.metarListenerId = setlistener( "environment/metar/valid", func(n) { me.metarListener(n); }, 1, 1 );
          
          # Update the dialog itself
#          me.refresh();
}


var apply = func() {
	var scenarioName = getprop( "sim/gui/dialogs/metar/source-selection");
      var metar = getprop( "environment/metar/data" );
      var global_weather_enabled = getprop("sim/gui/dialogs/metar/mode/global-weather");
      var local_weather_enabled = getprop("sim/gui/dialogs/metar/mode/local-weather");
      var manual_weather_enabled = getprop("sim/gui/dialogs/metar/mode/manual-weather");
          
     # General weather settings based on scenario          
     	if (manual_weather_enabled == 1) {
     		setprop( "/environment/params/metar-updates-environment", 0 );
            setprop( "/environment/realwx/enabled", 0 );
            setprop( "/environment/config/enabled", 1 );
            metar = "";
	} else if( scenarioName == "Live data" ) {
            setprop( "/environment/params/metar-updates-environment", 1 );
            setprop( "/environment/realwx/enabled", 1 );
            setprop( "/environment/config/enabled", 1 );
	} else if( scenarioName == "Manual input" ) {
            setprop( "/environment/params/metar-updates-environment", 1 );
            setprop( "/environment/realwx/enabled", 0 );
            setprop( "/environment/config/enabled", 1 );
            metar = getprop("sim/gui/dialogs/metar/metar-string" );
	} else {
            setprop( "/environment/params/metar-updates-environment", 1 );
            setprop( "/environment/realwx/enabled", 0 );
            setprop( "/environment/config/enabled", 1 );
            metar = getprop("sim/gui/dialogs/metar/metar-string" );
            setprop("/environment/weather-scenario", scenarioName);
	}
          
	if( metar != nil ) {
		setprop( "environment/metar/data", normalize_string(metar) );
	}
          
	# Clear any local weather that might be running
	if (getprop("/nasal/local_weather/loaded")) local_weather.clear_all();
	setprop("/nasal/local_weather/enabled", "false");
          
	if (local_weather_enabled) {
	# If Local Weather is enabled, re-initialize with updated 
	# initial tile and tile selection.
		setprop("/nasal/local_weather/enabled", "true");
            
            # Re-initialize local weather.
		settimer( func {local_weather.set_tile();}, 0.2);            
	} 
}

var normalize_string = func(src) {
	if( src == nil ) src = "";
	var dst = "";
	for( var i = 0; i < size(src); i+=1 ) {
		if( src[i] == `\n` or src[i] == `\r` )
			src[i] = ` `;
              
		if (i == 0 and src[i] == ` `)
			continue;

		if( i != 0 and src[i] == ` ` and src[i-1] == ` ` )
			continue;

		dst = dst ~ " ";
		dst[size(dst)-1] = src[i];
	}
	return dst;
}


var local_metar = func() {
#	if (getprop("/extra500/weather/ready") == 1) {
		# checking for valid metars and calculating weighing factors
		var total_weight = 0;
		var vvalid = [];
		var vweight = [];
		var one_valid = 0;
		for (var i = 0 ; i <= 20; i+=1){
			if (getprop("/extra500/weather/station["~i~"]/metar/valid") == 1) {
				one_valid = 1; 		# setting flag that at least one metar is valid
				append( vvalid , i);	# vector of valid metar stations		
				append( vweight ,math.pow(getprop("/extra500/weather/station["~i~"]/distance-m"),-2) );
				total_weight = total_weight + vweight[i];
			} else {
				append( vweight ,0 );
				print("METAR station ",i," not valid");
			}
		}

		# calculating average values
		if (one_valid == 1) {

			var deg2rad = getprop("/extra500/const/DEG2RAD");
			var rad2deg = getprop("/extra500/const/RAD2DEG");

			var metardata = ["dewpoint-sea-level-degc","max-visibility-m","min-visibility-m","pressure-sea-level-inhg","temperature-sea-level-degc","base-wind-dir-deg","base-wind-range-from","base-wind-range-to","base-wind-speed-kt","gust-wind-speed-kt"];

			foreach(var mdata; metardata) {
				var sum = 0;
				var sumx = 0;
				var sumy = 0;

				# for angles
				if ((mdata == "base-wind-dir-deg") or (mdata == "base-wind-range-from") or (mdata == "base-wind-range-to")) {
					foreach(var valid; vvalid) {
						sumx = sumx + vweight[valid] * math.sin(deg2rad*(getprop("/extra500/weather/station["~valid~"]/metar/",mdata)));
						sumy = sumy + vweight[valid] * math.cos(deg2rad*(getprop("/extra500/weather/station["~valid~"]/metar/",mdata)));
					}
					var avgx = sumx / total_weight;
					var avgy = sumy / total_weight;

					var avg_angle = rad2deg * math.atan2(avgx,avgy);
					setprop("/extra500/weather/avgmetar/",mdata ,avg_angle);

				} else {

				# for normal values
					foreach(var valid; vvalid) {
						sum = sum + vweight[valid] * getprop("/extra500/weather/station["~valid~"]/metar/",mdata);
					}
					setprop("/extra500/weather/avgmetar/",mdata ,sum / total_weight);
				}
			}
		buildMetar();
		} else {
			print("no valid METARs in range");
		}
#	}
};

var buildMetar = func() {
	var sp = " ";
	var winddir = sprintf("%03d",math.round( getprop("/extra500/weather/avgmetar/base-wind-dir-deg") ) );
	var windspeed = sprintf("%02d",math.round( getprop("/extra500/weather/avgmetar/base-wind-speed-kt") ) );

	var fromwind = getprop("/extra500/weather/avgmetar/base-wind-range-from");
	var towind = getprop("/extra500/weather/avgmetar/base-wind-range-to");
	if ( abs(fromwind-towind) > 10 ) {
		if (fromwind < 0) {fromwind = 360 + fromwind; }
		if (towind < 0) {towind = 360 + towind; }
		var vwind = sprintf("%03d",10*math.round( fromwind/10) ) ~"V"~ sprintf("%03d",10*math.round( towind/10) ) ~sp ;
	} else {
		var vwind = "";
	}

	var visi = getprop("/extra500/weather/avgmetar/max-visibility-m");
	if (visi > 9999) {
		var visi_str = "9999";
	} else {
		var visi_str = sprintf("%04d",math.round( getprop("/extra500/weather/avgmetar/max-visibility-m") ) );
	}

	var temp = getprop("/extra500/weather/avgmetar/temperature-sea-level-degc");
	if (temp < 0 ) {
		var temp_str = "M"~sprintf("%02d",math.round( abs(temp) ) );
	} else {
		var temp_str = sprintf("%02d",math.round(temp) );
	}

	var dewp = getprop("/extra500/weather/avgmetar/dewpoint-sea-level-degc");
	if (dewp < 0 ) {
		var dewp_str = "M"~sprintf("%02d",math.round( abs(dewp) ) );
	} else {
		var dewp_str = sprintf("%02d",math.round(dewp) );
	}

	var qnh = sprintf("%04d",math.round( 33.8639 * getprop("/extra500/weather/avgmetar/pressure-sea-level-inhg") ) );

	var metar = "XXXX" ~sp~ "012345Z" ~sp~ winddir~windspeed~"KT" ~sp~ vwind ~ visi_str ~sp~ temp_str~"/"~dewp_str ~sp~ "Q"~qnh;
print(metar);
};

var WeatherStation = {
	new : func(root){
		#print("WeatherStation::new() ... ");
		var m = { 
			parents 	: [WeatherStation],
			_root		: root,
			_nRoot		: props.globals.initNode(root),
		};
		m._icao			= "";
		m._lat			= 0;
		m._lon			= 0;
		m._elevation		= 0;
		m._distance		= 0;
		m._metar		= "default";
		
		m._nICAO  		= m._nRoot.initNode("icao",m._icao,"STRING");
		m._nLat  		= m._nRoot.initNode("lat",m._lat,"DOUBLE");
		m._nLon  		= m._nRoot.initNode("lon",m._lon,"DOUBLE");
		m._nElevation  		= m._nRoot.initNode("elevation-m",m._elevation,"DOUBLE");
		m._nDistance  		= m._nRoot.initNode("distance-m",m._distance,"DOUBLE");
		m._nMetar  		= m._nRoot.initNode("metar",m._metar,"STRING");
		
		return m;
	},
	setData : func(icao,lat,lon,elevation){
		#print("WeatherStation::setData() ... ");
		me._icao 	= icao;
		me._lat		= lat;
		me._lon		= lon;
		me._elevation	= elevation;
		me._ready	= 0;
		me._distance	= 0;
		
		me._nDistance.setValue(me._distance);
		
	},
	fetchMetar : func(){
		#print("WeatherStation::fetchMetar() ... ");
		fgcommand("request-metar", var n = props.Node.new({ "path": me._nMetar.getPath(),
                                                         "station": me._icao}));
		#print("--- "~me._nMetar.getPath()~" : "~me._icao~" ---");
		#props.dump(me._nMetar);
	},
	clearMetar : func(){
		fgcommand("clear-metar", var n = props.Node.new({ "path": me._nMetar.getPath(),
                                                         "station": me._icao}));
		me._icao 	= "";
		me._lat		= 0;
		me._lon		= 0;
		me._elevation	= 0;
		me._ready	= 0;
		me._distance	= 0;
		
	},
	publish : func(){
		#print("WeatherStation::publish() ... ");
		me._nICAO.setValue(me._icao);
		me._nLat.setValue(me._lat);
		me._nLon.setValue(me._lon);
		me._nElevation.setValue(me._elevation);
		me._nDistance.setValue(me._distance);
		me._nMetar.setValue(me._metar);
	},
};

var WeatherService = {
	new : func(root){
		var m = { 
			parents 	: [WeatherService],
			_root		: root,
			_nRoot		: props.globals.initNode(root),
		};
		m._maxWeatherStations 	= 20;
		m._weatherStation 	= [];
		m._listeners 		= [];
		m._stationsReady 	= 0;
		m._stationsRecieved 	= 0;
		m._threadRunning 	= 0;
		m._ready		= 0;
		m._elevation		= 0;
		m._metar		= "default";
		
		m._nElevation  		= m._nRoot.initNode("elevation-m",m._elevation,"DOUBLE");
		m._nMetar  		= m._nRoot.initNode("metar",m._metar,"STRING");
		m._nReady  		= m._nRoot.initNode("ready",m._ready,"BOOL");
		
		m._timerIntervall	= 60.0;
		m._timer 		= maketimer(m._timerIntervall,m,WeatherService.update);
		m._timer.singleShot 	= 0;
		
		m._geoAircraft = geo.aircraft_position();
		
		m._tSem = thread.newsem();
		return m;
	},
	init : func(){
		for (var i = 0 ; i <= me._maxWeatherStations; i+=1){
			var station = WeatherStation.new(me._root ~ "/station["~i~"]");
			append(me._weatherStation,station);
		}
	},
	start : func(){
		me.update();
		me._timer.restart(me._timerIntervall);
	},
	stop : func(){
		me._timer.stop();
	},
	publish : func(){
		
		for (var i = 0 ; i <= me._maxWeatherStations; i+=1){
			me._weatherStation[i].publish();
		}
				
		me._nElevation.setValue(me._elevation);
		me._nMetar.setValue(me._metar);
		#me._nReady.setValue(me._ready);
		
		#props.dump(me._nRoot);
	},
	update : func(){
		print("--------------------------------------------------------");
		print("WeatherService::update() ... ");
		me._ready = 0;
		me._nReady.setValue(me._ready);
		
		me.fetchMetar();
		me.publish();
		
		me._ready = 1;
		me._nReady.setValue(me._ready);
		
	},
	fetchMetar : func(){
		print("WeatherService::fetchMetar() ... ");
		var listAirports = positioned.findAirportsWithinRange(100);
		me._stationsReady = 0;
		var stationIndex = 0;
		me._ready = 0;
		me._nReady.setValue(me._ready);
		
		me._geoAircraft = geo.aircraft_position();
		me._elevation = geo.elevation(me._geoAircraft.lat(),me._geoAircraft.lon());
		
		var geoStation = geo.Coord.new().set_latlon(0, 0, 0);

		
		foreach(var airport; listAirports) {
			if(airport.has_metar){
				
				me._weatherStation[stationIndex].setData(airport.id,airport.lat,airport.lon,airport.elevation);
				me._weatherStation[stationIndex].fetchMetar();
								
				geoStation.set_lat(me._weatherStation[stationIndex]._lat);
				geoStation.set_lon(me._weatherStation[stationIndex]._lon);
				geoStation.set_alt(me._weatherStation[stationIndex]._elevation);
				
				me._weatherStation[stationIndex]._distance = me._geoAircraft.distance_to(geoStation);
				
				
				stationIndex += 1;
			}
			
			if (stationIndex >= me._maxWeatherStations){
				break;
			}
		}
		me._stationsRecieved = stationIndex;

		for (var i = stationIndex ; i <= me._maxWeatherStations; i+=1){
			me._weatherStation[i].clearMetar();
		}
			

	},
};


var weatherService = WeatherService.new("/extra500/weather");

