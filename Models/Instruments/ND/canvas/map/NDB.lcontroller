# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'NDB';
var parents = [SymbolLayer.Controller];
var __self__ = caller(0)[0];
SymbolLayer.Controller.add(name, __self__);
SymbolLayer.add(name, {
	parents: [NavaidSymbolLayer],
	type: name, # Symbol type
	df_controller: __self__, # controller to use by default -- this one
	df_style: {},
});
var new = func(layer) {
	var m = {
		parents: [__self__],
		layer: layer,
		map: layer.map,
		listeners: [],
		query_type:'ndb',
	};
	m.addVisibilityListener();

	return m;
};
var del = func() {
	foreach (var l; me.listeners)
		removelistener(l);
};

var searchCmd = NavaidSymbolLayer.make('ndb');


