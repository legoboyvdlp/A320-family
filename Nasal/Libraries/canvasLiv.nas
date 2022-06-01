# res2str
# =============================================================================
# Helper function for canvas_livery
# Returns the Nk version for the given resolution
var res2str = func(resolution) {
	if (math.mod(resolution, 1024) == 0)
	{
		return (resolution / 1024) ~ "k";
	}
	print("ERROR: Non 1024 based resolution: " ~ resolution);
	return nil;
};



# findTexByRes 
# =============================================================================
# Helper function for canvas_livery
# Looks for the largest available livery texture in resolution equal or smaller
# than the given limit
var findTexByRes = func(path, file, maxRes) {
	res = maxRes;
	checkFile = os.path.new(getprop("/sim/aircraft-dir") ~ "/" ~ path);
	while (res >= 1024) {
		checkFile.set(getprop("/sim/aircraft-dir") ~ "/" ~ path ~ "/" ~ res2str(res) ~ "/" ~ file);
		if (checkFile.isFile()) {
			return res2str(res);
		}
		res = res / 2;
	}
	print("No suiting texture " ~ file ~ " found in " ~ path ~ " and resolution " ~ maxRes ~ " or lower");
	return nil;
};


# =============================================================================
# Listener to update the canvas size, when the property gets changed

var livery_res_update = setlistener("/sim/model/livery/max-resolution", func {
	livery_update.setResolution(getprop("/sim/model/livery/max-resolution"));
	print("INIT: RES: " ~ resolution);
	# TODO mp liveries
}, 0, 0);


# canvas_livery
# =============================================================================
# Class for Canvas based liveries
#
var canvas_livery = {
	init: func(dir, nameprop = "sim/model/livery/name", sortprop = nil) {
		var m = { parents: [canvas_livery, gui.OverlaySelector.new("Select Livery", dir, nameprop,
				sortprop, "sim/model/livery/file")] };
		m.dialog = m.parents[1];
		m.liveriesdir = dir;
		m.resolution = getprop("/sim/model/livery/max-resolution");
		m.targets = {};
		return m;
	},
	setResolution: func(resolution) {
		maxSupportedRes = getprop("/sim/rendering/max-texture-size");
		if (resolution > maxSupportedRes) {
			resolution = maxSupportedRes;
			me.targets[name].resolution = maxSupportedRes;
		}
	#	foreach (var target, me.targets)
	#	{
	#		target.resolution = resolution;
	#		target.canvas.del();
	#	}
	},
	createTarget: func(name, objects, property, defLiv) {
		me.targets[name] = {
			canvas: nil,
			layers: {},
			layersHidden: {},
			groups: {},
			listener: nil,
			defaultLiv: defLiv,
			resolution: getprop("/sim/model/livery/max-resolution"),
		};
		var resolution = getprop("/sim/model/livery/max-resolution");
		me.targets[name].resolution = resolution;
		# Make sure we never load too large textures
		maxSupportedRes = getprop("/sim/rendering/max-texture-size");
		if (resolution > maxSupportedRes) {
			resolution = maxSupportedRes;
			me.targets[name].resolution = maxSupportedRes;
		}
		var (major, minor, patch) = split(".", getprop("/sim/version/flightgear"));
		if (num(major) == 2020 and num(minor) < 4) {
			me.targets[name].canvas = canvas.new({
				"name": name,
				"size": [resolution, resolution],
				"view": [resolution, resolution],
				"mipmapping": 1,
			});
		} else {
			me.targets[name].canvas = canvas.new({
				"name": name,
				"size": [resolution, resolution],
				"view": [resolution, resolution],
				"mipmapping": 1,
				"anisotropy": 32.0
			});
		}
		foreach (var object; objects) {
			me.targets[name].canvas.addPlacement({"node": object});
		}
		me.targets[name].groups["base"] = me.targets[name].canvas.createGroup("base");
		var livery = "";
		resStr = findTexByRes(me.liveriesdir, getprop(property), resolution);
		if (resStr == nil) {
			livery = me.targets[name].defaultLiv;
		}
		else
		{
			livery = me.liveriesdir ~ "/" ~ resStr ~ "/" ~ getprop(property)
		}
		me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(livery).setSize(resolution,resolution);
		me.targets[name].layersHidden["base"] = 0;
		me.targets[name].listener = setlistener(property, func(property) {
			resStr = findTexByRes(me.liveriesdir, property.getValue(), resolution);
			if (resStr == nil) {
				return nil;
			}
			me.targets[name].groups["base"].removeAllChildren();
			me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(me.liveriesdir ~ "/" ~ resStr ~ "/" ~ property.getValue()).setSize(resolution,resolution);
		});
	},
	addLayer: func(target, name, file) {
		me.targets[target].groups[name] = me.targets[target].canvas.createGroup(name);
		me.targets[target].layers[name] = me.targets[target].groups[name].createChild("image").setFile(file).setSize(me.targets[target].resolution, me.targets[target].resolution);
		me.targets[target].layersHidden[name] = 0;
		},
	removeLayer: func(target, name) {
		me.targets[target].layers[name].removeAllChildren();
		me.targets[target].layers[name] = nil;
		me.targets[target].layersHidden[name] = nil;
	},
	showLayer: func(target, name) {
		me.targets[target].layers[name].show();
		me.targets[target].layersHidden[name] = 0;
	},
	hideLayer: func(target, name) {
		me.targets[target].layers[name].hide();
		me.targets[target].layersHidden[name] = 1;
	},
};



# canvas_livery_update
# =============================================================================
# Class for Canvas based liveries
#
var canvas_livery_update = {
	init: func(liveriesdir, module_id, interval = 10.01, callback = nil) {
		var m = { parents: [canvas_livery_update, overlay_update.new()] };
		m.parents[1].add(liveriesdir, "sim/model/livery/file", callback);
		m.parents[1].interval = interval;
		m.liveriesdir = liveriesdir;
		m.resolution = getprop("/sim/model/livery/max-resolution");
		m.targets = {};
		m.module_id = module_id;
		m.rplayer = rplayer;
		return m;
	},
	setResolution: func(resolution) {
		# TODO
	},
	createTarget: func(name, objects, property) {
		me.targets[name] = {
			canvas: nil,
			layers: {},
			groups: {},
			listener: nil,
			defaultLiv: defLiv,
			resolution: getprop("/sim/model/livery/max-resolution"),
		};
		var resolution = getprop("/sim/model/livery/max-resolution");
		me.targets[name].resolution = resolution;
		# Make sure we never load too large textures
		maxSupportedRes = getprop("/sim/rendering/max-texture-size");
		if (resolution > maxSupportedRes) {
			resolution = maxSupportedRes;
			me.targets[name].resolution = maxSupportedRes;
		}
		var (major, minor, patch) = split(".", getprop("/sim/version/flightgear"));
		if (num(major) == 2020 and num(minor) < 4) {
			me.targets[name].canvas = canvas.new({
				"name": name,
				"size": [resolution, resolution],
				"view": [resolution, resolution],
				"mipmapping": 1,
			});
		} else {
			me.targets[name].canvas = canvas.new({
				"name": name,
				"size": [resolution, resolution],
				"view": [resolution, resolution],
				"mipmapping": 1,
				"anisotropy": 32.0
			});
		}
		foreach (var object; objects) {
			me.targets[name].canvas.addPlacement({"module-id": me.module_id, "type": "scenery-object", "node": object});
		}
		me.targets[name].groups["base"] = me.targets[name].canvas.createGroup("base");
		var livery = "";
		resStr = findTexByRes(me.liveriesdir, getprop(property), resolution);
		if (resStr == nil) {
			livery = me.targets[name].defaultLiv;
		}
		else
		{
			livery = me.liveriesdir ~ "/" ~ resStr ~ "/" ~ getprop(property)
		}
		me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(me.liveriesdir ~ "/" ~ resStr ~ "/" ~ getprop(property)).setSize(resolution,resolution);
		me.targets[name].listener = setlistener(me.rplayer.getNode(property, 1).getPath(), func(property) {
			resStr = findTexByRes(me.liveriesdir, property.getValue(), resolution);
			if (resStr == nil) {
				return nil;
			}
			me.targets[name].groups["base"].removeAllChildren();
			me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(me.liveriesdir ~ "/" ~ resStr ~ "/" ~ property.getValue()).setSize(resolution,resolution);
		});
	},
	addLayer: func(target, name, file) {
		me.targets[target].groups[name] = me.targets[target].canvas.createGroup(name);
		me.targets[target].layers[name] = me.targets[target].groups[name].createChild("image").setFile(file).setSize(me.targets[target].resolution, me.targets[target].resolution);
		},
	removeLayer: func(target, name) {
		me.targets[target].layers[name].removeAllChildren();
		me.targets[target].layers[name] = nil;
	},
	showLayer: func(target, name) {
		me.targets[target].layers[name].show();
	},
	hideLayer: func(target, name) {
		me.targets[target].layers[name].hide();
	},
	stop: func {
		me.parents[1].stop();
	},
};
