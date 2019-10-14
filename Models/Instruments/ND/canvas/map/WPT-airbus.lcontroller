# See: http://wiki.flightgear.org/MapStructure
# Class things:
var name = 'WPT-airbus';
var parents = [canvas.SymbolLayer.Controller];
var __self__ = caller(0)[0];

canvas.SymbolLayer.Controller.add(name, __self__);
canvas.SymbolLayer.add(name, {
    parents: [canvas.MultiSymbolLayer],
    type: name, # Symbol type
    df_controller: __self__, # controller to use by default -- this one
    df_options: { # default configuration options
        fix_symbol: func(group){
            group.createChild('path')
            .moveTo(-10,0)
            .lineTo(0,-17)
            .lineTo(10,0)
            .lineTo(0,17)
            .close()
            .setStrokeLineWidth(3)
            .setColor(1,1,1)
            .setScale(1);
        },
        vor_symbol: 'Nasal/canvas/map/Airbus/Images/airbus_vor.svg',
        airport_symbol: 'Nasal/canvas/map/Airbus/Images/airbus_airport.svg',
        ndb_symbol: func(group){
            group.createChild('path')
            .moveTo(-15,15)
            .lineTo(0,-15)
            .lineTo(15,15)
            .close()
            .setStrokeLineWidth(3)
            #.setColor(0.69,0,0.39)
            #.setTranslation(-24, -24),
            .setScale(1,1);
        }
    },
    df_style: {
        active_wp_color: [0.4,0.7,0.4],
        current_wp_color: [1,1,1],
        translation: {
            'airport': [-24,-24],
            'vor': [-24,-24]
        }
    },
    toggle_cstr: 0
});

var new = func(layer) {
    var m = {
        parents: [__self__],
        layer: layer,
        map: layer.map,
        listeners: [],
    };
    layer.searcher._equals = func(a,b) a.equals(b);
    var driver = opt_member(m.layer.options, 'route_driver');
    if(driver == nil){
        driver = RouteDriver.new();
    }
    var driver_listeners = driver.getListeners();
    foreach(var listener; driver_listeners){
        append(m.listeners, setlistener(listener, func m.layer.update()));
    }
    m.route_driver = driver;
    return m;
};

var del = func() {
    foreach (var l; me.listeners)
        removelistener(l);
};

var WPTModel = {
    new: func(fp, idx) {
        var m = { parents:[WPTModel] };
        var wp = fp.getWP(idx);

        m.id = wp.id;
        m.name = wp.wp_name;
        m.alt = wp.alt_cstr;
        m.spd = wp.speed_cstr;
        m.type = wp.wp_type;

        (m.lat,m.lon) = (wp.wp_lat,wp.wp_lon);
        var is_rwy = (m.type == 'runway');
        var id_len = size(m.id);
        if(!is_rwy and id_len < 5){
            if(id_len == 4 and airportinfo(m.id) != nil)
                m.navtype = 'airport';
            else {
                var navaid = nil;
                foreach(var t; ['vor', 'ndb']){
                    navaid = navinfo(m.lat, m.lon, t, m.id);
                    if(navaid != nil and size(navaid)){
                        m.navtype = t;
                        break;
                    }
                }
                if(navaid == nil or !size(navaid)) m.navtype = 'fix';
            }
        } else {
            m.navtype = (is_rwy ? 'rwy' : 'fix');
        }
        
        m.wp = wp;
        idx = wp.index;
        m.idx = idx;
        m.is_departure = (idx == 0 and is_rwy);
        m.is_destination = (idx > 0 and is_rwy);
        return m;
    },
    equals: func(other) {
        # this is set on symbol init, so use this for equality...
        me.name == other.name and me.alt == other.alt and
        me.type == other.type and me.idx == other.idx and 
        me.navtype == other.navtype
    },
};

var searchCmd = func {
    var driver = me.route_driver;
    if(!driver.shouldUpdate()) return [];
    driver.update();
    var result = [];
    var planCount = driver.getNumberOfFlightPlans();
    for(var idx = 0; idx < planCount; idx += 1){
        var fp = driver.getFlightPlan(idx);
        if(fp == nil) continue;
        var fpSize = fp.getPlanSize(idx);
        for (var i = 0; i < fpSize; i+=1){
            if(!driver.shouldUpdate()) return[];
            append(result, WPTModel.new(fp, i));
        }
    }
    return result;
}
