# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'ALT-profile';
var parents = [SymbolLayer.Controller];
var __self__ = caller(0)[0];
SymbolLayer.Controller.add(name, __self__);
SymbolLayer.add(name, {
	parents: [MultiSymbolLayer],
	type: name, # Symbol type
	df_controller: __self__, # controller to use by default -- this one
	df_options: { # default configuration options
		fplan_active: "/autopilot/route-manager/active",
		vnav_node: "/autopilot/route-manager/vnav/",
		types: ["tc", "td", "ec", "ed","sc", "sd"],
	}
});
var new = func(layer) {
	var m = {
		parents: [__self__],
		layer: layer,
		map: layer.map,
		listeners: [],
	};
	layer.searcher._equals = func(a,b) a.getName() == b.getName();
	append(m.listeners, setlistener(layer.options.fplan_active,
									func m.layer.update() ));
	m.addVisibilityListener();

	return m;
};
var del = func() {
	foreach (var l; me.listeners)
		removelistener(l);
};

var searchCmd = func {
	var results = [];
	var symNode = props.globals.getNode(me.layer.options.vnav_node);
	if (symNode != nil)
		foreach (var t; me.layer.options.types) {
			var n = symNode.getNode(t);
			if (n != nil)
				append(results, n);
		}
	return results;
}

