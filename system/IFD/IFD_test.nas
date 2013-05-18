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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             08.05.13
#


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
  update: func(timestamp)
  {
		
		
		var text = "";
		var text = sprintf("Sim time : %.4f sec",run.cycleTimeUsed);
	
		me.textSim.setText(text);
# 		
		text = "";
		text ~= sprintf("Generator  %0.2f V   %0.2f A\n",extra500.mainBoard.generatorShunt.indicatedVolt,extra500.mainBoard.generatorShunt.indicatedAmpere);
		text ~= sprintf("Battery    %0.2f V   %0.2f A\n",extra500.mainBoard.batteryShunt.indicatedVolt,extra500.mainBoard.batteryShunt.indicatedAmpere);
		text ~= sprintf("Altenator  %0.2f V   %0.2f A\n",extra500.mainBoard.alternatorShunt.indicatedVolt,extra500.mainBoard.alternatorShunt.indicatedAmpere);
		text ~="\nEngine\n";
		text ~= sprintf("Fuel cutoff      %s\n",extra500.engine._cutoffState==0?"off":"on");
		text ~= sprintf("Reverser         %s\n",extra500.engine.nReverser.getValue()==0?"off":"on");
		text ~="\nGround\n";
		text ~= sprintf("External Power   %s\n",extra500.externalPower.generatorActive==0?"off":"on");
		
# 		text ~= sprintf("Keypad     %0.2f %%\n",extra500.lightBoard.Keypad.state);
# 		text ~= sprintf("Glare      %0.2f %%\n",extra500.lightBoard.Glare.state);
# 		text ~= sprintf("Instrument %0.2f %%\n",extra500.lightBoard.Instrument.state);
# 		text ~= sprintf("Switches   %0.2f %%\n",extra500.lightBoard.Switches.state);
# 		text ~= sprintf("Annuciator %0.2f %%\n",extra500.lightBoard.Annunciator.state);
# 		
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
  update: func(timestamp)
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