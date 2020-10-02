# ==================================== timer stuff ===============================
var run_tyresmoke0 = 0;
var run_tyresmoke1 = 0;
var run_tyresmoke2 = 0;
var tyresmoke_0 = aircraft.tyresmoke.new(0, 0, 0.8, 0);
var tyresmoke_1 = aircraft.tyresmoke.new(1, 0, 0.8, 0);
var tyresmoke_2 = aircraft.tyresmoke.new(2, 0, 0.8, 0);

# =============================== listeners ===============================
setlistener("gear/gear[0]/position-norm", func {
	if (pts.Gear.position[0].getValue()){
		run_tyresmoke0 = 1;
	}else{
		run_tyresmoke0 = 0;
	}
},1,0);

setlistener("gear/gear[1]/position-norm", func {
	if (pts.Gear.position[1].getValue()){
		run_tyresmoke1 = 1;
	}else{
		run_tyresmoke1 = 0;
	}
},1,0);

setlistener("gear/gear[2]/position-norm", func {
	if (pts.Gear.position[2].getValue()){
		run_tyresmoke2 = 1;
	}else{
		run_tyresmoke2 = 0;
	}
},1,0);

#============================ Rain ===================================
aircraft.rain.init();

#==================== Tyre Smoke / Rain Effects ======================
var tyresmoke_and_rain = func {
	if (run_tyresmoke0)
		tyresmoke_0.update();
	if (run_tyresmoke1)
		tyresmoke_1.update();
	if (run_tyresmoke2)
		tyresmoke_2.update();
	aircraft.rain.update();
	settimer(tyresmoke_and_rain, 0);
}# end tyresmoke_and_rain

# == fire it up ===
tyresmoke_and_rain();

# end 
