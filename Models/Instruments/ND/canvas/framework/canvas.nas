# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2020 Josh Davidson (Octal450)

var assert_m = canvas.assert_m;

# --------------------------------
# From FGDATA/Nasal/canvas/api.nas
# --------------------------------

# Recursively get all children of class specified by first param
canvas.Group.getChildrenOfType = func(type, array = nil){
    var children = array;
    if(children == nil)
        children = [];
    var my_children = me.getChildren();
    if(typeof(type) != "vector")
        type = [type];
    foreach(var c; my_children){
        foreach(var t; type){
            if(isa(c, t)){
                append(children, c);
            }
        }
        if(isa(c, canvas.Group)){
            c.getChildrenOfType(type, children);
        }
    }
    return children;
};

    # Set color to children of type Path and Text. It is possible to optionally
    # specify which types of children should be affected by passing a vector as
    # the last agrument, ie. my_group.setColor(1,1,1,[Path]);
canvas.Group.setColor = func(){
    var color = arg;
    var types = [Path, Text];
    var arg_c = size(color);
    if(arg_c > 1 and typeof(color[-1]) == "vector"){
        types = color[-1];
        color = subvec(color, 0, arg_c - 1);
    }
    var children = me.getChildrenOfType(types);
    if(typeof(color) == "vector"){
        var first = color[0];
        if(typeof(first) == "vector")
            color = first;
    }
    foreach(var c; children)
    c.setColor(color);
};

canvas.Map.addLayer =  func(factory, type_arg=nil, priority=nil, style=nil, opts=nil, visible=1)
{
    if(contains(me.layers, type_arg))
        logprint("warn", "addLayer() warning: overwriting existing layer:", type_arg);
    var options = opts;
    # Argument handling

    if (type_arg != nil) {
        var layer = factory.new(type:type_arg, group:me, map:me, style:style, options:options, visible:visible);
        var type = factory.get(type_arg);
        var key = type_arg;
    } else {
        var layer = factory.new(group:me, map:me, style:style, options:options, visible:visible);
        var type = factory;
        var key = factory.type;
    }
    me.layers[type_arg] = layer;

    if (priority == nil)
        priority = type.df_priority;
    if (priority != nil)
        layer.group.setInt("z-index", priority);

    return layer; # return new layer to caller() so that we can directly work with it, i.e. to register event handlers (panning/zooming)
};

# -----------------------------------------
# From FGDATA/Nasal/canvas/MapStructure.nas
# -----------------------------------------

var opt_member = func(h,k) {
    if (contains(h, k)) return h[k];
    if (contains(h, "parents")) {
        var _=h.parents;
        for (var i=0;i<size(_);i+=1){
            var v = opt_member(_[i], k);
            if (v != nil) return v;
        }
    }
    return nil;
};

# Symbol

canvas.Symbol.formattedString = func(frmt, model_props){
    if(me.model == nil) return frmt;
    var args = [];
    foreach(var prop; model_props){
        if(contains(me.model, prop)){
            var val = me.model[prop];
            var tp = typeof(val);
            if(tp != "scalar"){
                val = "";
                #logprint("warn", "formattedString: invalid type for "~prop~" (" ~ tp ~ ")");
            } else {
                append(args, val);
            }
        }
    }
    return call(sprintf, [frmt] ~ args);
};

canvas.Symbol.getOption = func(name,  default = nil){
    var opt = me.options;
    if(opt == nil)
        opt = me.layer.options;
    if(opt == nil) return default;
    var val = opt_member(opt, name);
    if(val == nil) return default;
    return val;
};

canvas.Symbol.getStyle = func(name, default = nil){
    var st = me.style;
    if(st == nil)
        st = me.layer.style;
    if(st == nil) return default;
    var val = opt_member(st, name);
    if(typeof(val) == "func"){
        val = (call(val,[],me));
    }
    if(val == nil) return default;
    return val;
};

canvas.Symbol.getLabelFromModel = func(default_val = nil){
    if(me.model == nil) return default_val;
    if(default_val == nil and contains(me.model, "id"))
        default_val = me.model.id;
    var label_content = me.getOption("label_content");
    if(label_content == nil) return default_val;
    if(typeof(label_content) == "scalar")
        label_content = [label_content];
    var format_s = me.getOption("label_format");
    var label = "";
    if(format_s == nil){
        format_s = "%s";
    }
    return me.formattedString(format_s, label_content);
};

canvas.Symbol.callback = func(name, args...){
    name = name ~"_callback";
    var f = me.getOption(name);
    if(typeof(f) == "func"){
        return call(f, args, me);
    }
};

# DotSym

canvas.DotSym.update = func() {
    if (me.controller != nil) {
        if (!me.controller.update(me, me.model)) return;
        elsif (!me.controller.isVisible(me.model)) {
            me.element.hide();
            return;
        }
    } else
        me.element.show();
    me.draw();
    if(me.getOption("disable_position", 0)) return; # << CHECK FOR OPTION "disable_position"
    var pos = me.controller.getpos(me.model);
    if (size(pos) == 2)
        pos~=[nil]; # fall through
    if (size(pos) == 3)
        var (lat,lon,rotation) = pos;
    else __die("DotSym.update(): bad position: "~debug.dump(pos));
    # print(me.model.id, ": Position lat/lon: ", lat, "/", lon);
    me.element.setGeoPosition(lat,lon);
    if (rotation != nil)
        me.element.setRotation(rotation);
};

# SVGSymbol

canvas.SVGSymbol.init = func() {
    me.callback("init_before");
    var opt_path = me.getStyle("svg_path");
    if(opt_path != nil)
        me.svg_path = opt_path;
    if (!me.cacheable) {
        if(me.svg_path != nil and me.svg_path != "")
            canvas.parsesvg(me.element, me.svg_path);
        # hack:
        if (var scale = me.layer.style["scale_factor"])
            me.element.setScale(scale);
        if ((var transl = me.layer.style["translate"]) != nil)
            me.element.setTranslation(transl);
    } else {
        __die("cacheable not implemented yet!");
    }
    me.callback("init_after");
    me.draw();
};

canvas.SVGSymbol.draw = func{
    me.callback("draw");
};

# SymbolLayer

canvas.SymbolLayer._new = func(m, style, controller, options) {
    # print("SymbolLayer setup options:", m.options!=nil);
    m.style = default_hash(style, m.df_style);
    m.options = default_hash(options, m.df_options);

    if (controller == nil)
        controller = m.df_controller;
    assert_m(controller, "parents");
    if (controller.parents[0] == SymbolLayer.Controller)
        controller = controller.new(m);
    assert_m(controller, "parents");
    assert_m(controller.parents[0], "parents");
    if (controller.parents[0].parents[0] != SymbolLayer.Controller)
        __die("MultiSymbolLayer: OOP error");
    if(options != nil){ # << CHECK FOR CONFIGURABLE LISTENERS
        var listeners = opt_member(controller, "listeners");
        var listen = opt_member(options, "listen");
        if (listen != nil and listeners != nil){
            var listen_tp = typeof(listen);
            if(listen_tp != "vector" and listen_tp != "scalar")
                __die("Options 'listen' cannot be a "~ listen_tp);
            if(typeof(listen) == "scalar")
                listen = [listen];
            foreach(var node_name; listen){
                var node = opt_member(options, node_name);
                if(node == nil)
                    node = node_name;
                append(controller.listeners,
                       setlistener(node, func call(m.update,[],m),0,0));
            }
        }
    }
    m.controller = controller;
};

# LineSymbol

canvas.LineSymbol.new = func(group, layer, model, controller=nil) {
	if (me == nil) __die("Need me reference for LineSymbol.new()");
	if (typeof(model) != "vector") {
		if(typeof(model) == "hash"){
			if(!contains(model, "path"))
			canvas.__die("LineSymbol.new(): model hash requires path");
		}
		else canvas.__die("LineSymbol.new(): need a vector of points or a hash");
	}
	var m = {
		parents: [me],
		group: group,
		layer: layer,
		model: model,
		controller: controller == nil ? me.df_controller : controller,
		element: group.createChild(
			"path", me.element_id
		),
	};
	append(m.parents, m.element);
	canvas.Symbol._new(m);

	m.init();
	return m;
};
	# Non-static:
canvas.LineSymbol.draw = func() {
	me.callback("draw_before");
	if (!me.needs_update) return;
	#logprint(_MP_dbg_lvl, "redrawing a LineSymbol "~me.layer.type);
	me.element.reset();
	var cmds = [];
	var coords = [];
	var cmd = canvas.Path.VG_MOVE_TO;
	var path = me.model;
	if(typeof(path) == "hash"){
		path = me.model.path;
		if(path == nil) 
			canvas.__die("LineSymbol model requires a 'path' member (vector)");
	}
	foreach (var m; path) {
		if(size(keys(m)) >= 2){
			var (lat,lon) = me.controller.getpos(m);
			append(coords,"N"~lat);
			append(coords,"E"~lon);
			append(cmds,cmd); 
			cmd = canvas.Path.VG_LINE_TO;
		} else {
			cmd = canvas.Path.VG_MOVE_TO;
		}
	}
	me.element.setDataGeo(cmds, coords);
	me.element.update(); # this doesn"t help with flickering, it seems
	me.callback("draw_after");
};

