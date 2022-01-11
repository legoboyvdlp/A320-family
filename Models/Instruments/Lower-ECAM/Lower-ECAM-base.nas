# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var du3_lgt = props.globals.getNode("/controls/lighting/DU/du3");
var du3_test = props.globals.initNode("/instrumentation/du/du3-test", 0, "BOOL");
var du3_test_time = props.globals.initNode("/instrumentation/du/du3-test-time", 0.0, "DOUBLE");
var du3_test_amount = props.globals.initNode("/instrumentation/du/du3-test-amount", 0.0, "DOUBLE");
var du3_offtime = props.globals.initNode("/instrumentation/du/du3-off-time", 0.0, "DOUBLE");
var du4_lgt = props.globals.getNode("/controls/lighting/DU/du4", 1);
var du4_test = props.globals.initNode("/instrumentation/du/du4-test", 0, "BOOL");
var du4_test_time = props.globals.initNode("/instrumentation/du/du4-test-time", 0, "DOUBLE");
var du4_test_amount = props.globals.initNode("/instrumentation/du/du4-test-amount", 0, "DOUBLE");
var du4_offtime = props.globals.initNode("/instrumentation/du/du4-off-time", 0.0, "DOUBLE");

var canvas_lowerECAM_base =
{
	init: func() {
		me.canvas = canvas.new({
			"name": "lowerECAM",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1
		});
		me.canvas.addPlacement({"node": "lecam.screen"});
		me.canvas.addPlacement({"node": "uecam.screen2"});
		
		me.font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};
		
		me.test = me.canvas.createGroup();
		
		canvas.parsesvg(me.test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg", {"font-mapper": me.font_mapper} );
		foreach(var key; me.getKeysTest()) {
			me[key] = me.test.getElementById(key);
		};
	},
	getKeysTest: func() {
		return ["Test_white","Test_text"];
	},
	off: 0,
	on: 0,
	powerTransient: func() {
		if (systems.ELEC.Bus.ac2.getValue() >= 110) {
			if (!me.on) {
				if (du4_offtime.getValue() + 3 < pts.Sim.Time.elapsedSec.getValue()) {
					if (pts.Gear.wow[0].getValue()) {
						if (!acconfig.getBoolValue() and !du4_test.getBoolValue()) {
							du4_test.setValue(1);
							du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
							du4_test_time.setValue(pts.Sim.Time.elapsedSec.getValue());
						} else if (acconfig.getBoolValue() and !du4_test.getBoolValue()) {
							du4_test.setValue(1);
							du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
							du4_test_time.setValue(pts.Sim.Time.elapsedSec.getValue() - 30);
						}
					} else {
						du4_test.setValue(1);
						du4_test_amount.setValue(0);
						du4_test_time.setValue(-100);
					}
				}
				me.off = 0;
				me.on = 1;
			}
		} else {
			if (!me.off) {
				du4_test.setValue(0);
				du4_offtime.setValue(pts.Sim.Time.elapsedSec.getValue());
				me.off = 1;
				me.on = 0;
			}
		}
	},
	# Due to weirdness of the parents hash / me reference
	# you need to access it using me.Test_white rather than
	# me["Test_white"]
	updateTest: func(notification) {
		if (du4_test_time.getValue() + 1 >= notification.elapsedTime) {
			me.Test_white.show();
			me.Test_text.hide();
		} else {
			me.Test_white.hide();
			me.Test_text.show();
		}
	},
};

canvas_lowerECAM_base.init();