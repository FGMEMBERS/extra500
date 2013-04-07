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

    m.dynamic_text =
      g.createChild("text", "dynamic-text")
       .setText("Text node created at runtime.")
       .setFont("Helvetica.txf")
       .setFontSize(50)
       .setAlignment("center-center")
       .setTranslation(384, 200);
    #m.tf = m.dynamic_text.createTransform();
    #m.tf.setTranslation(384, 200);

    
    return m;
  },
  setShunt : func(text){
	me.dynamic_text.setText(text);
  },
  update: func()
  {

  },
};
var demo = canvas_demo.new();
# setlistener("/nasal/canvas/loaded", func {
#   
#   demo.update();
# }, 1);