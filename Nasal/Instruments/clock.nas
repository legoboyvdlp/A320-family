#
# Chrono - Clock - ET 
#
var chr = aircraft.timer.new("instrumentation/chrono[0]/elapsetime-sec",1);
var clk = aircraft.timer.new("instrumentation/clock/elapsetime-sec",1);

setlistener("sim/signals/fdm-initialized", func {
	chr.stop();
	chr.reset();
    clk.reset();
    clk.stop();
    props.globals.initNode("instrumentation/clock/indicated-string",0,"STRING");
    props.globals.initNode("instrumentation/clock/elapsed-string",0,"STRING");
    props.globals.initNode("instrumentation/clock/elapsetime-sec",0,"INT");
    props.globals.initNode("instrumentation/clock/et-selector",1,"INT");
	props.globals.initNode("instrumentation/clock/utc-selector",0,"INT");
    props.globals.initNode("instrumentation/clock/set-knob",0,"INT");
    props.globals.initNode("instrumentation/clock/et-hr",0,"INT");
    props.globals.initNode("instrumentation/clock/et-min",0,"INT");
    props.globals.initNode("instrumentation/chrono[0]/chr-et-string",0,"STRING");
    props.globals.initNode("instrumentation/chrono[0]/elapsetime-sec",0,"INT");
    props.globals.initNode("instrumentation/chrono[0]/chr-et-sec",0,"INT");
    props.globals.initNode("instrumentation/chrono[0]/chrono-reset",1,"INT");
    props.globals.initNode("instrumentation/chrono[0]/chr-et-min",0,"INT");
    props.globals.initNode("instrumentation/chrono[0]/chr-et-sec",0,"INT");
    start_loop.start();
});

setlistener("instrumentation/chrono[0]/chrono-reset", func(et){
    var tmp = et.getValue();
    if(tmp == 2){
        chr.stop();
        chr.reset();
        setprop("instrumentation/chrono[0]/chrono-reset", 1);
    }elsif(tmp==1){
       	chr.stop();
    }elsif(tmp==0){
       	chr.start();
    }
},0,0);

setlistener("instrumentation/clock/et-selector", func(et){
    var tmp1 = et.getValue();
    if(tmp1 == 2){
        clk.reset();
    }elsif(tmp1==1){
        clk.stop();
    }elsif(tmp1==0){
        clk.start();
    }
},0,0);


var start_loop = maketimer(0.1, func {
    var UTC_date = sprintf("%02d %02d %02d", getprop("sim/time/utc/month"), getprop("sim/time/utc/day"), substr(sprintf("%2d", getprop("sim/time/utc/year")),1,2));
    setprop("instrumentation/clock/utc-date", UTC_date);
    var UTC_date1 = sprintf("%02d", getprop("sim/time/utc/month"));
    var UTC_date2 = sprintf("%02d", getprop("sim/time/utc/day"));
    var UTC_date3 = substr(sprintf("%2d", getprop("sim/time/utc/year")),1,2);
    var clock2_2 = substr(getprop("instrumentation/clock/indicated-string"),6,2);
    setprop("instrumentation/clock/indicated-seconds", sprintf("%02d", clock2_2));
    setprop("instrumentation/clock/utc-date", UTC_date);
    setprop("instrumentation/clock/utc-date1", UTC_date1);
    setprop("instrumentation/clock/utc-date2", UTC_date2);
    setprop("instrumentation/clock/utc-date3", UTC_date3);
    if (getprop("instrumentation/clock/set-knob")=="")
    {
   		setprop("instrumentation/clock/set-knob", 0);
    };
    if (getprop("instrumentation/clock/utc-selector")=="")
    {
   		setprop("instrumentation/clock/utc-selector", 0);
    };

	# Chrono
#    var chr_tmp = getprop("instrumentation/chrono/elapsetime-sec");
#    if(chr_tmp == 0)
#    {
#        chr_tmp = getprop("instrumentation/chrono/elapsetime-sec");
#    }
    var chr_tmp = getprop("instrumentation/chrono[0]/elapsetime-sec");
    if (chr_tmp >= 6000) {
    	setprop("instrumentation/chrono[0]/elapsetime-sec", chr_tmp-6000);
    };
    var chr_min = int(chr_tmp * 0.0166666666667);
    if (chr_tmp >= 60) {
    	var chr_sec = int(chr_tmp - (chr_min * 60));
    } else {
		var chr_sec = int(chr_tmp);
    };
    setprop("instrumentation/chrono[0]/chr-et-min",chr_min);
    setprop("instrumentation/chrono[0]/chr-et-sec",chr_sec);
	chr_tmp = sprintf("%02d %02d", chr_min, chr_sec);
    setprop("instrumentation/chrono[0]/chr-et-string", chr_tmp);

	# ET clock
	var et_tmp = getprop("instrumentation/clock/elapsetime-sec");
    var et_min = int(et_tmp * 0.0166666666667);
    var et_hr  = int(et_min * 0.0166666666667);
    et_min = et_min - (et_hr * 60);
    #et_tmp = et_hr * 100 + et_min;
    #et_tmp = int(et_tmp * 0.0166666666667);
    #et_hr = int(et_tmp * 0.0166666666667);
    #et_min = et_tmp - (et_hr * 60);
    setprop("instrumentation/clock/et-hr",et_hr);
    setprop("instrumentation/clock/et-min",et_min);
    et_tmp = sprintf("%02d:%02d", et_hr, et_min);
    setprop("instrumentation/clock/elapsed-string", et_tmp);
	
});
