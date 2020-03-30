#
# Chrono - Clock - ET 
#
var chr_et = aircraft.timer.new("instrumentation/chrono/elapsetime-sec",1);
var et = aircraft.timer.new("instrumentation/clock/elapsetime-sec",1);

setlistener("sim/signals/fdm-initialized", func {
    chr_et.stop();
    et.stop();
    props.globals.initNode("instrumentation/clock/indicated-string",0,"STRING");
    props.globals.initNode("instrumentation/clock/elapsed-string",0,"STRING");
    props.globals.initNode("instrumentation/chrono/elapsed-string",0,"STRING");
    props.globals.initNode("instrumentation/clock/display-string",0,"STRING");
    props.globals.initNode("instrumentation/clock/et-selector",1,"INT");
	props.globals.initNode("instrumentation/clock/utc-selector",0,"INT");
    props.globals.initNode("instrumentation/clock/set-knob",0,"INT");
    props.globals.initNode("instrumentation/chrono/chrono-reset",2,"INT");
    props.globals.initNode("instrumentation/clock/et-hr",0,"INT");
    props.globals.initNode("instrumentation/clock/et-min",0,"INT");
    props.globals.initNode("instrumentation/chrono/et-hr",0,"INT");
    props.globals.initNode("instrumentation/chrono/et-min",0,"INT");
    start_loop.start();
});

setlistener("instrumentation/chrono/chrono-reset", func(chrono){
    var tmp = chrono.getValue();
    if(tmp == 2){
        chr_et.stop();
        chr_et.reset();
        #setprop("instrumentation/chrono/chrono-reset", 0);
    }elsif(tmp==1){
        chr_et.stop();
    }elsif(tmp==0){
        chr_et.start();
    }
},0,0);

setlistener("instrumentation/clock/et-selector", func(clock_et){
    var tmp1 = clock_et.getValue();
    if(tmp1 == 2){
        et.reset();
        setprop("instrumentation/clock/et-selector", 1);
    }elsif(tmp1==1){
        et.stop();
    }elsif(tmp1==0){
        et.start();
    }
},0,0);


var start_loop = maketimer(0.1, func {
    var UTC_date = sprintf("%02d %02d %02d", getprop("sim/time/utc/month"), getprop("sim/time/utc/day"), substr(sprintf("%2d", getprop("sim/time/utc/year")),1,2));
    setprop("instrumentation/clock/utc-date", UTC_date);
    var UTC_date1 = sprintf("%02d %02d", getprop("sim/time/utc/month"), getprop("sim/time/utc/day"));
    var UTC_date2 = substr(sprintf(" %2d", getprop("sim/time/utc/year")),1,2);
    var clock2_2 = substr(getprop("instrumentation/clock/indicated-string"),6,2);
    setprop("instrumentation/clock/indicated-seconds", sprintf(":%02d", clock2_2));
    setprop("instrumentation/clock/utc-date", UTC_date);
    setprop("instrumentation/clock/utc-date1", UTC_date1);
    setprop("instrumentation/clock/utc-date2", UTC_date2);
    if (getprop("instrumentation/clock/set-knob")=="")
    {
   		setprop("instrumentation/clock/set-knob", 0); 
    };
    if (getprop("instrumentation/clock/utc-selector")=="")
    {
   		setprop("instrumentation/clock/utc-selector", 0);
    };

	# ET clock
	var et_tmp = getprop("instrumentation/clock/elapsetime-sec");
    var et_min = int(et_tmp * 0.0166666666667);
    var et_hr  = int(et_min * 0.0166666666667);
    et_min = et_min - (et_hr * 60);
    et_tmp = et_hr * 100 + et_min;
    setprop("instrumentation/clock/elapsed-string",et_tmp);
    et_tmp = int(getprop("instrumentation/clock/elapsetime-sec") * 0.0166666666667);
    et_hr = int(et_tmp * 0.0166666666667);
    et_min = et_tmp - (et_hr * 60);
    setprop("instrumentation/clock/et-hr",et_hr);
    setprop("instrumentation/clock/et-min",et_min);
    et_tmp = sprintf("%02d:%02d", et_hr, et_min);
    setprop("instrumentation/clock/elapsed-string", et_tmp);

    # Chrono
    var et_tmp = getprop("instrumentation/chrono/elapsetime-sec");
    var et_min = int(et_tmp * 0.0166666666667);
    var et_hr  = int(et_min * 0.0166666666667);
    et_min = et_min - (et_hr * 60);
    et_sec = int(et_tmp) - (et_min * 60) - (et_hr * 3600);
    et_tmp = et_hr * 100 + et_min + et_sec;
    setprop("instrumentation/chrono/elapsed-string",et_tmp);
    et_tmp = int(getprop("instrumentation/chrono/elapsetime-sec") * 0.0166666666667);
    et_hr = int(et_tmp * 0.0166666666667);
    et_min = et_tmp - (et_hr * 60);
    setprop("instrumentation/chrono/et-hr",et_hr);
    setprop("instrumentation/chrono/et-min",et_min);
    setprop("instrumentation/chrono/et-min",et_sec);
    et_tmp = sprintf("%02d %02d", et_min, et_sec);
    setprop("instrumentation/chrono/elapsed-string", et_tmp);
});
