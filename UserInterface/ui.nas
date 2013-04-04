 
var UserInterface = {
	new : func{
		var m = {parents:[
			UserInterface
		]};
		
		m.aFuncHash = {};
		return m;
	},
	click : func(name,args=nil){
		var action = me.aFuncHash[name];
		#print("UserInterface.click ... action typeof("~typeof(action)~")");
		#debug.dump(me);
		#debug.dump(action.callback);
		if (contains(me.aFuncHash,name)){
			#print("UserInterface ... registered key");
			
			if (args != nil){
				#print("UserInterface ... we have some click args");
				me.aFuncHash[name]["callback"](args);
			}else if (me.aFuncHash[name]["args"] != nil){
				#print("UserInterface ... we have some registered args");
				me.aFuncHash[name]["callback"](me.aFuncHash[name]["args"]);
			}else{
				#print("UserInterface ... simple call");
				me.aFuncHash[name]["callback"]();
			}
			
			
		}else{
			print("###############################################");
			print("UserInterface ... no registered func("~name~") ");
			print("###############################################");
		}
		
	},
	register : func(name,callback,args=nil){
		#print("UserInterface ... register ("~name~")");
		#var action = Action.new(name,callback,args);
		
		var action = {"name":name,"callback":callback,"args":args};
		#append(me.aFuncHash,name,action);
		me.aFuncHash[name] = action;
	},
	echo : func(search=nil){
		#print("UserInterface.echo("~search~") ... ");
		
		print("-------------------------\n");
		
		var index = sort(keys(me.aFuncHash), func (a,b) cmp (me.aFuncHash[a].name, me.aFuncHash[b].name)) ;
		if (search != nil){
			
			foreach(var i;index) {
				#debug.dump(me.aFuncHash[i]);
				if (find(search, me.aFuncHash[i].name) >= 0 ){
							
					if (find("=", me.aFuncHash[i].name) >= 0 ){
						print("UI.click(\""~me.aFuncHash[i].name~"\",0.0);");
					}else{
						print("UI.click(\""~me.aFuncHash[i].name~"\");");
					}
					
				}
				
			}
				
		}else{
	
			foreach(var i;index) {
				#debug.dump(me.aFuncHash[i]);
					if (find("=", me.aFuncHash[i].name) >= 0 ){
						print("UI.click(\""~me.aFuncHash[i].name~"\",1.0);");
					}else{
						print("UI.click(\""~me.aFuncHash[i].name~"\");");
					}
					
			}
			
		}
		
		print("-------------------------\n");
	},
};

var oCockpit = UserInterface.new();

var click = func(name,args=nil){
	oCockpit.click(name,args);
}
var register = func(name,callback,args=nil){
	oCockpit.register(name,callback,args);
}
var echo = func(search=nil){
	oCockpit.echo(search);
}
