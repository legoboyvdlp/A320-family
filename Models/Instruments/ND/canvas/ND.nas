# A3XX ND Canvas

# Copyright (c) 2020 Josh Davidson (Octal450)

io.include("A3XX_ND.nas");

io.include("A3XX_ND_drivers.nas");
canvas.NDStyles["Airbus"].options.defaults.route_driver = A3XXRouteDriver.new();

var ND_1 = nil;
var ND_2 = nil;
var ND_1_test = nil;
var ND_2_test = nil;
var elapsedtime = 0;

# Fetch nodes:
var du1_test = props.globals.getNode("instrumentation/du/du1-test");
var du1_test_time = props.globals.getNode("instrumentation/du/du1-test-time");
var du1_test_amount = props.globals.getNode("instrumentation/du/du1-test-amount");
var du2_test = props.globals.getNode("instrumentation/du/du2-test");
var du2_test_time = props.globals.getNode("instrumentation/du/du2-test-time");
var du2_test_amount = props.globals.getNode("instrumentation/du/du2-test-amount");
var du2_offtime = props.globals.initNode("/instrumentation/du/du2-off-time", 0.0, "DOUBLE");
var du5_test = props.globals.getNode("instrumentation/du/du5-test");
var du5_test_time = props.globals.getNode("instrumentation/du/du5-test-time");
var du5_offtime = props.globals.initNode("/instrumentation/du/du5-off-time", 0.0, "DOUBLE");
var du5_test_amount = props.globals.getNode("instrumentation/du/du5-test-amount");
var du6_test = props.globals.getNode("instrumentation/du/du6-test");
var du6_test_time = props.globals.getNode("instrumentation/du/du6-test-time");
var du6_test_amount = props.globals.getNode("instrumentation/du/du6-test-amount");
var cpt_du_xfr = props.globals.getNode("modes/cpt-du-xfr");
var fo_du_xfr = props.globals.getNode("modes/fo-du-xfr");
var wow0 = props.globals.getNode("gear/gear[0]/wow");

var nd_display = {};

var ND = canvas.NavDisplay;

var myCockpit_switches = {
	"toggle_range": {path: "/inputs/range-nm", value:40, type:"INT"},
	"toggle_weather": {path: "/inputs/wxr", value:0, type:"BOOL"},
	"toggle_airports": {path: "/inputs/arpt", value:0, type:"BOOL"},
	"toggle_ndb": {path: "/inputs/NDB", value:0, type:"BOOL"},
	"toggle_stations": {path: "/inputs/sta", value:0, type:"BOOL"},
	"toggle_vor": {path: "/inputs/VORD", value:0, type:"BOOL"},
	"toggle_dme": {path: "/inputs/DME", value:0, type:"BOOL"},
	"toggle_cstr": {path: "/inputs/CSTR", value:0, type:"BOOL"},
	"toggle_waypoints": {path: "/inputs/wpt", value:0, type:"BOOL"},
	"toggle_position": {path: "/inputs/pos", value:0, type:"BOOL"},
	"toggle_data": {path: "/inputs/data",value:0, type:"BOOL"},
	"toggle_terrain": {path: "/inputs/terr",value:0, type:"BOOL"},
	"toggle_traffic": {path: "/inputs/tfc",value:0, type:"BOOL"},
	"toggle_centered": {path: "/inputs/nd-centered",value:0, type:"BOOL"},
	"toggle_lh_vor_adf": {path: "/input/lh-vor-adf",value:0, type:"INT"},
	"toggle_rh_vor_adf": {path: "/input/rh-vor-adf",value:0, type:"INT"},
	"toggle_display_mode": {path: "/nd/canvas-display-mode", value:"NAV", type:"STRING"},
	"toggle_display_type": {path: "/nd/display-type", value:"LCD", type:"STRING"},
	"toggle_true_north": {path: "/nd/true-north", value:0, type:"BOOL"},
	"toggle_track_heading": {path: "/trk-selected", value:0, type:"BOOL"},
	"toggle_wpt_idx": {path: "/inputs/plan-wpt-index", value: -1, type: "INT"},
	"toggle_plan_loop": {path: "/nd/plan-mode-loop", value: 0, type: "INT"},
	"toggle_weather_live": {path: "/nd/wxr-live-enabled", value: 0, type: "BOOL"},
	"toggle_chrono": {path: "/inputs/CHRONO", value: 0, type: "INT"},
	"toggle_xtrk_error": {path: "/nd/xtrk-error", value: 0, type: "BOOL"},
	"toggle_trk_line": {path: "/nd/trk-line", value: 0, type: "BOOL"},
	"ADIRS3": {path: "/nd/ir-3", value: 0, type: "BOOL"},
};

var canvas_nd_base = {
	init: func(canvas_group, file = nil) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		if (file != nil) {
			canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

			var svg_keys = me.getKeys();
			foreach(var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);
			}
		}
		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	updateDu2: func() {
		var elapsedtime = getprop("sim/time/elapsed-sec");
		if (getprop("systems/electrical/bus/ac-ess-shed") >= 110) {
			if (du2_offtime.getValue() + 3 < elapsedtime) {
				if (wow0.getValue() == 1) {
					if (getprop("systems/acconfig/autoconfig-running") != 1 and du2_test.getValue() != 1) {
						du2_test.setValue(1);
						du2_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du2_test_time.setValue(getprop("sim/time/elapsed-sec"));
					} else if (getprop("systems/acconfig/autoconfig-running") == 1 and du2_test.getValue() != 1) {
						du2_test.setValue(1);
						du2_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du2_test_time.setValue(getprop("sim/time/elapsed-sec") - 30);
					}
				} else {
					du2_test.setValue(1);
					du2_test_amount.setValue(0);
					du2_test_time.setValue(-100);
				}
			}
		} else {
			du2_test.setValue(0);
			du2_offtime.setValue(elapsedtime);
		}
	},
	updateDu5: func() {
		var elapsedtime = getprop("sim/time/elapsed-sec");
		if (getprop("systems/electrical/bus/ac-2") >= 110) {
			if (du5_offtime.getValue() + 3 < elapsedtime) {
				if (wow0.getValue() == 1) {
					if (getprop("systems/acconfig/autoconfig-running") != 1 and du5_test.getValue() != 1) {
						du5_test.setValue(1);
						du5_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du5_test_time.setValue(getprop("sim/time/elapsed-sec"));
					} else if (getprop("systems/acconfig/autoconfig-running") == 1 and du5_test.getValue() != 1) {
						du5_test.setValue(1);
						du5_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du5_test_time.setValue(getprop("sim/time/elapsed-sec") - 30);
					}
				} else {
					du5_test.setValue(1);
					du5_test_amount.setValue(0);
					du5_test_time.setValue(-100);
				}
			}
		} else {
			du5_test.setValue(0);
			du5_offtime.setValue(elapsedtime);
		}
		
	},
	update: func() {
		var elapsedtime = getprop("sim/time/elapsed-sec");
		
		if (getprop("systems/electrical/bus/ac-ess-shed") >= 110 and getprop("controls/lighting/DU/du2") > 0) {
			if (du2_test_time.getValue() + du2_test_amount.getValue() >= elapsedtime and cpt_du_xfr.getValue() != 1) {
				ND_1.page.hide();
				ND_1_test.page.show();
				ND_1_test.update();
			} else if (du1_test_time.getValue() + du1_test_amount.getValue() >= elapsedtime and cpt_du_xfr.getValue() == 1) {
				ND_1.page.hide();
				ND_1_test.page.show();
				ND_1_test.update();
			} else {
				ND_1_test.page.hide();
				ND_1.page.show();
				ND_1.NDCpt.update();
			}
		} else {
			ND_1_test.page.hide();
			ND_1.page.hide();
		}
		if (getprop("systems/electrical/bus/ac-2") >= 110 and getprop("controls/lighting/DU/du5") > 0) {
			if (du5_test_time.getValue() + du5_test_amount.getValue() >= elapsedtime and fo_du_xfr.getValue() != 1) {
				ND_2.page.hide();
				ND_2_test.page.show();
				ND_2_test.update();
			} else if (du6_test_time.getValue() + du6_test_amount.getValue() >= elapsedtime and fo_du_xfr.getValue() == 1) {
				ND_2.page.hide();
				ND_2_test.page.show();
				ND_2_test.update();
			} else {
				ND_2_test.page.hide();
				ND_2.page.show();
				ND_2.NDFo.update();
			}
		} else {
			ND_2_test.page.hide();
			ND_2.page.hide();
		}
	},
};

var canvas_ND_1 = {
	new: func(canvas_group) {
		var m = {parents: [canvas_ND_1, canvas_nd_base]};
		m.init(canvas_group);

		# here we make the ND:
		me.NDCpt = ND.new("instrumentation/efis", myCockpit_switches, "Airbus");
		me.NDCpt.attitude_heading_setting = -1;
		me.NDCpt.adirs_property = props.globals.getNode("/instrumentation/efis[0]/nd/ir-1",1);
		me.NDCpt.newMFD(canvas_group);
		me.NDCpt.update();

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {

	},
};

var canvas_ND_2 = {
	new: func(canvas_group) {
		var m = {parents: [canvas_ND_2, canvas_nd_base]};
		m.init(canvas_group);

		# here we make the ND:
		myCockpit_switches["ADIRS"]= {path: "/nd/ir-2", value: 0, type: "BOOL"};
		me.NDFo = ND.new("instrumentation/efis[1]", myCockpit_switches, "Airbus");
		me.NDFo.attitude_heading_setting = 1;
		me.NDFo.adirs_property = props.globals.getNode("/instrumentation/efis[1]/nd/ir-2",1);
		me.NDFo.newMFD(canvas_group);
		me.NDFo.update();

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {

	},
};

var canvas_ND_1_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_ND_1_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		elapsedtime = getprop("sim/time/elapsed-sec") or 0;
		if ((du2_test_time.getValue() + 1 >= elapsedtime) and getprop("modes/cpt-du-xfr") != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du1_test_time.getValue() + 1 >= elapsedtime) and getprop("modes/cpt-du-xfr") != 0) {
			print(getprop("modes/cpt-du-xfr"));
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_ND_2_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_ND_2_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		elapsedtime = getprop("sim/time/elapsed-sec") or 0;
		if ((du5_test_time.getValue() + 1 >= elapsedtime) and getprop("modes/cpt-du-xfr") != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du6_test_time.getValue() + 1 >= elapsedtime) and getprop("modes/cpt-du-xfr") != 0) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

setlistener("sim/signals/fdm-initialized", func {
	setprop("instrumentation/efis[0]/inputs/plan-wpt-index", -1);
	setprop("instrumentation/efis[1]/inputs/plan-wpt-index", -1);

	nd_display.main = canvas.new({
		"name": "ND1",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	nd_display.right = canvas.new({
		"name": "ND2",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});

	nd_display.main.addPlacement({"node": "ND.screen"});
	nd_display.right.addPlacement({"node": "ND_R.screen"});
	var group_nd1 = nd_display.main.createGroup();
	var group_nd1_test = nd_display.main.createGroup();
	var group_nd2 = nd_display.right.createGroup();
	var group_nd2_test = nd_display.right.createGroup();

	ND_1 = canvas_ND_1.new(group_nd1);
	ND_1_test = canvas_ND_1_test.new(group_nd1_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");
	ND_2 = canvas_ND_2.new(group_nd2);
	ND_2_test = canvas_ND_2_test.new(group_nd2_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");

	setlistener("/instrumentation/efis[0]/inputs/range-nm", func() {
		canvas_nd.ND_1.NDCpt.trafficLayer.camera.range = getprop("/instrumentation/efis[0]/inputs/range-nm");
	}, 1, 0);

	setlistener("/instrumentation/efis[1]/inputs/range-nm", func() {
		canvas_nd.ND_2.NDFo.trafficLayer.camera.range = getprop("/instrumentation/efis[1]/inputs/range-nm");
	}, 1, 0);
	
	setlistener("/instrumentation/efis[0]/inputs/nd-centered", func() {
		canvas_nd.ND_1.NDCpt.trafficLayer.camera.screenRange = getprop("/instrumentation/efis[0]/inputs/nd-centered") ? 436.8545 : 710;
		canvas_nd.ND_1.NDCpt.trafficLayer.camera.screenCY = getprop("/instrumentation/efis[0]/inputs/nd-centered") ? 512 : 850;
	}, 1, 0);

	setlistener("/instrumentation/efis[1]/inputs/nd-centered", func() {
		canvas_nd.ND_2.NDFo.trafficLayer.camera.screenRange = getprop("/instrumentation/efis[1]/inputs/nd-centered") ? 436.8545 : 710;
		canvas_nd.ND_2.NDFo.trafficLayer.camera.screenCY = getprop("/instrumentation/efis[1]/inputs/nd-centered") ? 512 : 850;
	}, 1, 0);
	
	setlistener("/instrumentation/tcas/inputs/mode", func() {
		if (getprop("/instrumentation/efis[1]/nd/canvas-display-mode") != "PLAN") {
			canvas_nd.ND_1.NDCpt.trafficGroup.setVisible(pts.Instrumentation.TCAS.Inputs.mode.getValue() >= 2 ? 1 : 0);
		}
		if (getprop("/instrumentation/efis[1]/nd/canvas-display-mode") != "PLAN") {
			canvas_nd.ND_2.NDFo.trafficGroup.setVisible(pts.Instrumentation.TCAS.Inputs.mode.getValue() >= 2 ? 1 : 0);
		}
	}, 1, 0);

	setlistener("/instrumentation/efis[0]/nd/canvas-display-mode", func() {
		canvas_nd.ND_1.NDCpt.trafficGroup.setVisible(getprop("/instrumentation/efis[0]/nd/canvas-display-mode") == "PLAN" ? 0 : 1);
	}, 1, 0);

	setlistener("/instrumentation/efis[1]/nd/canvas-display-mode", func() {
		canvas_nd.ND_2.NDFo.trafficGroup.setVisible(getprop("/instrumentation/efis[1]/nd/canvas-display-mode") == "PLAN" ? 0 : 1);
	}, 1, 0);
	
	nd_update.start();
	if (getprop("systems/acconfig/options/nd-rate") > 1) {
		rateApply();
	}
});

var rateApply = func {
	nd_update.restart(0.05 * getprop("systems/acconfig/options/nd-rate"));
}

var nd_update = maketimer(0.05, func {
	canvas_nd_base.update();
});

for (i = 0; i < 2; i = i + 1 ) {
	setlistener("/instrumentation/efis["~i~"]/nd/display-mode", func(node) {
		var par = node.getParent().getParent();
		var idx = par.getIndex();
		var canvas_mode = "/instrumentation/efis["~idx~"]/nd/canvas-display-mode";
		var nd_centered = "/instrumentation/efis["~idx~"]/inputs/nd-centered";
		var mode = getprop("instrumentation/efis["~idx~"]/nd/display-mode");
		var cvs_mode = "NAV";
		var centered = 1;
		if (mode == "ILS") {
			cvs_mode = "APP";
		}
		else if (mode == "VOR") {
			cvs_mode = "VOR";
		}
		else if (mode == "NAV"){
			cvs_mode = "MAP";
		}
		else if (mode == "ARC"){
			cvs_mode = "MAP";
			centered = 0;
		}
		else if (mode == "PLAN"){
			cvs_mode = "PLAN";
		}
		setprop(canvas_mode, cvs_mode);
		setprop(nd_centered, centered);
	});
}

setlistener("/instrumentation/efis[0]/nd/terrain-on-nd", func{
	var terr_on_hd = getprop("instrumentation/efis[0]/nd/terrain-on-nd");
	var alpha = 1;
	if (terr_on_hd) {
		alpha = 0.5;
	}
	nd_display.main.setColorBackground(0,0,0,alpha);
});

setlistener("/flight-management/control/capture-leg", func(n) {
	var capture_leg = n.getValue();
	setprop("instrumentation/efis[0]/nd/xtrk-error", capture_leg);
	setprop("instrumentation/efis[1]/nd/xtrk-error", capture_leg);
	setprop("instrumentation/efis[0]/nd/trk-line", capture_leg);
	setprop("instrumentation/efis[1]/nd/trk-line", capture_leg);
}, 0, 0);

var showNd = func(nd = nil) {
	if (nd == nil) nd = "main";
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(nd_display[nd]);
}

setlistener("/systems/electrical/bus/ac-ess-shed", func() {
	canvas_nd_base.updateDu2();
}, 0, 0);

setlistener("/systems/electrical/bus/ac-2", func() {
	canvas_nd_base.updateDu5();
}, 0, 0);
