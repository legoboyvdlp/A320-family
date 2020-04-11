# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2019 Joshua Davidson (Octal450)

var version = getprop("sim/version/flightgear");
var v = split(".", version);
version = num(v[0]~"."~v[1]);

setlistener("/nasal/canvas/loaded", func() {

	####### LOAD FILES #######
	#print("loading files");
	(func {
	 var aircraft_root = getprop("/sim/aircraft-dir");

	var load = func(file, name) {
		#print("Loading ..." ~ file);
		if (name == nil)
			var name = split("/", file)[-1];
		if (substr(name, size(name)-4) == ".draw")
		name = substr(name, 0, size(name)-5);
		#print("reading file");
		var code = io.readfile(file);
		#print("compiling file");
		# This segfaults for some reason:
		#var code = call(compile, [code], var err=[]);
		var code = call(func compile(code, file), [code], var err=[]);
		if (size(err)) {
			#print("handling error");
			if (substr(err[0], 0, 12) == "Parse error:") { # hack around Nasal feature
				var e = split(" at line ", err[0]);
				if (size(e) == 2)
				err[0] = string.join("", [e[0], "\n  at ", file, ", line ", e[1], "\n "]);
			}
			for (var i = 1; (var c = caller(i)) != nil; i += 1)
			err ~= subvec(c, 2, 2);
			debug.printerror(err);
			return;
		}
		#print("calling code");
		call(code, nil, nil, var hash = {});
		#debug.dump(keys(hash));
		return hash;
	};

	var load_deps = func(name) {
		print("Loading MapStructure Layer: "~ name);
		load(aircraft_root~"/Models/Instruments/ND/map/"~name~".lcontroller",  name);
		load(aircraft_root~"/Models/Instruments/ND/map/"~name~".symbol", name);
		if(version < 3.2)
			load(aircraft_root~"/Models/Instruments/ND/map/"~name~".scontroller", name);
	}

	#foreach( var name; ["APS","ALT-profile","SPD-profile","RTE","WPT","DECEL","NDB"] )
	#load_deps( name );
	var dep_names = [
		# With these extensions, in this order:
		"lcontroller",
		"symbol",
		"scontroller",
		"controller",
	];
	var map_root = aircraft_root~"/Models/Instruments/ND/canvas/map/";
	var files = directory(map_root);
	var deps = {};
	foreach (var d; dep_names) deps[d] = [];
	foreach(var f; files){
		var ext = size(var s=split(".", f)) > 1 ? s[-1] : nil;
		foreach (var d; dep_names) {
			if (ext == d) {
				append(deps[d], f);
				break
			}
		}
	}

	foreach (var d; dep_names) {
		foreach (var f; deps[d]) {
			var name = split(".", f)[0];
			load(map_root~f, name);
		}
	}

})();


}, 1);