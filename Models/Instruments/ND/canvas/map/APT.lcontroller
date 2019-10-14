# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'APT';
var parents = [SymbolLayer.Controller];
var __self__ = caller(0)[0];
SymbolLayer.Controller.add(name, __self__);
SymbolLayer.add(name, {
	parents: [MultiSymbolLayer],
	type: name, # Symbol type
	df_controller: __self__, # controller to use by default -- this one
	df_style: {
		line_width: 3,
		scale_factor: 1,
		debug: 1,
		color_default: [0,0.6,0.85],
		label_font_color:[0,0.6,0.85],
		label_font_size: 28,
		text_offset: [17,35],
		svg_path: nil
	},

});
var a_instance = nil;
var new = func(layer) {
	var m = {
		parents: [__self__],
		layer: layer,
		map: layer.map,
		listeners: [],
	};
	m.addVisibilityListener();

	return m;
};
var del = func() {
	#print(name,".lcontroller.del()");
	foreach (var l; me.listeners)
		removelistener(l);
};

var searchCmd = func {
	#print("Running query:", name);
	var range = me.map.getRange();
	if (range == nil) return;
	return positioned.findAirportsWithinRange(me.map.getPosCoord(), range);
};

