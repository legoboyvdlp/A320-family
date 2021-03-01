# Projection-related helper functions for the MFD maps

var Camera = {
    new: func(options) {
        var m = {
            parents: [Camera],

            camGeo: options['camGeo'] or geo.aircraft_position(),
            camHdg: options['camHdg'] or 0,
            range: options['range'] or 10.0,
            screenRange: options['screenRange'] or 256.0,
            screenCX: options['screenCX'] or options['screenRange'] or 256.0,
            screenCY: options['screenCY'] or options['screenRange'] or 256.0,
        };
        return m;
    },

    setRange: func(range) {
        me.range = range;
    },

    repositon: func(geo, hdg) {
        me.camGeo = geo;
        me.camHdg = hdg;
    },

    project: func(targetGeo) {
        var dist = me.camGeo.distance_to(targetGeo) * M2NM;
        var bearing = me.camGeo.course_to(targetGeo) - me.camHdg;
        return me.projectDistBearing(dist, bearing);
    },

    projectDistBearing: func(dist, bearing) {
        var bearingRad = bearing * D2R;
        var tx =  math.sin(bearingRad) * dist;
        var ty = -math.cos(bearingRad) * dist;
        var x = tx * me.screenRange / me.range + me.screenCX;
        var y = ty * me.screenRange / me.range + me.screenCY;
        return [x, y];
    },
};
