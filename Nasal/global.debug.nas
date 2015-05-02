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
#      Date: 15.03.2015
#
#      Last change:      Dirk Dittmann
#      Date:             15.03.2015
#
 
var DebugPrint = {
	new : func(){
		var m = { parents : [DebugPrint]};
		#{bulk|debug|info|warn|alert}
		m._Level 	= ["bulk", "debug", "info", "warn", "alert"];
		m._LevelMap 	= {"bulk":0, "debug":1, "info":2, "warn":3, "alert":4};
		m.color=[
			[0.8,0.0,0.0,1.0], # bulk
			[1.0,0.1,0.0,1.0], # debug
			[0.8,0.8,0.0,1.0], # info
			[0.0,0.0,0.8,1.0], # warn
			[0.0,0.0,0.8,1.0] # alert
		];
		
		m._debugLevel = 0;
		m._screenEnabledEnabled = 0;
		
		return m;
	},
	setDebugLevel : func(level){me._debugLevel = level},
	enableScreen : func(enable){me._screenEnabled = enable},
	
	terminal : func(level,msg){
		print(msg);
	},
	screen : func(level,msg){
		screen.log.write(msg,me.color[level][0],me.color[level][1],me.color[level][2],me.color[level][3]);
	},
	bulk : func(msg){
		if (me._debugLevel <= me._LevelMap.bulk){
			me.terminal(me._LevelMap.bulk,msg);
			if(me._screenEnabled){
				me.screen(me._LevelMap.bulk,msg);
			}
		}
	},
	debug : func(msg){
		if (me._debugLevel <= me._LevelMap.debug){
			me.terminal(me._LevelMap.debug,msg);
			if(me._screenEnabled){
				me.screen(me._LevelMap.debug,msg);
			}
		}
	},
	info : func(msg){
		if (me._debugLevel <= me._LevelMap.info){
			me.terminal(me._LevelMap.info,msg);
			if(me._screenEnabled){
				me.screen(me._LevelMap.info,msg);
			}
		}
	},
	warn : func(msg){
		if (me._debugLevel <= me._LevelMap.warn){
			me.terminal(me._LevelMap.warn,msg);
			if(me._screenEnabled){
				me.screen(me._LevelMap.warn,msg);
			}
		}
	},
	alert : func(msg){
		if (me._debugLevel <= me._LevelMap.alert){
			me.terminal(me._LevelMap.alert,msg);
			if(me._screenEnabled){
				me.screen(me._LevelMap.alert,msg);
			}
		}
	},
	
	
}