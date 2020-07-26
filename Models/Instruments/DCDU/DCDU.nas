# A3XX DCDU

# Copyright (c) 2020 Josh Davidson (Octal450)

var DCDU = nil;
var DCDU_display = nil;
var elapsedtime = 0;

# props.nas nodes
var dcdu_rate = props.globals.getNode("/systems/acconfig/options/dcdu-rate", 1);

var canvas_DCDU_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if (systems.ELEC.Bus.dc1.getValue() >= 25 or systems.ELEC.Bus.ac1.getValue() >= 110) {
			DCDU.page.show();
			DCDU.update();
		} else {
			DCDU.page.hide();
		}
	},
};

var canvas_DCDU = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_DCDU, canvas_DCDU_base]};
		m.init(canvas_group, file);
		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		
	}
};

setlistener("sim/signals/fdm-initialized", func {
	DCDU_display = canvas.new({
		"name": "DCDU",
		"size": [765, 512],
		"view": [765, 512],
		"mipmapping": 1
	});
	DCDU_display.addPlacement({"node": "dcduScreenL"});
	DCDU_display.addPlacement({"node": "dcduScreenR"});
	var group_DCDU = DCDU_display.createGroup();
	
	DCDU = canvas_DCDU.new(group_DCDU, "Aircraft/A320-family/Models/Instruments/DCDU/DCDU.svg");
	
	DCDU_update.start();
	if (dcdu_rate.getValue() > 1) {
		rateApply();
	}
});

var rateApply = func {
	DCDU_update.restart(0.05 * dcdu_rate.getValue());
}

var DCDU_update = maketimer(0.05, func {
	canvas_DCDU_base.update();
});

var showDCDU = func {
	var dlg = canvas.Window.new([383, 256], "dialog").set("resize", 1);
	dlg.setCanvas(DCDU_display);
}
