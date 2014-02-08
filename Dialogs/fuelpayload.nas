
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

    var style_dir = "gui/styles/AmbianceClassic/decoration/";

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
COLOR["Green"] = "#008000";

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
		
		me._cDataLevel.setText(sprintf("%3.2f",me._level * global.CONST.JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.2f",me._fraction*100.0));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
		fuelPayload._nNotify.setValue(systime());
			
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
		m._nLevel 	= props.globals.initNode("/consumables/fuel/total-fuel-norm",0.0,"DOUBLE");
		
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
		me._cFrame.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onFuelInputChange(e);});

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
		foreach(tank;keys(me._widget)){
			if (me._widget[tank]._refuelable == 1){
				me._level	+= me._widget[tank]._level;
			}
			me._levelTotal		+= me._widget[tank]._level;
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
		var fuelamount  = (me._capacity * newFraction) /2;
		var fuelAux	= fuelamount - me._widget.LeftMain._capacity;
		
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
		
		
		fuelPayload._nNotify.setValue(systime());
		
	},
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

var WightWidget = {
	new: func(dialog,canvasGroup,name,widgets){
		var m = {parents:[WightWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "WightWidget";
		m._widget = {};
		
		foreach(w;keys(widgets)){
			if(widgets[w] != nil){
				if(widgets[w]._class == "PayloadWidget"){
					m._widget[w] = widgets[w];
				}
			}
		}
		
		
		m._cCenterGravityX	 	= m._group.getElementById("CenterGravity_X");
		m._cCenterGravityY	 	= m._group.getElementById("CenterGravity_Y");
		m._cCenterGravityBall	 	= m._group.getElementById("CenterGravity_Ball").updateCenter();
		m._cWeightEmpty		 	= m._group.getElementById("Weight_Empty");
		m._cWeightGross	 		= m._group.getElementById("Weight_Gross");
		m._cWeightPayload	 	= m._group.getElementById("Weight_Payload");
		m._cWeightMaxRamp	 	= m._group.getElementById("Weight_Max_Ramp");
		m._cWeightMaxTakeoff	 	= m._group.getElementById("Weight_Max_Takeoff");
		m._cWeightMaxLanding	 	= m._group.getElementById("Weight_Max_Landing");
		m._cWeightMACPercent	 	= m._group.getElementById("Weight_MAC_Percent");
		
		m._cCenterGravityXMax	 	= m._group.getElementById("CenterGravity_X_Max");
		m._cCenterGravityXMin	 	= m._group.getElementById("CenterGravity_X_Min");
		m._cCenterGravityYMax	 	= m._group.getElementById("CenterGravity_Y_Max");
		m._cCenterGravityYMin	 	= m._group.getElementById("CenterGravity_Y_Min");
		
		
		
		m._nCGx 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-x-in");
		m._nCGy 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-y-in");
		m._nGross 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nEmpty 	= props.globals.initNode("/fdm/jsbsim/inertia/empty-weight-lbs");
		m._nRamp 	= props.globals.initNode("/limits/mass-and-balance/maximum-ramp-mass-lbs");
		m._nTakeoff 	= props.globals.initNode("/limits/mass-and-balance/maximum-takeoff-mass-lbs");
		m._nLanding 	= props.globals.initNode("/limits/mass-and-balance/maximum-landing-mass-lbs");
		m._nCGxMax 	= props.globals.initNode("/limits/mass-and-balance/cg-x-max-in",120.0,"DOUBLE");
		m._nCGxMin 	= props.globals.initNode("/limits/mass-and-balance/cg-x-min-in",150.0,"DOUBLE");
		m._nCGyMax 	= props.globals.initNode("/limits/mass-and-balance/cg-y-max-in",100.0,"DOUBLE");
		m._nCGyMin 	= props.globals.initNode("/limits/mass-and-balance/cg-y-min-in",-100.0,"DOUBLE");
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
		m._MAC 		= m._nMac.getValue(); # mm
		m._MAC_0 	= m._nMac0.getValue(); # mm
		
		m._ramp = m._nRamp.getValue();
		m._cWeightMaxRamp.setText(sprintf("%.2f",m._ramp));
		m._takeoff = m._nTakeoff.getValue();
		m._cWeightMaxTakeoff.setText(sprintf("%.2f",m._takeoff));
		m._landing = m._nLanding.getValue();
		m._cWeightMaxLanding.setText(sprintf("%.2f",m._landing));
		
		m._cCenterGravityXMax.setText(sprintf("%.2f",m._nCGxMax.getValue()));
		m._cCenterGravityXMin.setText(sprintf("%.2f",m._nCGxMin.getValue()));
		m._cCenterGravityYMax.setText(sprintf("%.2f",m._nCGyMax.getValue()));
		m._cCenterGravityYMin.setText(sprintf("%.2f",m._nCGyMin.getValue()));
		
		m._cWeightMACPercent.setText(sprintf("%.2f",m._MACPercent));
		
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
		me._empty = me._nEmpty.getValue();
		me._cWeightEmpty.setText(sprintf("%.2f",me._empty));
		
		me._payload = 0;
		foreach(w;keys(me._widget)){
			me._payload	+= me._widget[w]._level;
		}
		#print("WightWidget._onNotifyChange() ... _payload="~me._payload);
		me._cWeightPayload.setText(sprintf("%.2f",me._payload));
		
		
		#me._cCenterGravityBall.setTranslation(me._cgX * (64/13), (me._cgY - 136.0) * (64/13) );
		#me._cCenterGravityBall.setTranslation((me._cgY - 136.0) , me._cgX);
		
		var y = (me._cgX - 135.0) * (64/18);
		var x = (me._cgY ) * (64/13);
		me._cCenterGravityBall.setTranslation(x ,y );
		
		
		me._MACPercent = ( (me._cgX * global.CONST.INCH2METER * 1000) - me._MAC_0 ) / me._MAC;
		me._cWeightMACPercent.setText(sprintf("%.2f",me._MACPercent));
		
	},
	
	
	
};

var PayloadWidget = {
	new: func(dialog,canvasGroup,name,lable,index,listCategory=nil){
		var m = {parents:[PayloadWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "PayloadWidget";
		m._index 	= index;
		m._lable 	= lable;
		m._listCategory	= listCategory;
		
		m._nRoot	= props.globals.getNode("/payload/weight["~m._index~"]");
		m._nLable 	= m._nRoot.initNode("name","","STRING");
		m._nLevel 	= m._nRoot.initNode("weight-lb",0.0,"DOUBLE");
		m._nCapacity 	= m._nRoot.initNode("max-lb",0.0,"DOUBLE");
		m._nCategory 	= m._nRoot.initNode("category","","STRING");
		
		m._level	= m._nLevel.getValue();
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._level / m._capacity;
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
		m._cLBS.setText(sprintf("%3.2f",m._level));
		m._cName.setText(m._lable);
				
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		
		return m;
	},
	setListeners : func(instance) {
		
		#append(me._listeners, setlistener(me._nLevel,func(n){me._onLevelChange(n);},1,0) );
		append(me._listeners, setlistener(fuelPayload._nNotify,func(n){me._onNotifyChange(n);},1,0) );
		
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
	_onCatClick : func(e,cat){
		#print("PayloadWidget._onCatClick() ... "~cat);
		if(me._category == cat){
			me._category = "";
		}else{
			me._category = cat;
		}
		if(me._category != ""){
			me._nLevel.setValue(me._listCategory[me._category]*me._capacity);
		}
		me._nCategory.setValue(me._category);
		me._checkCat();
		fuelPayload._nNotify.setValue(systime());
	},
	_onNotifyChange : func(n){
		me._level	= me._nLevel.getValue();
		me._fraction	= me._level / me._capacity;
		
		me._cLBS.setText(sprintf("%3.2f",me._level));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
		
		
			
	},
	_onInputChange : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._height);
		}else{
			newFraction = me._fraction - (e.deltaY/me._height);
		}
		newFraction = global.clamp(newFraction,0.0,1.0);
		me._nLevel.setValue(me._capacity * newFraction);
		fuelPayload._nNotify.setValue(systime());
		
	},
};


var TripWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[TripWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TripWidget";
		
		m._ptree = {
			climb : {
				vs	: m._dialog._nRoot.initNode("climb/vs",1000.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("climb/gs",150.0,"DOUBLE"),
			},
			cruise : {
				fl	: m._dialog._nRoot.initNode("cruise/fl",120.0,"DOUBLE"),
				gs	: m._dialog._nRoot.initNode("cruise/gs",200.0,"DOUBLE"),
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
				nm	: m._dialog._nRoot.initNode("trip/nm",250.0,"DOUBLE"),
			},
		};
		
		m._can = {
			climb : {
				vsFrame	: m._group.getElementById(m._name~"_Climb_VS"),
				vs	: m._group.getElementById(m._name~"_Climb_VS_Value"),
				gsFrame	: m._group.getElementById(m._name~"_Climb_GS"),
				gs	: m._group.getElementById(m._name~"_Climb_GS_Value"),
				nm	: m._group.getElementById(m._name~"_Climb_NM_Value"),
				time	: m._group.getElementById(m._name~"_Climb_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Climb_Fuel_Value"),
			},
			cruise : {
				flFrame	: m._group.getElementById(m._name~"_Cruise_FL"),
				fl	: m._group.getElementById(m._name~"_Cruise_FL_Value"),
				gsFrame	: m._group.getElementById(m._name~"_Cruise_GS"),
				gs	: m._group.getElementById(m._name~"_Cruise_GS_Value"),
				nm	: m._group.getElementById(m._name~"_Cruise_NM_Value"),
				time	: m._group.getElementById(m._name~"_Cruise_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Cruise_Fuel_Value"),
			},
			descent : {
				vsFrame	: m._group.getElementById(m._name~"_Descent_VS"),
				vs	: m._group.getElementById(m._name~"_Descent_VS_Value"),
				gsFrame	: m._group.getElementById(m._name~"_Descent_GS"),
				gs	: m._group.getElementById(m._name~"_Descent_GS_Value"),
				nm	: m._group.getElementById(m._name~"_Descent_NM_Value"),
				time	: m._group.getElementById(m._name~"_Descent_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Descent_Fuel_Value"),
			},
			reserve : {
				flFrame	: m._group.getElementById(m._name~"_Reserve_FL"),
				fl	: m._group.getElementById(m._name~"_Reserve_FL_Value"),
				gsFrame	: m._group.getElementById(m._name~"_Reserve_GS"),
				gs	: m._group.getElementById(m._name~"_Reserve_GS_Value"),
				nmFrame	: m._group.getElementById(m._name~"_Reserve_NM"),
				nm	: m._group.getElementById(m._name~"_Reserve_NM_Value"),
				time	: m._group.getElementById(m._name~"_Reserve_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Reserve_Fuel_Value"),
			},
			trip : {
				nmFrame	: m._group.getElementById(m._name~"_NM"),
				nm	: m._group.getElementById(m._name~"_NM_Value"),
				time	: m._group.getElementById(m._name~"_Time_Value"),
				fuel	: m._group.getElementById(m._name~"_Fuel_Value"),
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
				profile	: m._group.getElementById(m._name~"_FlightProfile"),
			},
		};
		
		
		
		m._data = {
			climb : {
				vs	: m._ptree.climb.vs.getValue(),
				gs	: m._ptree.climb.gs.getValue(),
				nm	: 65,
				time	: 0,
				fuel	: 0,
				burnrate: 230/3600, # lbs/sec
			},
			cruise : {
				fl	: m._ptree.cruise.fl.getValue(),
				gs	: m._ptree.cruise.gs.getValue(),
				nm	: 0,
				time	: 0,
				fuel	: 0,
				burnrate: 221/3600,
			},
			descent : {
				vs	: m._ptree.descent.vs.getValue(),
				gs	: m._ptree.descent.gs.getValue(),
				nm	: 50,
				time	: 0,
				fuel	: 0,
				burnrate: 145/3600, # lbs/sec
			},
			reserve : {
				fl	: m._ptree.reserve.fl.getValue(),
				gs	: m._ptree.reserve.gs.getValue(),
				nm	: m._ptree.reserve.nm.getValue(),
				time	: 0,
				fuel	: 0,
				burnrate: 180/3600, # lbs/sec
			},
			trip : {
				nm	: m._ptree.trip.nm.getValue(),
				time	: 0,
				fuel	: 0,
			},
			graph : {
				x0	: 0,
				x25	: 0,
				x50	: 0,
				x75	: 0,
				x100	: 0,
				toc	: 0,
				tod	: 0,
				flScale : 196/300,
				nmScale : 512/100,
			},
			
			
		};
		
		
		
		
		return m;
	},
	setListeners : func(instance) {
		me._can.graph.flFrame.addEventListener("drag",func(e){me._onCruiseFlChange(e);});
		me._can.cruise.flFrame.addEventListener("drag",func(e){me._onCruiseFlChange(e);});
		me._can.cruise.flFrame.addEventListener("wheel",func(e){me._onCruiseFlChange(e);});
		me._can.cruise.gsFrame.addEventListener("drag",func(e){me._onCruiseGsChange(e);});
		me._can.cruise.gsFrame.addEventListener("wheel",func(e){me._onCruiseGsChange(e);});
		
		me._can.climb.gsFrame.addEventListener("drag",func(e){me._onClimbGsChange(e);});
		me._can.climb.gsFrame.addEventListener("wheel",func(e){me._onClimbGsChange(e);});
		me._can.climb.vsFrame.addEventListener("drag",func(e){me._onClimbVsChange(e);});
		me._can.climb.vsFrame.addEventListener("wheel",func(e){me._onClimbVsChange(e);});
		
		me._can.descent.gsFrame.addEventListener("drag",func(e){me._onDescentGsChange(e);});
		me._can.descent.gsFrame.addEventListener("wheel",func(e){me._onDescentGsChange(e);});
		me._can.descent.vsFrame.addEventListener("drag",func(e){me._onDescentVsChange(e);});
		me._can.descent.vsFrame.addEventListener("wheel",func(e){me._onDescentVsChange(e);});
		
		me._can.reserve.flFrame.addEventListener("drag",func(e){me._onReserveFlChange(e);});
		me._can.reserve.flFrame.addEventListener("wheel",func(e){me._onReserveFlChange(e);});
		me._can.reserve.gsFrame.addEventListener("drag",func(e){me._onReserveGsChange(e);});
		me._can.reserve.gsFrame.addEventListener("wheel",func(e){me._onReserveGsChange(e);});
		
		me._can.trip.nmFrame.addEventListener("drag",func(e){me._onTripNmChange(e);});
		me._can.trip.nmFrame.addEventListener("wheel",func(e){me._onTripNmChange(e);});
		me._can.reserve.nmFrame.addEventListener("drag",func(e){me._onReserveNmChange(e);});
		me._can.reserve.nmFrame.addEventListener("wheel",func(e){me._onReserveNmChange(e);});
		
	},
	init : func(instance=me){
		me.setListeners(instance);
		me._draw();
	},
	_onCruiseFlChange : func(e){
		if(e.type == "wheel"){
			me._data.cruise.fl += e.deltaY / me._data.graph.flScale;
		}else{
			me._data.cruise.fl -= e.deltaY / me._data.graph.flScale;
		}
		me._data.cruise.fl = math.floor(me._data.cruise.fl);
		me._data.cruise.fl = global.clamp(me._data.cruise.fl,0,250.0);
		me._ptree.cruise.fl.setValue(me._data.cruise.fl);
		me._draw();
	},
	_onCruiseGsChange : func(e){
		if(e.type == "wheel"){
			me._data.cruise.gs += e.deltaY;
		}else{
			me._data.cruise.gs -= e.deltaY;
		}
		me._data.cruise.gs = global.clamp(me._data.cruise.gs,80,250.0);
		me._ptree.cruise.gs.setValue(me._data.cruise.gs);
		
		me._draw();
	},
	_onClimbGsChange : func(e){
		if(e.type == "wheel"){
			me._data.climb.gs += e.deltaY;
		}else{
			me._data.climb.gs -= e.deltaY;
		}
		me._data.climb.gs = global.clamp(me._data.climb.gs,80,250.0);
		me._ptree.climb.gs.setValue(me._data.climb.gs);
		
		me._draw();
	},
	_onClimbVsChange : func(e){
		if(e.type == "wheel"){
			me._data.climb.vs += e.deltaY * 100;
		}else{
			me._data.climb.vs -= e.deltaY * 100;
		}
		me._data.climb.vs = global.clamp(me._data.climb.vs,100,1600.0);
		me._ptree.climb.vs.setValue(me._data.climb.vs);
		
		me._draw();
	},
	_onDescentGsChange : func(e){
		if(e.type == "wheel"){
			me._data.descent.gs += e.deltaY;
		}else{
			me._data.descent.gs -= e.deltaY;
		}
		me._data.descent.gs = global.clamp(me._data.descent.gs,80,250.0);
		me._ptree.descent.gs.setValue(me._data.descent.gs);
		
		me._draw();
	},
	_onDescentVsChange : func(e){
		if(e.type == "wheel"){
			me._data.descent.vs += e.deltaY * 100;
		}else{
			me._data.descent.vs -= e.deltaY * 100;
		}
		me._data.descent.vs = global.clamp(me._data.descent.vs,-1600,-100);
		me._ptree.descent.vs.setValue(me._data.descent.vs);
		
		me._draw();
	},
	_onReserveFlChange : func(e){
		if(e.type == "wheel"){
			me._data.reserve.fl += e.deltaY / me._data.graph.flScale;
		}else{
			me._data.reserve.fl -= e.deltaY / me._data.graph.flScale;
		}
		me._data.reserve.fl = math.floor(me._data.reserve.fl);
		me._data.reserve.fl = global.clamp(me._data.reserve.fl,0,250.0);
		me._ptree.reserve.fl.setValue(me._data.reserve.fl);
		
		me._draw();
	},
	_onReserveGsChange : func(e){
		if(e.type == "wheel"){
			me._data.reserve.gs += e.deltaY;
		}else{
			me._data.reserve.gs -= e.deltaY;
		}
		me._data.reserve.gs = global.clamp(me._data.reserve.gs,80,250.0);
		me._ptree.reserve.gs.setValue(me._data.reserve.gs);
		
		me._draw();
	},
	_onTripNmChange: func(e){
		if(e.type == "wheel"){
			me._data.trip.nm += e.deltaY;
		}else{
			me._data.trip.nm -= e.deltaY;
		}
		me._data.trip.nm = global.clamp(me._data.trip.nm,20,8000.0);
		me._ptree.trip.nm.setValue(me._data.trip.nm);
		
		me._draw();
	},
	_onReserveNmChange: func(e){
		if(e.type == "wheel"){
			me._data.reserve.nm += e.deltaY;
		}else{
			me._data.reserve.nm -= e.deltaY;
		}
		me._data.reserve.nm = global.clamp(me._data.reserve.nm,20,150.0);
		me._ptree.reserve.nm.setValue(me._data.reserve.nm);
		
		me._draw();
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
		
		me._data.climb.nm 	= me._data.climb.gs * (( (me._data.cruise.fl*100) / me._data.climb.vs) / 60) ;
		me._data.climb.time	= (me._data.climb.nm / me._data.climb.gs) * 3600;
		me._data.climb.burnrate = extra500.fuelFlowLog.getBurnRate(me._data.cruise.fl,me._data.climb.gs,me._data.climb.vs);
		me._data.climb.burnrate += extra500.fuelFlowLog.getBurnRate(30,me._data.climb.gs,me._data.climb.vs);
		me._data.climb.burnrate /=2;
		me._data.climb.burnrate /=3600;
		me._data.climb.fuel	= me._data.climb.time * me._data.climb.burnrate;
		
		me._data.descent.nm 	= math.abs(me._data.descent.gs * (( (me._data.cruise.fl*100) / me._data.descent.vs) / 60) );
		me._data.descent.time	= (me._data.descent.nm / me._data.descent.gs) * 3600;
		me._data.descent.burnrate = extra500.fuelFlowLog.getBurnRate(me._data.cruise.fl,me._data.descent.gs,me._data.descent.vs);
		me._data.descent.burnrate += extra500.fuelFlowLog.getBurnRate(30,me._data.descent.gs,me._data.descent.vs);
		me._data.descent.burnrate /=2;
		me._data.descent.burnrate /=3600;
		me._data.descent.fuel	= me._data.descent.time * me._data.descent.burnrate;
		
		
		me._data.reserve.time	= (me._data.reserve.nm / me._data.reserve.gs) * 3600;
		me._data.reserve.burnrate = extra500.fuelFlowLog.getBurnRate(me._data.reserve.fl,me._data.reserve.gs,0);
		me._data.reserve.burnrate /=3600;
		me._data.reserve.fuel	= me._data.reserve.time * me._data.reserve.burnrate;
		
		
		me._data.cruise.nm 	= me._data.trip.nm - me._data.climb.nm - me._data.descent.nm;
		me._data.cruise.time	= (me._data.cruise.nm / me._data.cruise.gs) * 3600;
		me._data.cruise.burnrate = extra500.fuelFlowLog.getBurnRate(me._data.cruise.fl,me._data.cruise.gs,0);
		me._data.cruise.burnrate /=3600;
		me._data.cruise.fuel	= me._data.cruise.time * me._data.cruise.burnrate;
		
		me._data.trip.time	= me._data.climb.time + me._data.cruise.time + me._data.descent.time;
		me._data.trip.fuel	= me._data.climb.fuel + me._data.cruise.fuel + me._data.descent.fuel;
		
		
		me._data.graph.x25	= me._data.trip.nm * 0.25;
		me._data.graph.x50	= me._data.trip.nm * 0.50;
		me._data.graph.x75	= me._data.trip.nm * 0.75;
		me._data.graph.x100	= me._data.trip.nm;
		
		me._data.graph.nmScale =  512 / me._data.trip.nm;
	},
	_draw : func(){
		
		me._calculate();
		
		me._can.graph.flFrame.setTranslation(0,-me._data.cruise.fl*me._data.graph.flScale);
		me._can.graph.fl.setText(sprintf("%3i",me._data.cruise.fl));
		
		me._can.climb.vs.setText(sprintf("%4i",me._data.climb.vs));
		me._can.climb.gs.setText(sprintf("%3i",me._data.climb.gs));
		me._can.climb.nm.setText(sprintf("%i",me._data.climb.nm));
		me._can.climb.time.setText(me.getTime(me._data.climb.time));
		me._can.climb.fuel.setText(sprintf("%.2f",me._data.climb.fuel));
		
		me._can.cruise.fl.setText(sprintf("%3i",me._data.cruise.fl));
		me._can.cruise.gs.setText(sprintf("%3i",me._data.cruise.gs));
		me._can.cruise.nm.setText(sprintf("%i",me._data.cruise.nm));
		me._can.cruise.time.setText(me.getTime(me._data.cruise.time));
		me._can.cruise.fuel.setText(sprintf("%.2f",me._data.cruise.fuel));
		
		me._can.descent.vs.setText(sprintf("%4i",me._data.descent.vs));
		me._can.descent.gs.setText(sprintf("%3i",me._data.descent.gs));
		me._can.descent.nm.setText(sprintf("%i",me._data.descent.nm));
		me._can.descent.time.setText(me.getTime(me._data.descent.time));
		me._can.descent.fuel.setText(sprintf("%.2f",me._data.descent.fuel));
		
		me._can.reserve.fl.setText(sprintf("%3i",me._data.reserve.fl));
		me._can.reserve.gs.setText(sprintf("%3i",me._data.reserve.gs));
		me._can.reserve.nm.setText(sprintf("%i",me._data.reserve.nm));
		me._can.reserve.time.setText(me.getTime(me._data.reserve.time));
		me._can.reserve.fuel.setText(sprintf("%.2f",me._data.reserve.fuel));
		
		me._can.trip.nm.setText(sprintf("%i",me._data.trip.nm));
		me._can.trip.time.setText(me.getTime(me._data.trip.time));
		me._can.trip.fuel.setText(sprintf("%.2f",me._data.trip.fuel));
		
		
		me._can.graph.x0.setText(sprintf("%i",me._data.graph.x0));
		me._can.graph.x25.setText(sprintf("%i",me._data.graph.x25));
		me._can.graph.x50.setText(sprintf("%i",me._data.graph.x50));
		me._can.graph.x75.setText(sprintf("%i",me._data.graph.x75));
		me._can.graph.x100.setText(sprintf("%i",me._data.graph.x100));
		
		
		me._can.graph.profile.set("coord[3]",-me._data.cruise.fl * me._data.graph.flScale);
		me._can.graph.profile.set("coord[7]",me._data.cruise.fl * me._data.graph.flScale);
		
		me._can.graph.profile.set("coord[2]",me._data.climb.nm * me._data.graph.nmScale);
		me._can.graph.profile.set("coord[4]",me._data.cruise.nm * me._data.graph.nmScale);
		me._can.graph.profile.set("coord[6]",me._data.descent.nm * me._data.graph.nmScale);
		
		me._can.graph.toc.setTranslation(me._data.climb.nm * me._data.graph.nmScale,0);
		me._can.graph.tod.setTranslation((me._data.climb.nm+me._data.cruise.nm) * me._data.graph.nmScale,0);
		
		
	},
	_draw2 : func(){
		me._cFL.setTranslation(me._pFL.x,-me._pFL.y);
		me._cTOC.setTranslation(me._pTOC.x,me._pTOC.y);
		me._cTOD.setTranslation(me._pTOC.x + me._pTOD.x,me._pTOD.y);
		me._cNM.setTranslation(me._pTOC.x + me._pTOD.x + me._pNM.x,me._pNM.y);
		
		me._cFlightProfile.set("coord[3]",-me._pFL.y);
		me._cFlightProfile.set("coord[7]",me._pFL.y);
		
		me._cFlightProfile.set("coord[2]",me._pTOC.coordX + me._pTOC.x);
		me._cFlightProfile.set("coord[4]",me._pTOD.coordX + me._pTOD.x);
		me._cFlightProfile.set("coord[6]",me._pNM.coordX  + me._pNM.x);
		
	}
	
};


var FuelPayloadClass = {
	new : func(){
		var m = {parents:[FuelPayloadClass]};
		m._nRoot 	= props.globals.initNode("/extra500/dialog/fuel");
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
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
				me._widget[widget] = nil;
			}
		}
		
	},
	open : func(){
		if(getprop("/gear/gear[0]/wow") == 1){
			me.openFuel();
		}else{
			me.openMsg();
		}
		
	},
	openMsg : func(){
		me._dlg = MyWindow.new([512,384], "dialog");
		me._dlg._onClose = func(){
			fuelPayload._onClose();
		}
		me._dlg.set("title", "Unable to refuel in Air");
		me._dlg.move(100,100);
		
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#3F3D38");
#              
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
		
		me._widget.weight = WightWidget.new(me,me._group,"Weight",me._widget);
		me._widget.trip = TripWidget.new(me,me._group,"Trip");
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].init();
			}
		}
		
		#me.setListeners();
		
		
	},
	_onNotifyChange : func(n){

	},
	_onFuelTotalChange : func(n){
		
	}
	
};

var fuelPayload = FuelPayloadClass.new();

