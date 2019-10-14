# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2019 Joshua Davidson (Octal450)

var SymbolPainter = {
    aircraft_dir: nil,
    getOpts: func(opts){
        if(opts == nil) opts = {};
        var defOpts = {id:nil,color:nil,scale:1,create_group:0,update_center:0};
        if(contains(opts, "id"))
        defOpts.id = opts.id;
        if(contains(opts, "color"))
        defOpts.color = opts.color;
        if(contains(opts, "scale"))
        defOpts.scale = opts.scale;
        if(contains(opts, "create_group"))
        defOpts.create_group = opts.create_group;
        if(contains(opts, "update_center"))
        defOpts.update_center = opts.update_center;
        return defOpts;
    },
    getAircraftDir: func(){
        if(me.aircraft_dir == nil)
            me.aircraft_dir = split("/", getprop("/sim/aircraft-dir"))[-1];
        return me.aircraft_dir;
    },
    svgPath: func(file){
        return "Aircraft/" ~ me.getAircraftDir() ~ "/Models/Instruments/ND/canvas/res/"~file;
    },
    drawFIX : func(grp, opts = nil){
        var icon_fix = nil;
        opts = me.getOpts(opts);
        var sym_id = opts.id;
        if(sym_id != nil)
            icon_fix = grp.createChild("path", sym_id);
        else 
            icon_fix = grp.createChild("path");
        var color = opts.color;
        if(color == nil){
            color = {
                r: 0.69,
                g: 0,
                b: 0.39
            };
        }
        var scale = opts.scale;
        if(scale == nil) scale = 0.8;
        icon_fix.moveTo(-10,0)
        .lineTo(0,-17)
        .lineTo(10,0)
        .lineTo(0,17)
        .close()
        .setStrokeLineWidth(3)
        .setColor(color.r,color.g,color.b)
        .setScale(scale,scale);
        return icon_fix;
    },
    drawVOR: func(grp, opts = nil){
        opts = me.getOpts(opts);
        if(opts.create_group){
            var sym_id = opts.id;
            if(sym_id != nil)
                grp = grp.createChild("group", sym_id);
            else 
                grp = grp.createChild("group");
        }
        var svg_path = me.svgPath("airbus_vor.svg");
        canvas.parsesvg(grp, svg_path);
        var scale = opts.scale;
        if(scale == nil) scale = 0.8;
        grp.setScale(scale,scale);
        if(opts.update_center)
            grp.setTranslation(-24 * scale,-24 * scale);
        if(!contains(grp, "setColor")){
            grp.setColor = func {
                var layer1 = grp.getElementById("layer1");
                if(layer1 == nil) return;
                var children = layer1.getChildren();
                foreach(var c; children){
                    if(isa(c, canvas.Path))
                        c.setColor(arg);
                }
            };
        }
        return grp;
    },
    drawNDB: func(grp, opts = nil){
        var icon_ndb = nil;
        opts = me.getOpts(opts);
        var sym_id = opts.id;
        if(sym_id != nil)
            icon_ndb = grp.createChild("path", sym_id);
        else 
            icon_ndb = grp.createChild("path");
        var color = opts.color;
        var color = opts.color;
        if(color == nil){
            color = {
                r: 0.69,
                g: 0,
                b: 0.39
            };
        }
        var scale = opts.scale;
        if(scale == nil) scale = 0.8;
        icon_ndb.moveTo(-15,15)
        .lineTo(0,-15)
        .lineTo(15,15)
        .close()
        .setStrokeLineWidth(3)
        .setColor(color.r,color.g,color.b)
        .setScale(scale,scale);
        return icon_ndb;
    },
    drawAirport: func(grp, opts = nil){
        opts = me.getOpts(opts);
        if(opts.create_group){
            var sym_id = opts.id;
            if(sym_id != nil)
                grp = grp.createChild("group", sym_id);
            else 
                grp = grp.createChild("group");
        }
        var svg_path = me.svgPath("airbus_airport.svg");
        canvas.parsesvg(grp, svg_path);
        var scale = opts.scale;
        if(scale == nil) scale = 0.8;
        grp.setScale(scale,scale);
        if(opts.update_center)
            grp.setTranslation(-24 * scale,-24 * scale);
        return grp;
    },
    draw: func(type, grp, opts = nil){
        if(type == "VOR" or type == "vor")
            return me.drawVOR(grp, opts);
        elsif(type == "NDB" or type == "ndb")
        return me.drawNDB(grp, opts);
        elsif(type == "ARPT" or type == "arpt")
        return me.drawAirport(grp, opts);
        else 
            return me.drawFIX(grp, opts);
    }
};
