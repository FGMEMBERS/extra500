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
#      Date: April 16 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#
 
var Display = {
	id : 0,
	new : func(x, y, show_tags = 1) {
		var m = { parents: [Display] };
		#
		# "public"
		m.x = x;
		m.y = y;
		m.width = 100;
		m.height = 100;
		m.padding = 5;
		m.tags = show_tags;
		m.font = "HELVETICA_14";
		m.bg = [0.5, 0.5, 0.5, 0];		# background color
		m.fg = [0.9, 0.4, 0.2, 1];	# default foreground color
		m.tagformat = "%s";
		m.format = "%.12g";
		m.title = "";
		m.interval = 0.1;
		#
		# "private"
		m.entries = [];
		m.loopid = 0;
		m.dialog = nil;
		m.name = "__screen_display_" ~ (Display.id += 1) ~ "__";
		m.base = props.globals.getNode("/sim/gui/dialogs/property-display-" ~ Display.id, 1);
		m.namenode = props.Node.new({ "dialog-name": m.name });
		setlistener("/sim/startup/xsize", func m.redraw());
		setlistener("/sim/startup/ysize", func m.redraw());
		#m.reset();
		return m;
	},
	setcolor : func(r, g, b, a = 1) {
		me.fg = [r, g, b, a];
		me.redraw();
		me;
	},
	setfont : func(font) {
		me.font = font;
		me.redraw();
		me;
	},
	_create_ : func {
		me.dialog = gui.Widget.new();
		me.dialog.set("name", me.name);
		me.dialog.set("x", me.x);
		me.dialog.set("y", me.y);
		me.dialog.set("width", me.width);
		me.dialog.set("height", me.height);
		me.dialog.set("layout", "vbox");
		me.dialog.set("default-padding", me.padding);
		me.dialog.setFont(me.font);
		me.dialog.setColor(me.bg[0], me.bg[1], me.bg[2], me.bg[3]);
		if (me.title != ""){
			var t = me.dialog.addChild("text");
			t.set("label",me.title);
			me.dialog.addChild("hrule");
		}
		
		foreach (var e; me.entries) {
			if (e.mode == 0){
				var w = me.dialog.addChild("text");
				w.set("halign", "left");
				w.set("label", "M");    # mouse-grab sensitive area
				w.set("property", e.target.getPath());
				w.set("format", me.tags ? e.tag ~ " = %s" : "%s");
				w.set("live", 1);
				w.setColor(me.fg[0], me.fg[1], me.fg[2], me.fg[3]);
			}else{
				var w = me.dialog.addChild("text");
				w.set("halign", "left");
				#w.set("label", "M");    # mouse-grab sensitive area
				w.set("property", e.target.getPath());
				w.set("format", "%s");
				w.set("live", 1);
				w.setColor(me.fg[0], me.fg[1], me.fg[2], me.fg[3]);
			}
		}
		fgcommand("dialog-new", me.dialog.prop());
		fgcommand("dialog-show", me.namenode);
	},
	# add() opens already, so call open() explicitly only after close()!
	open : func {
		if (me.dialog != nil) {
			fgcommand("dialog-show", me.namenode);
			me._loop_(me.loopid += 1);
		}
	},
	close : func {
		if (me.dialog != nil) {
			fgcommand("dialog-close", me.namenode);
			me.loopid += 1;
			me.dialog = nil;
		}
	},
	toggle : func {
		me.dialog == nil ? me.redraw() : me.close();
	},
	reset : func {
		me.close();
		me.loopid += 1;
		me.entries = [];
	},
	redraw : func {
		#print("Display.redraw() ... "~me.name);
		
		me.close();
		me._create_();
		me.open();
	},
	add : func(p...) {
		foreach (nextprop; var n; props.nodeList(p)) {
			var path = n.getPath();
			foreach (var e; me.entries) {
				if (e.node.getPath() == path)
					continue nextprop;
				e.parent = e.node;
				e.tag = sprintf(me.tagformat, me.nameof(e.node));
			}
			append(me.entries, {mode:0, node: n, parent: n,
					tag: sprintf(me.tagformat, me.nameof(n)),
					target: me.base.getChild("entry", size(me.entries), 1) });
		}

		# extend names to the left until they are unique
		while (me.tags) {
			var uniq = {};
			foreach (var e; me.entries) {
				if (contains(uniq, e.tag))
					append(uniq[e.tag], e);
				else
					uniq[e.tag] = [e];
			}

			var done = 1;
			foreach (var u; keys(uniq)) {
				if (size(uniq[u]) == 1)
					continue;
				done = 0;
				foreach (var e; uniq[u]) {
					e.parent = e.parent.getParent();
					if (e.parent != nil)
						e.tag = me.nameof(e.parent) ~ '/' ~ e.tag;
				}
			}
			if (done)
				break;
		}
		#me.redraw();
		#me;
	},
	addNasal : func(format,callback){
			append(me.entries, { mode:1, format:format, callback:callback,
					target: me.base.getChild("entry", size(me.entries), 1) });
	},
	addNamed : func(format,n){
			if (n!=nil){
			append(me.entries, {mode:2, node: n, parent: n, format:format,
					target: me.base.getChild("entry", size(me.entries), 1) });
			}
	},
	add_Node: func(lable,n){
			if (n!=nil){
			append(me.entries, {mode:3, node: n, parent: n, lable:lable,
					target: me.base.getChild("entry", size(me.entries), 1) });
			}
	},
	update : func {
		foreach (var e; me.entries) {
			if (e.mode == 0){
				var type = e.node.getType();
				if (type == "NONE")
					var val = "nil";
				elsif (type == "BOOL")
					var val = e.node.getValue() ? "true" : "false";
				elsif (type == "STRING" or type == "UNSPECIFIED")
					var val = "'" ~ sanitize(e.node.getValue(), 1) ~ "'";
				else
					var val = sprintf(me.format, e.node.getValue());
				e.target.setValue(val);
			}else if (e.mode == 1){
				var val = sprintf(e.format, e.callback());
				e.target.setValue(val);
			}else if (e.mode == 2){
				var val = sprintf(e.format, ( e.node.getValue() ));
				e.target.setValue(val);
			}else if (e.mode == 3){
				var type = e.node.getType();
				if (type == "NONE")
					var val = sprintf("%s %s",e.lable,"nil");
				elsif (type == "BOOL")
					var val = sprintf("%s %s",e.lable,(e.node.getValue() ? "true" : "false"));
				elsif (type == "STRING" or type == "UNSPECIFIED")
					var val = lable~"'" ~ sanitize(e.node.getValue(), 1) ~ "'";
				else
					var val = sprintf("%s %s",e.lable, e.node.getValue());
				
				e.target.setValue(val);
			}
		}
	},
	_loop_ : func(id) {
		id != me.loopid and return;
		me.update();
		settimer(func me._loop_(id), me.interval);
	},
	nameof : func(n) {
		var name = n.getName();
		if (var i = n.getIndex())
			name ~= '[' ~ i ~ ']';
		return name;
	},
};


var Page = {
	new : func(name) {
		var m = { parents: [Page] };
		m.name = name;
		m.displays = [];
		return m;
	},
	add : func(display){
		append(me.displays,display);
	},
	open : func(){
		#print("Page.open() ... "~me.name);
		gui.popupTip("Page - "~me.name);
		foreach (var display; me.displays) {
			display.redraw();
		}
	},
	close :func(){
		#print("Page.close() ... "~me.name);
		foreach (var display; me.displays) {
			display.close();
		}
	}
};

var Book = {
	new : func(nRoot,name) {
		var m = { parents: [Book] };
		m.pages = [];
		m.index = 0;
		m.nIndex = nRoot.initNode("index",m.index,"INT");
		m.index = m.nIndex.getValue();
		
		return m;
	},
	_adjustIndex : func(value){
		me.index = me.nIndex.getValue();
		me.index += value;
		me.index = math.mod(me.index,size(me.pages));
		me.nIndex.setValue(me.index);	
	},
	add : func(page){
		append(me.pages,page);
	},
	browse : func(count){
		me.pages[me.index].close();
		me._adjustIndex(count);
		me.pages[me.index].open();
		
	},
	open : func(){
		#print("Book.open() ... "~me.index);
		me.pages[me.index].open();
	},
	close : func(){
		#print("Book.close() ... "~me.index);
		me.pages[me.index].close();
	},
};


