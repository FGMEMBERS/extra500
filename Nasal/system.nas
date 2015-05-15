
var SubSystemTimer = {
	new : func(system,callback=func(){}){
		var m = {parents:[
			SubSystemTimer
		]};
		m.__system 	= system;
		m.__callback	= callback;
		m.__start	= 0;
		m.__stop	= 0;
		m.__duration	= 0;
		m.__timeline	= 0;
		m.__avg		= 0;
		m.__sum 	= 0;
		m.__count 	= 0;
		m.__timer	= nil;
		
		m.__timer		= maketimer(1.0,m,SubSystemTimer.__update);
		m.__timer.singleShot 	= 1;
		
		return m;
	},
	__initSubSystem : func(m){
		me.__system = m;
		me.__timer		= maketimer(1.0,me,SubSystemTimer.__update);
		me.__timer.singleShot 	= 1;
	},
	__update : func(){
		me.__start 	= systime();
		#print("SubSystemClass::update() ... " ~ me._name);
		#me.__system[me.__callback]();
		me.__callback();
		me.__stop 	= systime();
		me.__duration = me.__stop - me.__start;
		me.__sum += me.__duration;
		me.__count +=1;
		me.__avg = me.__sum / me.__count;
	},
};


var SystemManagerClass = {
	new : func(){
		var m = {parents:[
			SystemManagerClass
		]};
		
		m._timer 		= nil;
		m._timerIntervall 	= 1.0;
		m._start		= 0;
		m._stop			= 0;
		m._duration		= 0;
		
		m._subSystemList 	= [];
		m._subSystemSpace	= 0;
		m._subSystemDuration	= 0;
		m._subSystemCount	= 0;
		m._subSystemTimeLine	= 0;
		
		m._verbose		= 0;
		
		return m;
	},
	init : func(){
		me._timer = maketimer(me._timerIntervall,me,SystemManagerClass._update);
	},
	register : func(sys){
		append(me._subSystemList,sys);
		me._subSystemCount = size(me._subSystemList);
	},
	start : func(intervall){
		me._timerIntervall = intervall;
		me._timer.restart(me._timerIntervall);
	},
	stop : func(){
		me._timer.stop();
	},
	_calcDuration : func(){
		me._subSystemDuration = 0;
		foreach(var sub;me._subSystemList){
			me._subSystemDuration += sub.__avg;
		}
	},
	_fireTimers : func(){
		me._subSystemSpace = (me._timerIntervall - me._duration - me._subSystemDuration) / (me._subSystemCount+1);
		if(me._subSystemSpace<0){
			print("SystemManagerClass::_fireTimers() ... _subSystemSpace < 0 ");
		}
		me._subSystemTimeLine = me._subSystemSpace;
		foreach(var sub;me._subSystemList){
			sub.__timeline = me._subSystemTimeLine;
			sub.__timer.restart(me._subSystemTimeLine);
# 			settimer(func(sub){
# 				sub.update();
# 			},me._subSystemTimeLine);
			me._subSystemTimeLine += sub.__duration + me._subSystemSpace;
		}
	},
	printStats : func(){
		print("\n");
		print(sprintf("              system(%.2f sec)\tDeltaT(sec)\t     AVG\t load(%%)\ttimeline(%f)",me._timerIntervall,me._subSystemSpace));
		print("--------------------------------------------------------");
		foreach(var sub;me._subSystemList){
			print(sprintf("%30s\t%f\t%f\t%f\t%f",
					sub.__system._name,
					sub.__duration,
					sub.__avg,
					(sub.__avg/me._timerIntervall)*100,
					sub.__timeline
				     ));
		}
		print("--------------------------------------------------------");
		print(sprintf("%30s\t\t\t%f\t%f","sum",me._subSystemDuration,(me._subSystemDuration/me._timerIntervall)*100));
		print("\n");
	},
	_update : func(){
		me._start 	= systime();
		if(me._verbose){
			me.printStats();
		}
		me._calcDuration();
		me._fireTimers();
		
		me._stop 	= systime();
		me._duration = me._stop - me._start;
	}
};

subSystemManager = SystemManagerClass.new();
subSystemManager20Hz = SystemManagerClass.new();