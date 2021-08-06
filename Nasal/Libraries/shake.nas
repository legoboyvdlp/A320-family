# A3XX Shaking

# Copyright (c) 2020 Josh Davidson (Octal450)

var shakeEffectA3XX = props.globals.initNode("/systems/shake/effect", 0, "BOOL");
var shakeA3XX = props.globals.initNode("/systems/shake/shaking", 0, "DOUBLE");
var sf = 0;

var theShakeEffect = func {
	if (shakeEffectA3XX.getBoolValue()) {
		sf = pts.Gear.rollspeed[0].getValue() / 94000;
		interpolate("/systems/shake/shaking", sf, 0.03);
		settimer(func {
			interpolate("/systems/shake/shaking", -sf * 2, 0.03); 
		}, 0.06);
		settimer(func {
			interpolate("/systems/shake/shaking", sf, 0.03);
		}, 0.12);
		settimer(theShakeEffect, 0.09);	
	} else {
		shakeA3XX.setValue(0);
		shakeEffectA3XX.setBoolValue(0);
	}	    
}

setlistener("/systems/shake/effect", func {
	if (shakeEffectA3XX.getBoolValue()) {
		theShakeEffect();
	}
}, 0, 0);