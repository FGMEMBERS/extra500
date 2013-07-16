
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

var SvgWidget = {
	new: func(canvasGroup,name){
		var m = {parents:[TankWidget]};
		m._listeners 	= [];
		m._name 	= name;
		m._group	= canvasGroup;
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
	
}

var TankWidget = {
	new: func(canvasGroup,name,index,refuelable=1){
		var m = {parents:[SvgWidget.new(canvasGroup,name),TankWidget]};
		m._index 	= index;
		m._refuelable 	= refuelable;
		m._nLevel 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/level-gal_us",0.0,"DOUBLE");
		m._nCapacity 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/capacity-gal_us",0.0,"DOUBLE");
		
		m._level	= m._nLevel.getValue();
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._level / m._capacity;
			
		m._cFrame 	= m._group.getElementById(me._name~"_Frame");
		m._cFuelLevel 	= m._group.getElementById(me._name~"_Fuel_Level");
				
		
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		
	},
	setListeners : func(instance) {
		
		append(me._listeners, setlistener(me._nLevel,func(n){me._onFuelLevelChange(n);},1,0) );
		if(me._refuelable == 1){
			me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
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
		
		me.cLeftAuxFuelLevel.setInt("coord[1]", m._bottom - (me._height * me._fraction));
			
	},
	_onFuelInputChange : func(e){
		
	},
}


var FuelPayloadClass = {
	new : func(){
		var m = {parents:[FuelPayloadClass]};
		m._nRoot = props.globals.initNode("/sim/gui/dialogs/FuelPayload/dialog");
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
		append(me._listeners, setlistener("/consumables/fuel/tank[0]/level-gal_us",func(n){me._onLeftAuxFuelLevelChange(n);},1,0) );
	},
	_onClose : func(){
		print("FuelPayloadClass._onClose() ... ");
		me.removeListeners();
		me._dlg.del();
	},
	open : func(){
		
		
		me._dlg = MyWindow.new([1024,768], "dialog");
		me._dlg._onClose = func(){
			fuelPayload._onClose();
		}
		me._dlg.set("title", me._title);
		me._dlg.move(100,100);
		
		
		me._canvas = me._dlg.createCanvas().set("background", "#f2f1f000");
#                        
		
		me._group = me._canvas.createGroup();

		canvas.parsesvg(me._group, "Dialogs/FuelPayload.svg");
		
		
		#me.setListeners();
		
		
	},
	_onLeftAuxFuelChange : func(e){
		printf("%s: screen(%.1f|%.1f) client(%.1f|%.1f) %.1f",e.type, e.screenX, e.screenY, e.clientX, e.clientY, e.deltaY); 
		var bottom 	= me.cLeftAuxFuelLevel.get("coord[3]");
		var top		= me.cLeftAuxFuelLevel.get("coord[1]");
		var height	= bottom - top;
		var newTop	= top + e.deltaY;
		me.cLeftAuxFuelLevel.setInt("coord[1]", newTop);
	},
	_onLeftAuxFuelLevelChange : func(n){
		
	}
	
};

var fuelPayload = FuelPayloadClass.new();

