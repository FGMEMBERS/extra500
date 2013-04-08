var Part = {
	new : func(nRoot,name){
		var m = {parents:[
			Part,
			ServiceAble.new(nRoot)
		]};
		m.nRoot = nRoot;
		m.nRoot.initNode("name",name,"STRING");
		m.name = name;
		return m;
	},
};

var aListSimStateAble = [];
var aListElectricFuseAble = [];
