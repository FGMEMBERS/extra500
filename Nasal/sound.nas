click = func(button) {
    if (getprop("sim/freeze/replay-state"))
        return;
    var propName="sim/sound/click["~button~"]";
    setprop(propName,1);
    settimer(func { click_reset(propName) },0.4);
}
click_reset = func(propName) {
    setprop(propName,0);
}