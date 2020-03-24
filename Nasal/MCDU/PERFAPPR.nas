# Copyright (c) 2020 Matthew Maring (hayden2000)

# APPR PERF
var dest_qnh = props.globals.getNode("FMGC/internal/dest-qnh", 1);
var dest_temp = props.globals.getNode("FMGC/internal/dest-temp", 1);
var dest_mag = props.globals.getNode("FMGC/internal/dest-mag", 1);
var dest_wind = props.globals.getNode("FMGC/internal/dest-wind", 1);
var transAlt = props.globals.getNode("FMGC/internal/trans-alt", 1);
var vapp_speed = props.globals.getNode("FMGC/internal/vapp-speed", 1);
var vapp_speed_set = props.globals.getNode("FMGC/internal/vapp-speed-set", 1);
var f_speed_appr = props.globals.getNode("FMGC/internal/f-speed-appr", 1);
var s_speed_appr = props.globals.getNode("FMGC/internal/s-speed-appr", 1);
var o_speed_appr = props.globals.getNode("FMGC/internal/o-speed-appr", 1);
var vls_speed_appr = props.globals.getNode("FMGC/internal/vls-speed-appr", 1);
var final = props.globals.getNode("FMGC/internal/final", 1);
var mda = props.globals.getNode("FMGC/internal/mda", 1);
var dh = props.globals.getNode("FMGC/internal/dh", 1);
var ldg_config_3_set = props.globals.getNode("FMGC/internal/ldg-config-3-set", 1);
var ldg_config_f_set = props.globals.getNode("FMGC/internal/ldg-config-f-set", 1);

var perfAPPRInput = func(key, i) {
    var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
	    if (scratchpad == "CLR") {
	        setprop("FMGC/internal/dest-qnh", -1);
	        setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else if ((scratchpad >= 25 and scratchpad <= 60) or (scratchpad >= 900 and scratchpad <= 1100)) {
	        # doesn't support accidental temp input yet
			setprop("FMGC/internal/dest-qnh", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L2") {
	    if (scratchpad == "CLR") {
	        setprop("FMGC/internal/dest-temp", -999);
	        setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else if (scratchpad >= -100 and scratchpad < 100) {
			setprop("FMGC/internal/dest-temp", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L3") {
	    var tfs = size(scratchpad);
	    if (scratchpad == "CLR") {
	        setprop("FMGC/internal/dest-mag", -1);
	        setprop("FMGC/internal/dest-wind", -1);
	        setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else if (tfs >= 3 and tfs <= 7 and find("/", scratchpad) != -1) {
	        var weather = split("/", scratchpad);
            var mag = size(weather[0]);
            var wind = size(weather[1]);
            if (mag >= 1 and mag <= 3 and weather[0] >= 1 and weather[0] <= 360 and wind >= 1 and wind <= 3 and weather[1] >= 0 and weather[1] <= 100) {
                setprop("FMGC/internal/dest-mag", weather[0]);
	            setprop("FMGC/internal/dest-wind", weather[1]);
	            setprop("MCDU[" ~ i ~ "]/scratchpad", "");
                fmgc.updateARPT();
            } else {
                notAllowed(i);
            }
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L4") {
	    if (scratchpad == "CLR") {
	        setprop("FMGC/internal/trans-alt", 18000);
	        setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else if (scratchpad >= 0 and scratchpad <= 50000) {
			setprop("FMGC/internal/trans-alt", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L5") {
	    if (scratchpad == "CLR") {
	        if (dest_wind.getValue() < 5) {
                setprop("FMGC/internal/vapp-speed", vls_speed_appr.getValue() + 5);
            } else if (dest_wind.getValue() > 15) {
                setprop("FMGC/internal/vapp-speed", vls_speed_appr.getValue() + 15);
            } else {
                setprop("FMGC/internal/vapp-speed", vls_speed_appr.getValue() + dest_wind.getValue());
            }
            setprop("FMGC/internal/vapp-speed-set", 0);
	        setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else if (scratchpad >= 0 and scratchpad <= 200) {
			setprop("FMGC/internal/vapp-speed", scratchpad);
			setprop("FMGC/internal/vapp-speed-set", 1);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "DES");
	} else if (key == "R4") {
	    if (scratchpad == "" and ldg_config_f_set.getValue() == 1 and ldg_config_3_set.getValue() == 0) {
	        setprop("FMGC/internal/ldg-config-3-set", 1);
	        setprop("FMGC/internal/ldg-config-f-set", 0);
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "R5") {
	    if (scratchpad == "" and ldg_config_3_set.getValue() == 1 and ldg_config_f_set.getValue() == 0) {
	        setprop("FMGC/internal/ldg-config-3-set", 0);
	        setprop("FMGC/internal/ldg-config-f-set", 1);
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "GA");
	}

}