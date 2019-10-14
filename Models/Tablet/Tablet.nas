# IDG Tablet
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var Tablet1 = nil;
var Tablet_1 = nil;

var canvas_tablet_base = {
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
	update: func() {
	
	},
};

var canvas_Tablet_1 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_Tablet_1, canvas_tablet_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
	
	},
};

setlistener("sim/signals/fdm-initialized", func {
	Tablet1 = canvas.new({
		"name": "Tablet1",
		"size": [1920, 1280],
		"view": [1920, 1280],
		"mipmapping": 1
	});
	
	Tablet1.addPlacement({"node": "Tablet.screen"});
	var group_tablet1 = Tablet1.createGroup();

	Tablet_1 = canvas_Tablet_1.new(group_tablet1, "Aircraft/A320-family/Models/Tablet/res/screen.svg");
});

var showTablet = func() {
	var dlg = canvas.Window.new([768, 512], "dialog");
	dlg.setCanvas(Tablet1);
}
