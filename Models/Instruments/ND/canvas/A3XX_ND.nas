# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2019 Joshua Davidson (Octal450)

var get_local_path = func(file){
    var aircraft_dir = split("/", getprop("/sim/aircraft-dir"))[-1];
    return "Aircraft/" ~ aircraft_dir ~ "/Models/Instruments/ND/canvas/"~ file;
};

var version = getprop("sim/version/flightgear");
var v = split(".", version);
version = num(v[0]~"."~v[1]);

var SymbolLayer = canvas.SymbolLayer;
var SingleSymbolLayer = canvas.SingleSymbolLayer;
var MultiSymbolLayer = canvas.MultiSymbolLayer;
var NavaidSymbolLayer = canvas.NavaidSymbolLayer;
var Symbol = canvas.Symbol;
var Group = canvas.Group;
var Path = canvas.Path;
var DotSym = canvas.DotSym;
var Map = canvas.Map;
var SVGSymbol = canvas.SVGSymbol;
var LineSymbol = canvas.LineSymbol;
var StyleableCacheable = canvas.StyleableCacheable;
var SymbolCache32x32 = canvas.SymbolCache32x32;
var SymbolCache = canvas.SymbolCache;
var Text = canvas.Text;

io.include("ND_config.nas");
io.include("framework/canvas.nas");
io.include("framework/navdisplay.nas");
io.include("framework/MapDrivers.nas");
io.include("loaders.nas");
io.include("helpers.nas");
io.include("style.nas");
