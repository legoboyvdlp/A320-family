#
#
#
var chronometer = aircraft.timer.new("instrumentation/clock/ET-sec",1);
var elapsetime = aircraft.timer.new("instrumentation/clock/elapsetime-sec",1);

setlistener("sim/signals/fdm-initialized", func {
    chronometer.stop();
    props.globals.initNode("instrumentation/clock/ET-display",0,"INT");
    props.globals.initNode("instrumentation/clock/time-display",0,"INT");
    props.globals.initNode("instrumentation/clock/time-knob",0,"INT");
    props.globals.initNode("instrumentation/clock/et-knob",0,"INT");
    props.globals.initNode("instrumentation/clock/set-knob",0,"INT");
    props.globals.initNode("instrumentation/clock/utc_date",0,"STRING");
    #settimer(start_updates,1);
    start_loop();
    #writeSettings();
});

setlistener("instrumentation/clock/et-knob", func(et){
    var tmp = et.getValue();
    if(tmp == -1){
        chronometer.reset();
    }elsif(tmp==0){
        chronometer.stop();
    }elsif(tmp==1){
        chronometer.start();
    }
},0,0);

var start_loop = func {
    var UTC_date = sprintf("%02d %02d %02d", getprop("sim/time/utc/month"), getprop("sim/time/utc/day"), getprop("sim/time/utc/year"));
    var et_tmp = getprop("instrumentation/clock/ET-sec");
    if(et_tmp == 0)
    {
        et_tmp = getprop("instrumentation/clock/elapsetime-sec");
    }
    var et_min = int(et_tmp * 0.0166666666667);
    var et_hr  = int(et_min * 0.0166666666667);
    et_min = et_min - (et_hr * 60);
    et_tmp = et_hr * 100 + et_min;
    setprop("instrumentation/clock/ET-display",et_tmp);
    et_tmp = int(getprop("instrumentation/clock/elapsetime-sec") * 0.0166666666667);
    et_hr = int(et_tmp * 0.0166666666667);
    et_min = et_tmp - (et_hr * 60);
    et_tmp = sprintf("%02d:%02d", et_hr, et_min);
    setprop("instrumentation/clock/elapsed-string", et_tmp);
    setprop("instrumentation/clock/utc_date", UTC_date);
    settimer(update_systems,0);
}
