
var MyWindow = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, type = nil, id = nil)
  {
    var ghost = canvas._newWindowGhost(id);
    var m = {
      parents: [MyWindow, canvas.PropertyElement, ghost],
      _node: props.wrapNode(ghost._node_ghost)
    };

    m.setInt("size[0]", size[0]);
    m.setInt("size[1]", size[1]);

    # TODO better default position
    m.move(0,0);

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);
    if( type )
      m.set("type", type);

    m._isOpen = 1;
    return m;
  },
  # Destructor
  del: func
  {
    me._node.remove();
    me._node = nil;

    if( me["_canvas"] != nil )
    {
      me._canvas.del();
      me._canvas = nil;
    }
     me._isOpen = 0;
  },
  # Create the canvas to be used for this Window
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size = [
      me.get("size[0]"),
      me.get("size[1]")
    ];

    me._canvas = canvas.new({
      size: [2 * size[0], 2 * size[1]],
      view: size,
      placement: {
        type: "window",
        id: me.get("id")
      }
    });

    me._canvas.addEventListener("mousedown", func me.raise());
    return me._canvas;
  },
  # Set an existing canvas to be used for this Window
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");

    canvas_.addPlacement({type: "window", index: me._node.getIndex()});
    me['_canvas'] = canvas_;
  },
  # Get the displayed canvas
  getCanvas: func()
  {
    return me['_canvas'];
  },
  getCanvasDecoration: func()
  {
    return canvas.wrapCanvas(me._getCanvasDecoration());
  },
  setPosition: func(x, y)
  {
    me.setInt("tf/t[0]", x);
    me.setInt("tf/t[1]", y);
  },
  move: func(x, y)
  {
    me.setInt("tf/t[0]", me.get("tf/t[0]", 10) + x);
    me.setInt("tf/t[1]", me.get("tf/t[1]", 30) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    # on writing the z-index the window always is moved to the top of all other
    # windows with the same z-index.
    me.setInt("z-index", me.get("z-index", 0));
  },
# private:
  _propCallback: func(child, mode)
  {
    if( !me._node.equals(child.getParent()) )
      return;
    var name = child.getName();

    # support for CSS like position: absolute; with right and/or bottom margin
    if( name == "right" )
      me._handlePositionAbsolute(child, mode, name, 0);
    else if( name == "bottom" )
      me._handlePositionAbsolute(child, mode, name, 1);

    # update decoration on type change
    else if( name == "type" )
    {
      if( mode == 0 )
        settimer(func me._updateDecoration(), 0);
    }
  },
  _handlePositionAbsolute: func(child, mode, name, index)
  {
    # mode
    #   -1 child removed
    #    0 value changed
    #    1 child added

    if( mode == 0 )
      me._updatePos(index, name);
    else if( mode == 1 )
      me["_listener_" ~ name] = [
        setlistener
        (
          "/sim/gui/canvas/size[" ~ index ~ "]",
          func me._updatePos(index, name)
        ),
        setlistener
        (
          me._node.getNode("size[" ~ index ~ "]"),
          func me._updatePos(index, name)
        )
      ];
    else if( mode == -1 )
      for(var i = 0; i < 2; i += 1)
        removelistener(me["_listener_" ~ name][i]);
  },
  _updatePos: func(index, name)
  {
    me.setInt
    (
      "tf/t[" ~ index ~ "]",
      getprop("/sim/gui/canvas/size[" ~ index ~ "]")
      - me.get(name)
      - me.get("size[" ~ index ~ "]")
    );
  },
  _onClose : func(){
	me.del();
  },
  _updateDecoration: func()
  {
    var border_radius = 9;
    me.set("decoration-border", "25 1 1");
    me.set("shadow-inset", int((1 - math.cos(45 * D2R)) * border_radius + 0.5));
    me.set("shadow-radius", 5);
    me.setBool("update", 1);

    var canvas_deco = me.getCanvasDecoration();
    canvas_deco.addEventListener("mousedown", func me.raise());
    canvas_deco.set("blend-source-rgb", "src-alpha");
    canvas_deco.set("blend-destination-rgb", "one-minus-src-alpha");
    canvas_deco.set("blend-source-alpha", "one");
    canvas_deco.set("blend-destination-alpha", "one");

    var group_deco = canvas_deco.getGroup("decoration");
    var title_bar = group_deco.createChild("group", "title_bar");
    title_bar
      .rect( 0, 0,
             me.get("size[0]"),
             me.get("size[1]"), #25,
             {"border-top-radius": border_radius} )
      .setColorFill(0.25,0.24,0.22)
      .setStrokeLineWidth(0);

    var style_dir = "gui/styles/AmbianceClassic/";

    # close icon
    var x = 10;
    var y = 3;
    var w = 19;
    var h = 19;
    var ico = title_bar.createChild("image", "icon-close")
                       .set("file", style_dir ~ "close_focused_normal.png")
                       .setTranslation(x,y);
    ico.addEventListener("click", func me._onClose());
    ico.addEventListener("mouseover", func ico.set("file", style_dir ~ "close_focused_prelight.png"));
    ico.addEventListener("mousedown", func ico.set("file", style_dir ~ "close_focused_pressed.png"));
    ico.addEventListener("mouseout",  func ico.set("file", style_dir ~ "close_focused_normal.png"));

    # title
    me._title = title_bar.createChild("text", "title")
                         .set("alignment", "left-center")
                         .set("character-size", 14)
                         .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
                         .setTranslation( int(x + 1.5 * w + 0.5),
                                          int(y + 0.5 * h + 0.5) );

    var title = me.get("title", "Canvas Dialog");
    me._node.getNode("title", 1).alias(me._title._node.getPath() ~ "/text");
    me.set("title", title);

    title_bar.addEventListener("drag", func(e) {
      if( !ico.equals(e.target) )
        me.move(e.deltaX, e.deltaY);
    });
  }
};

var COLOR = {};
COLOR["Red"] = "rgb(244,28,33)";
COLOR["Green"] = "rgb(64,178,80)";

var SvgWidget = {
	new: func(canvasGroup,name){
		var m = {parents:[SvgWidget]};
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
	
};

var TankWidget = {
	new: func(canvasGroup,name,lable,index,refuelable=1){
		var m = {parents:[TankWidget,SvgWidget.new(canvasGroup,name)]};
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
		m._cDataMax.setText(sprintf("%3.2f",m._capacity * global.CONST.JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.2f",m._level * global.CONST.JETA_LBGAL));
		m._cDataPercent.setText(sprintf("%3.2f",m._fraction*100.0));
		
		
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
		
		me._cDataLevel.setText(sprintf("%3.2f",me._level * global.CONST.JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.2f",me._fraction*100.0));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
		fuelPayload._nNotify.setValue(systime());
			
	},
	_onFuelInputChange : func(e){
		var newFraction = me._fraction - (e.deltaY/me._height);
		newFraction = global.clamp(newFraction,0.0,1.0);
		me._nLevel.setValue(me._capacity * newFraction);
		
	},
};

var TankerWidget = {
	new: func(canvasGroup,name,lable,tanks){
		var m = {parents:[TankerWidget,SvgWidget.new(canvasGroup,name)]};
		m._lable 	= lable;
		m._tanks	= tanks;
		m._nLevel 	= props.globals.initNode("/consumables/fuel/total-fuel-norm",0.0,"DOUBLE");
		
		m._level		= 0;
		m._capacity		= 0;
		m._levelTotal		= 0;
		m._capacityTotal	= 0;
		
		#debug.dump(m._tanks);
		foreach(tank;keys(m._tanks)){
			if (m._tanks[tank]._refuelable == 1){
			print ("TankerWidget.new() ... "~tank);
				
				m._capacity 	+= m._tanks[tank]._capacity;
				m._level	+= m._tanks[tank]._level;
			}
			m._capacityTotal 	+= m._tanks[tank]._capacity;
			m._levelTotal		+= m._tanks[tank]._level;
			
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
		m._cDataMax.setText(sprintf("%3.2f",m._capacity * global.CONST.JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.2f",m._level * global.CONST.JETA_LBGAL));
		m._cDataPercent.setText(sprintf("%3.2f",m._fraction*100.0));
		
		m._cTotalDataName.setText("Total");
		m._cTotalDataMax.setText(sprintf("%3.2f",m._capacityTotal * global.CONST.JETA_LBGAL));
		m._cTotalDataLevel.setText(sprintf("%3.2f",m._levelTotal * global.CONST.JETA_LBGAL));
		m._cTotalDataPercent.setText(sprintf("%3.2f",m._fractionTotal*100.0));
		
		
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fuelPayload._nNotify,func(n){me._onNotifyChange(n);},1,0) );
		me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onFuelInputChange(e);});

	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onNotifyChange : func(n){
		me._level 	= 0;
		me._levelTotal 	= 0;
		foreach(tank;keys(me._tanks)){
			if (me._tanks[tank]._refuelable == 1){
				me._level	+= me._tanks[tank]._level;
			}
			me._levelTotal		+= me._tanks[tank]._level;
		}
		
		me._fraction		= me._level / me._capacity;
		me._fractionTotal	= me._levelTotal / me._capacityTotal;
		
		me._cDataLevel.setText(sprintf("%3.2f",me._level * global.CONST.JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.2f",me._fraction*100.0));
		
		me._cTotalDataLevel.setText(sprintf("%3.2f",me._levelTotal * global.CONST.JETA_LBGAL));
		me._cTotalDataPercent.setText(sprintf("%3.2f",me._fractionTotal*100.0));
		
		me._cWeightFuel.setText(sprintf("%3.2f",me._levelTotal * global.CONST.JETA_LBGAL));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
	
	},
	_onFuelInputChange : func(e){
		
		var newFraction = me._fraction - (e.deltaY/me._height);
		newFraction = global.clamp(newFraction,0.0,1.0);
		
# 		foreach(tank;keys(me._tanks)){
# 			if (me._tanks[tank]._refuelable == 1){
# 				me._tanks[tank]._nLevel.setValue(me._tanks[tank]._capacity * newFraction);
# 			}
# 			
# 		}
		var fuelamount  = (me._capacity * newFraction) /2;
		var fuelAux	= fuelamount - me._tanks.LeftMain._capacity;
		
		if (fuelAux > 0){
			me._tanks.LeftMain._nLevel.setValue(me._tanks.LeftMain._capacity);
			me._tanks.RightMain._nLevel.setValue(me._tanks.RightMain._capacity);
			
			me._tanks.LeftAux._nLevel.setValue(fuelAux);
			me._tanks.RightAux._nLevel.setValue(fuelAux);
		}else{
			me._tanks.LeftMain._nLevel.setValue(fuelamount);
			me._tanks.RightMain._nLevel.setValue(fuelamount);
			
			me._tanks.LeftAux._nLevel.setValue(0);
			me._tanks.RightAux._nLevel.setValue(0);
			
		}
		
		
		fuelPayload._nNotify.setValue(systime());
		
	},
};

COLOR["TabActive"] = "#f2f2f2";
COLOR["TabPassive"] = "#cccccc";

var TabWidget = {
	new: func(canvasGroup,name){
		var m = {parents:[TabWidget,SvgWidget.new(canvasGroup,name)]};
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

var WightWidget = {
	new: func(canvasGroup,name){
		var m = {parents:[WightWidget,SvgWidget.new(canvasGroup,name)]};
		m._cCenterGravityX	 	= m._group.getElementById("CenterGravity_X");
		m._cCenterGravityY	 	= m._group.getElementById("CenterGravity_Y");
		m._cCenterGravityBall	 	= m._group.getElementById("CenterGravity_Ball").updateCenter();
		m._cWeightEmpty		 	= m._group.getElementById("Weight_Empty");
		m._cWeightGross	 		= m._group.getElementById("Weight_Gross");
		m._cWeightMaxRamp	 	= m._group.getElementById("Weight_Max_Ramp");
		m._cWeightMaxTakeoff	 	= m._group.getElementById("Weight_Max_Takeoff");
		m._cWeightMaxLanding	 	= m._group.getElementById("Weight_Max_Landing");
		
		m._nCGx 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-x-in");
		m._nCGy 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-y-in");
		m._nGross 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nEmpty 	= props.globals.initNode("/fdm/jsbsim/inertia/empty-weight-lbs");
		m._nRamp 	= props.globals.initNode("/limits/mass-and-balance/maximum-ramp-mass-lbs");
		m._nTakeoff 	= props.globals.initNode("/limits/mass-and-balance/maximum-takeoff-mass-lbs");
		m._nLanding 	= props.globals.initNode("/limits/mass-and-balance/maximum-landing-mass-lbs");
		m._cgX  = 0;
		m._cgY  = 0;
		m._gross = 0;
		m._ramp  = 0;
		m._takeoff  = 0;
		m._landing = 0;
		m._empty = 0;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fuelPayload._nNotify,func(n){me._onNotifyChange(n);},1,0) );
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onNotifyChange : func(n){
		me._cgX = me._nCGx.getValue();
		me._cCenterGravityX.setText(sprintf("%.2f",me._cgX));
		me._cgY = me._nCGy.getValue();
		me._cCenterGravityY.setText(sprintf("%.2f",me._cgY));
		me._gross = me._nGross.getValue();
		me._cWeightGross.setText(sprintf("%.2f",me._gross));
		me._ramp = me._nRamp.getValue();
		me._cWeightMaxRamp.setText(sprintf("%.2f",me._ramp));
		me._takeoff = me._nTakeoff.getValue();
		me._cWeightMaxTakeoff.setText(sprintf("%.2f",me._takeoff));
		me._landing = me._nLanding.getValue();
		me._cWeightMaxLanding.setText(sprintf("%.2f",me._landing));
		me._empty = me._nEmpty.getValue();
		me._cWeightEmpty.setText(sprintf("%.2f",me._empty));
		
		#me._cCenterGravityBall.setTranslation(me._cgX * (64/13), (me._cgY - 136.0) * (64/13) );
		#me._cCenterGravityBall.setTranslation((me._cgY - 136.0) , me._cgX);
		
		var y = (me._cgX - 138.0) * (64/5);
		var x = (me._cgY ) * (64/13);
		me._cCenterGravityBall.setTranslation(x ,y );
		
	},
	
	
	
};

var FuelPayloadClass = {
	new : func(){
		var m = {parents:[FuelPayloadClass]};
		m._nRoot 	= props.globals.initNode("/sim/gui/dialogs/FuelPayload/dialog");
		m._nNotify 	= m._nRoot.initNode("dialogNotify",0.0,"DOUBLE");
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
		
		m._tanks = {
			LeftAux 	: nil,
			LeftMain 	: nil,
			LeftCol 	: nil,
			CenterEngine 	: nil,
			RightAux 	: nil,
			RightMain 	: nil,
			RightCol 	: nil,
		};
		
		m._tanker 	= nil;
		m._selector 	= nil;
		m._weight 	= nil;
		
		return m;
	},
	toggle : func(){
		if(me._dlg != nil){
			if (me._dlg._isOpen){
				me.close();
			}else{
				me.open();	
			}
		}else{
			me.open();
		}
	},
	close : func(){
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
		append(me._listeners, setlistener(me._nNotify,func(n){me._onNotifyChange(n);},1,0) );
	},
	_onClose : func(){
		print("FuelPayloadClass._onClose() ... ");
		me.removeListeners();
		me._dlg.del();
		
		me._selector.deinit();
		me._weight.deinit();
		
		me._tanks.LeftAux.deinit();
		me._tanks.LeftMain.deinit();
		me._tanks.LeftCol.deinit();
		me._tanks.CenterEngine.deinit();
		me._tanks.RightCol.deinit();
		me._tanks.RightMain.deinit();
		me._tanks.RightAux.deinit();
		
		me._tanker.deinit();
		
		me._selector 			= nil;
		me._weight 			= nil;
		
		me._tanks.LeftAux 		= nil;
		me._tanks.LeftMain 		= nil;
		me._tanks.LeftCol 		= nil;
		me._tanks.CenterEngine 		= nil;
		me._tanks.RightCol 		= nil;
		me._tanks.RightMain 		= nil;
		me._tanks.RightAux 		= nil;
		
		me._tanker 			= nil;
		
	},
	open : func(){
		
		
		me._dlg = MyWindow.new([1024,768], "dialog");
		me._dlg._onClose = func(){
			fuelPayload._onClose();
		}
		me._dlg.set("title", me._title);
		me._dlg.move(100,100);
		
		
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#3F3D38");
#                        
		
		me._group = me._canvas.createGroup();

		canvas.parsesvg(me._group, "Dialogs/FuelPayload.svg",{"font-mapper": IFD.AvidyneFontMapper});
		
		me._selector = TabWidget.new(me._group,"Tab Selector");
		
		me._weight = WightWidget.new(me._group,"Weight");
		
		me._tanks.LeftAux 		= TankWidget.new(me._group,"Left_Aux","Auxiliary",0,1);
		me._tanks.LeftMain 		= TankWidget.new(me._group,"Left_Main","Main",1,1);
		me._tanks.LeftCol 		= TankWidget.new(me._group,"Left_Collector","Collector",2,0);
		me._tanks.CenterEngine 		= TankWidget.new(me._group,"Center_Engine","Engine",3,0);
		me._tanks.RightCol 		= TankWidget.new(me._group,"Right_Collector","Collector",4,0);
		me._tanks.RightMain 		= TankWidget.new(me._group,"Right_Main","Main",5,1);
		me._tanks.RightAux 		= TankWidget.new(me._group,"Right_Aux","Auxiliary",6,1);
		
		me._tanker			= TankerWidget.new(me._group,"Tanker","Tanker",me._tanks);
		
		me._selector.init();
		me._weight.init();
		
		me._tanks.LeftAux.init();
		me._tanks.LeftMain.init();
		me._tanks.LeftCol.init();
		me._tanks.CenterEngine.init();
		me._tanks.RightCol.init();
		me._tanks.RightMain.init();
		me._tanks.RightAux.init();
		
		me._tanker.init();
		
		#me.setListeners();
		
		
	},
	_onNotifyChange : func(n){

	},
	_onFuelTotalChange : func(n){
		
	}
	
};

var fuelPayload = FuelPayloadClass.new();

