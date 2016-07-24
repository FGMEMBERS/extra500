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
#      Last change: Eric van den Berg      
#      Date: 03.06.2016            
#
# note: some parts are taken from fgdata/gui/dialogs/weather.xml


# a Box to collect/remove the unique listener id returned by setlistener()
### TODO: move to a better place in a more global namespace 
var ListenerBox = {
	new: func(){
		var m = { parents: [ListenerBox] };
		m._listeners = [];
		return m;
	},
	append : func(l){
		append(me._listeners,l);
	},
	removeAll : func(){
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	}
};

var weatherListenerBox = ListenerBox.new();

setlistener("/extra500/weather/smooth", func {
	init_weather();
},0,0);


var onMetarValidChange = func(n){
	if (getprop("/environment/metar/valid")==0) {
		setprop("/environment/params/metar-updates-environment",0);
	} else if (getprop("/extra500/weather/ready") == 1) {
		buildMetar();
		setprop("/environment/params/metar-updates-environment",1);
	}
};

var onWeatherReadyChange = func(n){
	if (getprop("/extra500/weather/ready") == 1) {

		var noruns = getprop("extra500/weather/noruns");
		setprop("extra500/weather/noruns",noruns+1);

		settimer(func{ local_metar(); }, 15);

		if (noruns == 1) {
			# Clear any local weather that might be running
			var local_w = getprop("/nasal/local_weather/loaded");
			if (local_w) local_weather.clear_all();
			setprop("/nasal/local_weather/enabled", "false");          
		} 
	}
};


var init_weather = func() {
    if (getprop("/extra500/weather/smooth") == 1)  {

	weatherListenerBox.append(setlistener("/environment/metar/valid",onMetarValidChange ,0,0));
	weatherListenerBox.append(setlistener("/extra500/weather/ready",onWeatherReadyChange ,0,0));

	setprop( "/environment/params/metar-updates-environment", 1 ); # makes sure it follows (new) metar set in /environment/metar/data
	setprop( "/environment/realwx/enabled", 1 ); # make sure metars can be picked up
	setprop( "/environment/config/enabled", 1 );
	weatherService.init();
	weatherService.start();
	UI.msg.info("Smooth weather is now active");
    } else {
	    
	weatherListenerBox.removeAll();

	setprop("extra500/weather/noruns",0);
	setprop("/extra500/weather/ready",0);
	setprop("/environment/params/metar-updates-environment",1);
	weatherService.stop();
	setprop("/extra500/weather/range-nm",getprop("/extra500/weather/min-range-nm"));
	UI.msg.info("Smooth weather is de-activated");
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
		# checking for valid metars and calculating weighing factors
		var debug = getprop("/extra500/weather/debug");
		var total_weight = 0;
		var vvalid = [];
		var vweight = [];
		var no_valid = 0;
		var scanRange = getprop("/extra500/weather/range-nm");

		for (var i = 0 ; i <= 14; i+=1){
			var dist = getprop("/extra500/weather/station["~i~"]/distance-m");
			if ( (getprop("/extra500/weather/station["~i~"]/metar/valid") == 1) and (dist != -1) ) {
				no_valid = no_valid +1; 		# counting valid metars
				append( vvalid , i);			# vector of valid metar stations

				if (dist <	1) {dist = 1;}	
				append( vweight ,math.pow(dist,-2) );
				total_weight = total_weight + vweight[i];
			} else {
				append( vweight ,0 );
				if (debug) {print("METAR station ",i," not valid"); }
			}
		}
		if (debug) {print("number of METAR station used for calcs: ",no_valid); }

		# calculating average values
		if (no_valid > 0) {

			var deg2rad = global.CONST.DEG2RAD;
			var rad2deg = global.CONST.RAD2DEG;

			var metardata = ["dewpoint-sea-level-degc","max-visibility-m","min-visibility-m","pressure-sea-level-inhg","temperature-sea-level-degc","base-wind-dir-deg","base-wind-range-from","base-wind-range-to","base-wind-speed-kt","gust-wind-speed-kt","clouds/layer/coverage-type","clouds/layer/elevation-ft","clouds/layer[1]/coverage-type","clouds/layer[1]/elevation-ft","clouds/layer[2]/coverage-type","clouds/layer[2]/elevation-ft","clouds/layer[3]/coverage-type","clouds/layer[3]/elevation-ft","clouds/layer[4]/coverage-type","clouds/layer[4]/elevation-ft","rain-norm","snow-norm"];

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

				} else if ( ( mdata == "clouds/layer/elevation-ft" ) or (mdata == "clouds/layer[1]/elevation-ft") or (mdata == "clouds/layer[2]/elevation-ft") or (mdata == "clouds/layer[3]/elevation-ft") or (mdata == "clouds/layer[4]/elevation-ft") ){
				# for cloud layer altitude
					total_weight2 = 0;

					foreach(var valid; vvalid) {
						var cl_elvtn = getprop("/extra500/weather/station["~valid~"]/metar/",mdata);
						if ( cl_elvtn > 0 ) {	# for 'clear sky' elevation is set as -9999
							sum = sum + vweight[valid] * cl_elvtn;
							total_weight2 = total_weight2 + vweight[valid];
						} 
					}
					if ( total_weight2 > 0 ) {
						setprop("/extra500/weather/avgmetar/",mdata ,sum / total_weight2);
					} else {
						setprop("/extra500/weather/avgmetar/",mdata ,-9999);
					}

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
			if (debug) {print("no valid METARs in range"); }
		}

		# variable range
		var maxStations = getprop("/extra500/weather/max-stations");
		var minStations = getprop("/extra500/weather/min-stations");

		var rangeAdjustFactor = getprop("/extra500/weather/range-adjust-factor");

		if (no_valid > maxStations) { 
			if (debug) {print("valid stations is more than needed...reducing range"); }
			scanRange = math.max(scanRange / rangeAdjustFactor,getprop("/extra500/weather/min-range-nm") ); 
		} else if (	no_valid < minStations) {
			if (debug) {print("valid stations is less than needed...increasing range"); }
			scanRange = math.min(scanRange * rangeAdjustFactor,getprop("/extra500/weather/max-range-nm") ); 
		}

		setprop("/extra500/weather/range-nm",scanRange);

};

var buildMetar = func() {

	var sp = " ";

	var airp_elev_m = getprop("/extra500/weather/nearest-arprt-elev");
	QNHandTcalc(airp_elev_m,33.8639 * getprop("/extra500/weather/avgmetar/pressure-sea-level-inhg"),getprop("/extra500/weather/avgmetar/temperature-sea-level-degc"));

# date and time

	var dat = substr(getprop("/extra500/weather/station/metar/data"),0,16);
	var dat2 = substr(getprop("/extra500/weather/station/metar/data"),22,7);
#	print(dat2);

# airport
	var nrst_arp = getprop("/extra500/weather/nearest-arprt");

# wind
	var winddirection = getprop("/extra500/weather/avgmetar/base-wind-dir-deg") ;
	if (winddirection < 0) {winddirection = 360 + winddirection; }
	var winddir = sprintf("%03d",math.round( winddirection ) );

	var windspeed = sprintf("%02d",math.round( getprop("/extra500/weather/avgmetar/base-wind-speed-kt") ) );

	var fromwind = getprop("/extra500/weather/avgmetar/base-wind-range-from");
	var towind = getprop("/extra500/weather/avgmetar/base-wind-range-to");
	if ( abs(fromwind-towind) > 60 ) {
		if (fromwind < 0) {fromwind = 360 + fromwind; }
		if (towind < 0) {towind = 360 + towind; }
		var vwind = sprintf("%03d",10*math.round( fromwind/10) ) ~"V"~ sprintf("%03d",10*math.round( towind/10) ) ~sp ;
	} else {
		var vwind = "";
	}

# gusts
	var gust = getprop("/extra500/weather/avgmetar/gust-wind-speed-kt");
	if (gust > 10 ) {
		gustwind = "G"~sprintf("%02d",math.round(gust) );
	} else {
		gustwind = "";
	}

#visibility
	var visi = getprop("/extra500/weather/avgmetar/max-visibility-m");
	if (visi > 9999) {
		var visi_str = "9999";
	} else {
		var visi_str = sprintf("%04d",math.round( getprop("/extra500/weather/avgmetar/max-visibility-m") ) );
	}

# clouds
	var vlayer = [0,1,2,3,4];
	var layer = [];

	foreach(var lay; vlayer) {
		var cl_type = math.round (getprop("/extra500/weather/avgmetar/clouds/layer["~lay~"]/coverage-type"));
		var cl_alt = ( getprop("/extra500/weather/avgmetar/clouds/layer["~lay~"]/elevation-ft") - airp_elev_m * global.CONST.METER2FEET ) / 100;
		if (cl_alt <= 0) {
			cl_alt = 0;
		} else {
			cl_alt = sprintf("%03d",cl_alt);
		}

		if (cl_type == 0 ) { append (layer, "OVC"~cl_alt~" "); }
		if (cl_type == 1 ) { append (layer, "BKN"~cl_alt~" "); }
		if (cl_type == 2 ) { append (layer, "SCT"~cl_alt~" "); }
		if (cl_type == 3 ) { append (layer, "FEW"~cl_alt~" "); }
		if ( (cl_type == 4) or (cl_type == 5) ) { append (layer, ""); }

	}

# temperature
	var temp = getprop("/extra500/weather/avgmetar/T_atAP");
	if (temp < 0 ) {
		var temp_str = "M"~sprintf("%02d",math.round( abs(temp) ) );
	} else {
		var temp_str = sprintf("%02d",math.round(temp) );
	}

#dewpoint
	var dewp = getprop("/extra500/weather/avgmetar/dewpoint-sea-level-degc") -0.002 * airp_elev_m;
	if (dewp < 0 ) {
		var dewp_str = "M"~sprintf("%02d",math.round( abs(dewp) ) );
	} else {
		var dewp_str = sprintf("%02d",math.round(dewp) );
	}

#QNH
	var qnh = sprintf("%04d",math.round( getprop("/extra500/weather/avgmetar/QNH") ) );

# assembling METAR
	var metar = dat ~ sp ~ nrst_arp ~sp~ dat2 ~sp~ winddir~windspeed~gustwind~"KT" ~sp~ vwind ~ visi_str ~sp~ layer[0] ~ layer[1] ~ layer[2] ~ layer[3] ~ layer[4] ~ temp_str~"/"~dewp_str ~sp~ "Q"~qnh;
	if (getprop("/extra500/weather/debug")) {print(metar);}

	if( metar != nil ) {
		setprop( "environment/metar/data", normalize_string(metar) );
	}

	var noruns = getprop("extra500/weather/noruns");
	if (noruns>1){
# metar is too 'rough' for pressure and temperature (and calculated density), so setting average settings explicitly	
		setprop("environment/metar/pressure-sea-level-inhg",getprop("/extra500/weather/avgmetar/filtered-pressure-sea-level-inhg"));
		setprop("environment/metar/temperature-sea-level-degc",getprop("/extra500/weather/avgmetar/filtered-temperature-sea-level-degc"));
	} else {
		setprop("environment/metar/pressure-sea-level-inhg",getprop("/extra500/weather/avgmetar/pressure-sea-level-inhg"));
		setprop("environment/metar/temperature-sea-level-degc",getprop("/extra500/weather/avgmetar/temperature-sea-level-degc"));
	}

# rain
	var rain_norm = getprop("/extra500/weather/avgmetar/rain-norm");
	if (rain_norm < 0.1 ) {
		setprop("environment/metar/rain-norm",0);
	} else {
		setprop("environment/metar/rain-norm",rain_norm);
	}
# snow
	var snow_norm = getprop("/extra500/weather/avgmetar/snow-norm");
	if (snow_norm < 0.1 ) {
		setprop("environment/metar/snow-norm",0);
	} else {
		setprop("environment/metar/snow-norm",snow_norm);
	}

};

var QNHandTcalc = func(elevation_m,p_sl_hPa,T_sl_degC) {
	var p0 = global.CONST.P0;
	var T0 = global.CONST.T0;
	var g0 = global.CONST.G0;
	var R = global.CONST.R;
	var lambda = global.CONST.lambda;
	var Re = global.CONST.Re;

	var geopotheight_ap = Re * elevation_m / (Re + elevation_m);

	var T_ap_degC = T_sl_degC + lambda * geopotheight_ap;

	var p_ap_hPa = p_sl_hPa * math.pow(geopotheight_ap * lambda / (T_sl_degC + 273.15) + 1 , - g0 / (R*lambda));
	var ind_pr_alt = T0 / lambda *  (math.pow( p_ap_hPa / p0 , - R * lambda / g0 ) -1);
	var alt_corr = geopotheight_ap - ind_pr_alt;
	var QNH = p0 * math.pow(-alt_corr * lambda/T0 + 1 , - g0 / (R *  lambda));

	setprop("/extra500/weather/avgmetar/QNH",QNH);
	setprop("/extra500/weather/avgmetar/T_atAP",T_ap_degC);
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
		me._distance	= -1; #setting -1 to signal METAR is no longer to be used.
		
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
#		m._maxWeatherStations 	= 20;
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
		
		m._timerIntervall	= getprop("/extra500/weather/interval-sec");
		m._timer 		= maketimer(m._timerIntervall,m,WeatherService.update);
		m._timer.singleShot 	= 0;
		
		m._geoAircraft = geo.aircraft_position();
		
		m._tSem = thread.newsem();
		return m;
	},
	init : func(){
		for (var i = 0 ; i < 15; i+=1){
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
		
		for (var i = 0 ; i < 15; i+=1){
			me._weatherStation[i].publish();
		}
				
		me._nElevation.setValue(me._elevation);
		me._nMetar.setValue(me._metar);
		#me._nReady.setValue(me._ready);
		
		#props.dump(me._nRoot);
	},
	update : func(){
		if (getprop("/extra500/weather/debug")) {
			print("--------------------------------------------------------");
			print("WeatherService::update() ... ");
		}
		me._ready = 0;
		me._nReady.setValue(me._ready);
		
		me.fetchMetar();
		me.publish();
		
		me._ready = 1;
		me._nReady.setValue(me._ready);
		
	},
	fetchMetar : func(){
		if (getprop("/extra500/weather/debug")) {print("WeatherService::fetchMetar() ... ");}

		var scanRange = getprop("/extra500/weather/range-nm");
		var maxStations = getprop("/extra500/weather/max-stations");

		var listAirports = positioned.findAirportsWithinRange(scanRange);
		me._stationsReady = 0;
		var stationIndex = 0;
		me._ready = 0;
		me._nReady.setValue(me._ready);
		
		me._geoAircraft = geo.aircraft_position();
		me._elevation = geo.elevation(me._geoAircraft.lat(),me._geoAircraft.lon());
		if(me._elevation == nil){
			me._elevation = 0.001;
		}
		
		var geoStation = geo.Coord.new().set_latlon(0, 0, 0);

		var closest_ap = 0;

		foreach(var airport; listAirports) {
			if (closest_ap == 0) {			
				if (getprop("/extra500/weather/debug")) {print("Closest airport is ",airport.id," at ",sprintf("%4d",math.round( airport.elevation ) ),"m or ",sprintf("%4d",math.round( airport.elevation/0.3048 ) ),"ft"); }
				setprop("/extra500/weather/nearest-arprt",airport.id);
				setprop("/extra500/weather/nearest-arprt-elev",airport.elevation);
				closest_ap = 1;
			}
			if(airport.has_metar){
				me._weatherStation[stationIndex].setData(airport.id,airport.lat,airport.lon,airport.elevation);
				me._weatherStation[stationIndex].fetchMetar();
								
				geoStation.set_lat(me._weatherStation[stationIndex]._lat);
				geoStation.set_lon(me._weatherStation[stationIndex]._lon);
				geoStation.set_alt(me._weatherStation[stationIndex]._elevation);
				
				me._weatherStation[stationIndex]._distance = me._geoAircraft.distance_to(geoStation);
				
				
				stationIndex += 1;
			}
			
			if (stationIndex >= maxStations){
				break;
			}
		}
		me._stationsRecieved = stationIndex;

		for (var i = stationIndex ; i < 15; i+=1){
			me._weatherStation[i].clearMetar();
		}

	},
};


var weatherService = WeatherService.new("/extra500/weather");

