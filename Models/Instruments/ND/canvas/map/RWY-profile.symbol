# See: http://wiki.flightgear.org/MapStructure

# Class things:
var name = 'RWY-profile';
var parents = [DotSym];
var __self__ = caller(0)[0];
DotSym.makeinstance( name, __self__ );

var element_type = "group";

var style = { # style to use by default
    zoom: 20,
    color: [1,1,1],
    center_line_len: 0.75,
    line_width: 3
};

SymbolLayer.get(name).df_style = style;
#var already_drawn = 0;

var init = func {
    #if(me.already_drawn) return;
    var lat = me.model.lat;
    var lon = me.model.lon;
    var rwyhdg = me.model.heading;
    var width = me.model.width;
    var length = me.model.length;
    var group = me.element;
    var ctr_len = length * me.getStyle('center_line_len', 0.75);
    var crds = [];
    var coord = geo.Coord.new();
    width = width * me.getStyle('zoom', 20); # Else rwy is too thin to be visible
    var line_w = me.getStyle('line_width', 3);
    var color = me.getStyle('color', [1,1,1]);
    coord.set_latlon(lat, lon);
    coord.apply_course_distance(rwyhdg, -(ctr_len / 2));
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg, (ctr_len));
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    icon_rwy = group.createChild("path", "rwy-cl")
    .setStrokeLineWidth(line_w)
    .setDataGeo([2,4],crds)
    .setColor(color);
    #.setStrokeDashArray([10, 20, 10, 20, 10]);
    #icon_rwy.hide();
    var crds = [];
    coord.set_latlon(lat, lon);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg + 90, width/2);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg, length);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    icon_rwy = group.createChild("path", "rwy")
    .setStrokeLineWidth(line_w)
    .setDataGeo([2,4,4],crds)
    .setColor(color);
    var crds = [];
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg - 90, width);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg, -length);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    coord.apply_course_distance(rwyhdg + 90, width / 2);
    append(crds,"N"~coord.lat());
    append(crds,"E"~coord.lon());
    icon_rwy = group.createChild("path", "rwy")
    .setStrokeLineWidth(line_w)
    .setDataGeo([2,4,4,4],crds)
    .setColor(color);
};

var draw = func{}


#var update = func() {
#    if (me.controller != nil) {
#        if (!me.controller.update(me, me.model)) return;
#        elsif (!me.controller.isVisible(me.model)) {
#            me.element.hide();
#            return;
#        }
#    } else
#        me.element.show();
#    me.draw();
#}
