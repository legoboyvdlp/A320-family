# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'APS';
var parents = [SymbolLayer.Controller];
var __self__ = caller(0)[0];
SymbolLayer.Controller.add(name, __self__);
SymbolLayer.add(name, {
	parents: [SingleSymbolLayer],
	type: name, # Symbol type
	df_controller: __self__, # controller to use by default -- this one
	df_style: {},
});
# N.B.: if used, this SymbolLayer should be updated every frame
# by the Map Controller, or as often as the position is changed.
var new = func(layer) {
	var __model = layer.map.getPosCoord();
	#debug.dump(typeof(layer.options));
	if(layer.options != nil and contains(layer.options, 'model'))
		__model = layer.options.model;
	return {
		parents: [__self__],
		_model: __model,
	};
};
var del = func;

