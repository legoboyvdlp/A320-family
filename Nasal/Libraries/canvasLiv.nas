# res2str
# =============================================================================
# Helper function for canvas_livery
# Returns the Nk version for the given resolution
var res2str = func(resolution) {
	if (resolution == 1024) {
		return "1k";
	}
	if (resolution == 2048) {
		return "2k";
	}
	if (resolution == 4096) {
		return "4k";
	}
	if (resolution == 8192) {
		return "8k";
	}
	if (resolution == 16384) {
		return "16k";
	}
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
	logprint(LOG_WARN, "No suiting texture found", me.path);
	return nil;
};



# canvas_livery
# =============================================================================
# Class for Canvas based liveries
#
var canvas_livery = {
	init: func(dir, nameprop = "sim/model/livery/name", sortprop = nil, resolution=4096) {
		var m = { parents: [canvas_livery, gui.OverlaySelector.new("Select Livery", dir, nameprop,
				sortprop, "sim/model/livery/file")] };
		m.dialog = m.parents[1];
		m.liveriesdir = dir;
		m.resolution = resolution;
		m.targets = {};
		return m;
	},
	setResolution: func(resolution) {
	},
	createTarget: func(name, objects, property, resolution=4096) {
		me.targets[name] = {
			canvas: nil,
			layers: {},
			groups: {},
			listener: nil,
			resolution: resolution,
		};
		maxRes = getprop("/sim/model/livery/max-resolution");
		if (resolution > maxRes) {
			resolution = maxRes;
			me.targets[name].resolution = maxRes;
		}
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
		resStr = findTexByRes(me.liveriesdir, getprop(property), resolution);
		if (resStr == nil) {
			return nil;
		}
		me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(me.liveriesdir ~ "/" ~ resStr ~ "/" ~ getprop(property)).setSize(resolution,resolution);
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
};



# canvas_livery_update
# =============================================================================
# Class for Canvas based liveries
#
var canvas_livery_update = {
	init: func(liveriesdir, module_id, interval = 10.01, callback = nil, resolution=4096) {
		var m = { parents: [canvas_livery_update, overlay_update.new()] };
		m.parents[1].add(liveriesdir, "sim/model/livery/file", callback);
		m.parents[1].interval = interval;
		m.liveriesdir = liveriesdir;
		m.resolution = resolution;
		m.targets = {};
		m.module_id = module_id;
		return m;
	},
	setResolution: func(resolution) {
	},
	createTarget: func(name, objects, property, resolution=4096) {
		me.targets[name] = {
			canvas: nil,
			layers: {},
			groups: {},
			listener: nil,
			resolution: resolution,
		};
		maxRes = getprop("/sim/model/livery/max-resolution");
		if (resolution > maxRes) {
			resolution = maxRes;
			me.targets[name].resolution = maxRes;
		}
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
		resStr = findTexByRes(me.liveriesdir, getprop(property), resolution);
		if (resStr == nil) {
			return nil;
		}
		me.targets[name].layers["base"] = me.targets[name].groups["base"].createChild("image").setFile(me.liveriesdir ~ "/" ~ resStr ~ "/" ~ getprop(property)).setSize(resolution,resolution);
		me.targets[name].listener = setlistener("/ai/models/multiplayer[" ~ me.module_id ~ "]/" ~ property, func(property) {
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
