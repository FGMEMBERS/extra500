# ==============================================================================
# DEMO
# ==============================================================================
var canvas_demo = {
  new: func()
  {
    debug.dump("Creating new canvas demo...");

    var m = { parents: [canvas_demo] };
    
    # create a new canvas...
    m.canvas = canvas.new({
      "name": "PFD-Test",
      "size": [1024, 1024],
      "view": [768, 1024],
      "mipmapping": 1
    });
    
    # ... and place it on the object called PFD-Screen
    m.canvas.addPlacement({"node": "PFD-Screen"});
    m.canvas.setColorBackground(0,0.04,0);
    
    # and now do something with it
    m.dt = props.globals.getNode("sim/time/delta-sec");
    m.gmt  = props.globals.getNode("sim/time/gmt");
    
    var g = m.canvas.createGroup();
#     var g_tf = g.createTransform();
#     g_tf.setRotation(0.1 * math.pi);
    
    m.text_title =
      g.createChild("text", "line-title")
       .setDrawMode(canvas.Text.TEXT + canvas.Text.FILLEDBOUNDINGBOX)
       .setColor(0,0,0)
       .setColorFill(0,1,0)
       .setAlignment("center-top")
       .setFont("LiberationFonts/LiberationMono-Bold.ttf")
       .setFontSize(70, 1.5)
       .setTranslation(384, 5);

    m.textSim =
      g.createChild("text", "dynamic-text")
       .setText("Text node created at runtime.")
       .setFont("LiberationFonts/LiberationMono-Bold.ttf")
       .setFontSize(40)
       .setAlignment("left-top")
       .setTranslation(20, 20);
    m.textElectric =
      g.createChild("text", "dynamic-text")
       .setText("Text node created at runtime.")
       .setFont("LiberationFonts/LiberationMono-Bold.ttf")
       .setFontSize(40)
       .setAlignment("left-top")
       .setTranslation(20, 200);
    #m.tf = m.dynamic_text.createTransform();
    #m.tf.setTranslation(384, 200);

    
    return m;
  },
  update: func()
  {
		
		
		var text = "";
		var text = sprintf("Cycle time used : %.4f sec",run.cycleTimeUsed);
	
		me.textSim.setText(text);
		
		text = "";
		text ~= sprintf("Battery    %0.2f V   %0.2f A\n",extra500.mainBoard.batteryShunt.voltIndicated,extra500.mainBoard.batteryShunt.ampereIndicated);
		text ~= sprintf("Generator  %0.2f V   %0.2f A\n",0.0,0.0);
		text ~= sprintf("Altenator  %0.2f V   %0.2f A\n",0.0,0.0);
		text ~="\nLight\n";
		text ~= sprintf("Keypad     %0.2f %%\n",extra500.lightBoard.Keypad.state);
		text ~= sprintf("Glare      %0.2f %%\n",extra500.lightBoard.Glare.state);
		text ~= sprintf("Instrument %0.2f %%\n",extra500.lightBoard.Instrument.state);
		text ~= sprintf("Switches   %0.2f %%\n",extra500.lightBoard.Switches.state);
		text ~= sprintf("Annuciator %0.2f %%\n",extra500.lightBoard.Annunciator.state);
		
		me.textElectric.setText(text);
  },
};


var canvas_svg = {
  new: func()
  {
    var m = { parents: [canvas_svg] };
    
    # create a new canvas...
    m.canvas = canvas.new({
      "name": "PFD-Test",
      "size": [1024, 1024],
      "view": [768, 1024],
      "mipmapping": 1
    });
    
    # ... and place it on the object called PFD-Screen
    m.canvas.addPlacement({"node": "PFD-Screen"});
    m.canvas.setColorBackground(0,0.04,0);
     
    var g = m.canvas.createGroup();
#     var g_tf = g.createTransform();
#     g_tf.setRotation(0.1 * math.pi);
    canvas.parsesvg(g, "system/IFD/IFD01.svg");
    m.bar = g.getElementById("simTime.bar");
    #m.bar.setCenter(100,0);
    m.needle = g.getElementById("simTime.needle");
    
   # debug.dump(m.bar);
     return m;
  },
  update: func()
  {
	me.needle.setTranslation(run.cycleTimeUsed*4000,0);
	me.bar.setScale(run.cycleTimeUsed*10,1);
	#me.bar.set("width",run.cycleTimeUsed*4000);
	me.bar.width = run.cycleTimeUsed*4000;
	
  },
};

var demo = canvas_demo.new();
# setlistener("/nasal/canvas/loaded", func {
#   
#   demo.update();
# }, 1);