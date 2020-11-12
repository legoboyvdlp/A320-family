########### Thunder sounds (from c172p) ###################

var clamp = func(v, min, max) { v < min ? min : v > max ? max : v };

var speed_of_sound = func (t, re) {
    # Compute speed of sound in m/s
    #
    # t = temperature in Celsius
    # re = amount of water vapor in the air

    # Compute virtual temperature using mixing ratio (amount of water vapor)
    # Ratio of gas constants of dry air and water vapor: 287.058 / 461.5 = 0.622
    var T = 273.15 + t;
    var v_T = T * (1 + re/0.622)/(1 + re);

    # Compute speed of sound using adiabatic index, gas constant of air,
    # and virtual temperature in Kelvin.
    return math.sqrt(1.4 * 287.058 * v_T);
};

var thunder_listener = func {
    var thunderCalls = 0;

    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x, 2) + math.pow(lightning_pos_y, 2));

    # On the ground, thunder can be heard up to 16 km. Increase this value
    # a bit because the aircraft is usually in the air.
    if (lightning_distance > 20000)
        return;

    var t = getprop("/environment/temperature-degc");
    var re = getprop("/environment/relative-humidity") / 100;
    var delay_seconds = lightning_distance / speed_of_sound(t, re);

    # Maximum volume at 5000 meter
    var lightning_distance_norm = std.min(1.0, 1 / math.pow(lightning_distance / 5000.0, 2));

    settimer(func {
        var thunder1 = getprop("/sim/sound/thunder1");
        var thunder2 = getprop("/sim/sound/thunder2");
        var thunder3 = getprop("/sim/sound/thunder3");
        var thunder4 = getprop("/sim/sound/thunder4");
        var vol = getprop("/sim/current-view/internal");
        if (!thunder1) {
            thunderCalls = 1;
            setprop("/sim/sound/dist-thunder1", lightning_distance_norm * vol * 1.75);
        }
        else if (!thunder2) {
            thunderCalls = 2;
            setprop("/sim/sound/dist-thunder2", lightning_distance_norm * vol * 1.75);
        }
        else if (!thunder3) {
            thunderCalls = 3;
            setprop("/sim/sound/dist-thunder3", lightning_distance_norm * vol * 1.75);
        }
        else if (!thunder4) {
            thunderCalls = 4;
            setprop("/sim/sound/dist-thunder4", lightning_distance_norm * vol * 1.75);
        }
        else
            return;

        # Play the sound (sound files are about 9 seconds)
        play_thunder("thunder" ~ thunderCalls, 9.0, 0);
    }, delay_seconds);
};

var play_thunder = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/sound/" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after timeout so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

setlistener("/environment/lightning/lightning-pos-y", thunder_listener);