# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'WPT-airbus';
var parents = [canvas.DotSym];
var __self__ = caller(0)[0];
canvas.DotSym.makeinstance( name, __self__ );

var element_type = "group";

var init = func {
    var name = me.model.name;
    var alt = me.model.alt;
    var spd = me.model.spd;
    var wp_group = me.element;
    me.alt_path = nil;

    var colors = [
        'wp_color',
        'current_wp_color',
        'constraint_color',
        'active_constraint_color',
        'missed_constraint_color'
    ];
    foreach(col; colors){
        me[col] = me.getStyle(col, me.getOption(col));
    }

    var idLen = size(me.model.id);
    var draw_sym = nil;
    var navtype = me.model.navtype;
    if (navtype == nil) navtype = 'fix';
    if(navtype == 'airport')
        draw_sym = me.options.airport_symbol;
    elsif(navtype == 'vor')
        draw_sym = me.options.vor_symbol;
    elsif(navtype == 'ndb')
        draw_sym = me.options.ndb_symbol;
    else
        draw_sym = me.options.fix_symbol;
    me.wp_sym = me.element.createChild('group', 'wp-'~ me.model.idx);
    if(typeof(draw_sym) == 'func')
        draw_sym(me.wp_sym);
    elsif(typeof(draw_sym) == 'scalar')
        canvas.parsesvg(me.wp_sym, draw_sym);
    var translation = me.getStyle('translation', {});
    if(contains(translation, navtype)){
        me.wp_sym.setTranslation(translation[navtype]);
    }
    me.text_wps = wp_group.createChild("text", "wp-text-" ~ me.model.idx)
    .setDrawMode( canvas.Text.TEXT )
    .setText(me.model.name)
    .setFont("LiberationFonts/LiberationSans-Regular.ttf")
    .setFontSize(28)
    .setTranslation(25,15)
    .setColor(1,1,1);
    me.text_alt = nil;
    if(alt > 0 or spd > 0){
        var cstr_txt = "\n";
        if(alt > 0){
            if(alt > 10000) 
                cstr_txt ~= sprintf('FL%3.0f', int(alt / 100));
            else 
                cstr_txt ~= sprintf('%4.0f', int(alt));
        }
        if(spd > 0){
            if(alt > 0) cstr_txt ~= "\n";
            if(spd <= 1) 
                cstr_txt ~= sprintf('%1.2fM', spd);
            else 
                cstr_txt ~= sprintf('%3.0fKT', int(spd));
        }
        me.text_alt = wp_group.createChild("text", "wp-alt-text-" ~ me.model.idx)
        .setDrawMode( canvas.Text.TEXT )
        .setText(cstr_txt)
        .setFont("LiberationFonts/LiberationSans-Regular.ttf")
        .setFontSize(28)
        .setTranslation(25,15);
    }
}

var draw = func{
    var wp_group = me.element;
    var alt = me.model.alt;
    var i = me.model.idx;
    var vnav_actv = getprop(me.options.ver_ctrl) == me.options.managed_val;
    var curwp = getprop(me.options.current_wp);
    if(alt > 0){
        var wp_d = me.model.wp.distance_along_route;
        var lvl_off_at = getprop(me.options.level_off_alt);
        if(lvl_off_at == nil) lvl_off_at = 0;
        if(me.alt_path == nil){
            me.alt_path = wp_group.createChild("path").
            setStrokeLineWidth(4).
            moveTo(-22,0).
            arcSmallCW(22,22,0,44,0).
            arcSmallCW(22,22,0,-44,0);
        }
        if(vnav_actv){
            if(lvl_off_at and (lvl_off_at - wp_d) > 0.5 and curwp == i)
                me.alt_path.setColor(me.missed_constraint_color);
            else
                me.alt_path.setColor(me.active_constraint_color);
        }
        else
            me.alt_path.setColor(me.constraint_color);
        if(me.layer.toggle_cstr)
            me.alt_path.show();
        else
            me.alt_path.hide();
    } else {
        if(me.alt_path != nil) me.alt_path.hide();
    }
    wp_group.set("z-index",4);
    #var sym = me.element.getElementById('wp-' ~ me.model.idx);
    if(alt > 0 and me.text_alt != nil){
        if(vnav_actv)
            me.text_alt.setColor(me.active_constraint_color);
        else
            me.text_alt.setColor(me.constraint_color);
    }
    if(i == curwp) {
        me.wp_sym.setColor(me.current_wp_color);
        me.text_wps.setColor(me.current_wp_color);
    } else {
        me.wp_sym.setColor(me.wp_color);
        me.text_wps.setColor(me.wp_color);
    }
    if(me.model.is_departure or me.model.is_destination){
        var prop = (me.model.is_departure ? 'departure' : 'destination');
        var rwy = getprop("/autopilot/route-manager/"~prop~"/runway");
        if(rwy != nil and size(rwy) > 0){
            me.wp_sym.hide();
        } else {
            me.wp_sym.show();
        }
    }
}
