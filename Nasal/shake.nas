# A3XX Shaking

# Copyright (c) 2019 Joshua Davidson (Octal450)

var shakeEffectA3XX = props.globals.initNode("/systems/shake/effect", 0, "BOOL");
var shakeA3XX = props.globals.initNode("/systems/shake/shaking", 0, "DOUBLE");
var rSpeed = 0;
var sf = 0;
var n_g_c = 0;
var n_g_l = 0;
var n_g_r = 0;

var theShakeEffect = func {
	n_g_c = getprop("/gear/gear[0]/compression-norm") or 0;
	n_g_l = getprop("/gear/gear[1]/compression-norm") or 0;
	n_g_r = getprop("/gear/gear[2]/compression-norm") or 0;
	rSpeed = getprop("/gear/gear[0]/rollspeed-ms") or 0;
	sf = rSpeed / 94000;

	if (shakeEffectA3XX.getBoolValue() and (n_g_c > 0 or n_g_l > 0 or n_g_r > 0)) {
		interpolate("/systems/shake/shaking", sf, 0.03);
		settimer(func {
			interpolate("/systems/shake/shaking", -sf * 2, 0.03); 
		}, 0.06);
		settimer(func {
			interpolate("/systems/shake/shaking", sf, 0.03);
		}, 0.12);
		settimer(theShakeEffect, 0.09);	
	} else {
		setprop("/systems/shake/shaking", 0);
		setprop("/systems/shake/effect", 0);		
	}	    
}

setlistener("/systems/shake/effect", func(state) {
	if(state.getBoolValue()) {
		theShakeEffect();
	}
}, 1, 0);
