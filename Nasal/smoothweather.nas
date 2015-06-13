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


var init_weather = func() {
    if (getprop("/extra500/weather/smooth") == 1)  {
		setprop("sim/gui/dialogs/metar/mode/manual-weather",1);
            setprop("sim/gui/dialogs/metar/source-selection", "Manual input" );
# think need to do controller.apply(); from weather.xml, not sure howto...
    } else {
		setprop("sim/gui/dialogs/metar/mode/manual-weather",0);
            setprop("sim/gui/dialogs/metar/source-selection", "Live input" );
# think need to do controller.apply(); from weather.xml, not sure howto...
    }
}

setlistener("/extra500/weather/smooth", func {
	init_weather();
});

var WeatherStation = {
	new : func(root){
		print("WeatherStation::new() ... ");
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
		m._ready		= 0;
		
		m._nICAO  		= m._nRoot.initNode("icao",m._icao,"STRING");
		m._nLat  		= m._nRoot.initNode("lat",m._lat,"DOUBLE");
		m._nLon  		= m._nRoot.initNode("lon",m._lon,"DOUBLE");
		m._nElevation  		= m._nRoot.initNode("elevation",m._elevation,"DOUBLE");
		m._nDistance  		= m._nRoot.initNode("distance",m._distance,"DOUBLE");
		m._nMetar  		= m._nRoot.initNode("metar",m._metar,"STRING");
		m._nReady  		= m._nRoot.initNode("ready",m._ready,"BOOL");
		
		m._lMetar		= setlistener(m._nMetar,func(n){m.onMetarChange(n);},1,0);
		
		return m;
	},
	setData : func(icao,lat,lon,elevation){
		print("WeatherStation::setData() ... ");
		me._icao 	= icao;
		me._lat		= lat;
		me._lon		= lon;
		me._elevation	= elevation;
		me._ready	= 0;
		me._distance	= 0;
		
		me._nDistance.setValue(me._distance);
		me._nReady.setValue(me._ready);
	},
	fetchMetar : func(){
		print("WeatherStation::fetchMetar() ... ");
		fgcommand("request-metar", var n = props.Node.new({ "path": me._nMetar.getPath(),
                                                         "station": me._icao}));
		print("--- "~me._nMetar.getPath()~" : "~me._icao~" ---");
		props.dump(me._nMetar);
	},
	onMetarChange : func (n){
		print("WeatherStation::onMetarChange() ... ");
		me._metar = n.getValue();
		
		
		me._ready	= 1;
		me._nReady.setValue(me._ready);
	},
	publish : func(){
		print("WeatherStation::publish() ... ");
		me._nICAO.setValue(me._icao);
		me._nLat.setValue(me._lat);
		me._nLon.setValue(me._lon);
		me._nElevation.setValue(me._elevation);
		me._nDistance.setValue(me._distance);
		me._nMetar.setValue(me._metar);
		me._nReady.setValue(me._ready);
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
		
		m._nElevation  		= m._nRoot.initNode("elevation",m._elevation,"DOUBLE");
		m._nMetar  		= m._nRoot.initNode("metar",m._metar,"STRING");
		m._nReady  		= m._nRoot.initNode("ready",m._ready,"BOOL");
		
		m._timerIntervall	= 60.0;
		m._timer 		= maketimer(m._timerIntervall,m,WeatherService.update);
		m._timer.singleShot 	= 1;
		
		m._geoPosition = geo.aircraft_position();
		
		m._tSem = thread.newsem();
		return m;
	},
	init : func(){
		for (var i = 0 ; i <= me._maxWeatherStations; i+=1){
			var station = WeatherStation.new(me._root ~ "/station["~i~"]");
			append(me._listeners, setlistener(station._nReady,func(n){me._onStationReady(n);},1,0) );
		
			append(me._weatherStation,station);
		}
	},
	start : func(){
		me._threadRunning = 1;
		thread.newthread(func(){me.__tCalculator();});
		me._timer.restart(10);
	},
	stop : func(){
		me._threadRunning = 0;
		thread.semup(me._tSem);
	},
	publish : func(){
		me._nElevation.setValue(me._elevation);
		me._nMetar.setValue(me._metar);
		me._nReady.setValue(me._ready);
		
		props.dump(me._nRoot);
	},
	_onStationReady : func(n){
		var value = n.getValue();
		print("WeatherService::_onStationReady() ... "~value);
		me._stationsReady += value;
		if(me._stationsReady == me._stationsRecieved){
			me._startCalculation();
		}
	},
	update : func(){
		print("--------------------------------------------------------");
		print("WeatherService::update() ... ");
		me.fetchMetar();
	},
	fetchMetar : func(){
		print("WeatherService::fetchMetar() ... ");
		var listAirports = positioned.findAirportsWithinRange(100);
		me._stationsReady = 0;
		var stationIndex = 0;
		me._ready = 0;
		me._nReady.setValue(me._ready);
		foreach(var airport; listAirports) {
			if(airport.has_metar){
				me._weatherStation[stationIndex].setData(airport.id,airport.lat,airport.lon,airport.elevation);
				me._weatherStation[stationIndex].fetchMetar();
				stationIndex += 1;
			}
			
			if (stationIndex >= me._maxWeatherStations){
				break;
			}
		}
		me._stationsRecieved = stationIndex;
	},
	_startCalculation : func(){
		print("WeatherService::_startCalculation() ... ");
		
		me._elevation = 0;
		me._geoPosition = geo.aircraft_position();
		
		## push one thread to run
		thread.semup(me._tSem);
	},
	_onCalculationReady : func(){
		print("WeatherService::_onCalculationReady() ... ");
		
		me._ready	= 1;
		
		for (var i = 0 ; i <= me._stationsRecieved; i+=1){
			me._weatherStation[i].publish();
		}
		
		me.publish();
		
		me._timer.restart(me._timerIntervall);
		print("--------------------------------------------------------");
		
	},
	
	## calculation thread 
	__tCalculator : func(){
		var geoStation = geo.Coord.new();
		while(me._threadRunning == 1){
			
			thread.semdown(me._tSem);
			
			if(me._threadRunning == 0){
				break;
			}
			
			### begin calculation
			
			me._elevation = geo.elevation(me._geoPosition.lat(),me._geoPosition.lon());
			
			## calc distances
			
			for (var i = 0 ; i <= me._stationsRecieved; i+=1){
				geoStation.set_lat(me._weatherStation[i]._lat);
				geoStation.set_lon(me._weatherStation[i]._lon);
				me._weatherStation[i]._distance = me._geoPosition.distance_to(geoStation);
				
				## TODO : interpolate station metar to _geoPosition by distance
				
			}
			
						
			## TODO : writing new metar for _geoPosition
			me._metar = "none";
			
			settimer(func(){me._onCalculationReady()},0.0001);
		}
	},
	
};


var weatherService = WeatherService.new("/extra500/weather");

