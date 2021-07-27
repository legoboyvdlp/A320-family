# provides relative vectors from eye-point to aircraft lights
# in east/north/up coordinates the renderer uses
# Thanks to BAWV12 / Thorsten

var als_on = props.globals.getNode("");
var alt_agl = props.globals.getNode("position/gear-agl-ft");
var cur_alt = 0;

var Light = {
	new: func(n) {
		var light = {parents: [Light]};
		light.isOn = 0;
		
		light.Pos = {
			x: 0,
			y: 0,
			z: 0,
		};
		
		light.Color = {
			r: 0,
			g: 0,
			b: 0,
		};
		
		light.colorr = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/lightspot-r[" ~ n ~ "]", 1);
		light.colorg = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/lightspot-g[" ~ n ~ "]", 1);
		light.colorb = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/lightspot-b[" ~ n ~ "]", 1);
		light.dir = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/dir[" ~ n ~ "]", 1);
		light.size = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/size[" ~ n ~ "]", 1);
		light.posx = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[" ~ n ~ "]", 1);
		light.posy = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[" ~ n ~ "]", 1);
		light.posz = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[" ~ n ~ "]", 1);
		
		if (n <= 1) {
			light.stretch = props.globals.getNode("/sim/rendering/als-secondary-lights/lightspot/stretch[" ~ n ~ "]", 1);
		}
		return light;
	},
	setColor: func(r,g,b) {
		me.Color.r = r;
		me.Color.g = g;
		me.Color.b = b;
	},
	setDir: func(dir) {
		me.dir.setValue(dir);
	},
	setSize: func(size) {
		me.size.setValue(size);
	},
	setStretch: func(stretch) {
		me.stretch.setValue(stretch);
	},
	setPos: func(x,y,z) {
		me.Pos.x = x;
		me.Pos.y = y;
		me.Pos.z = z;
	},
	on: func() {
		if (me.isOn) { return; }
		me.colorr.setValue(me.Color.r);
		me.colorg.setValue(me.Color.g);
		me.colorb.setValue(me.Color.b);
		me.isOn = 1;
	},
	off: func() {
		if (!me.isOn) { return; }
		me.colorr.setValue(0);
		me.colorg.setValue(0);
		me.colorb.setValue(0);
		me.isOn = 0;
	},
};

var lightManager = {
	lat_to_m: 110952.0,
	lon_to_m: 0.0,
	
	Lights: {
		light1: Light.new(0),
		light2: Light.new(1),
		light3: Light.new(2),
		light4: Light.new(3),
		light5: Light.new(4),
	},
	
	init: func() {
		setprop("/sim/rendering/als-secondary-lights/flash-radius", 13);
		setprop("/sim/rendering/als-secondary-lights/num-lightspots", 5);
		
		me.Lights.light1.setPos(100,0,2);
		me.Lights.light2.setPos(60,0,2);
		me.Lights.light3.setPos(-2,18,2);
		me.Lights.light4.setPos(-2,-18,2);
		me.Lights.light5.setPos(-25,0,2);
		
		me.Lights.light1.setColor(0.7,0.7,0.7);
		me.Lights.light2.setColor(0.7,0.7,0.7);
		me.Lights.light3.setColor(0.4,0.0,0.0);
		me.Lights.light4.setColor(0.0,0.4,0.0);
		me.Lights.light5.setColor(0.4,0.4,0.4);
		
		me.Lights.light1.setSize(12);
		me.Lights.light2.setSize(6);
		me.Lights.light3.setSize(4);
		me.Lights.light4.setSize(4);
		me.Lights.light5.setSize(5);
		
		me.Lights.light1.setStretch(6);
		me.Lights.light2.setStretch(6);
		me.update();
	},
	apos: 0,
	curAlt: 0,
	ELEC: [0, 0],
	ll1: 0,
	ll2: 0,
	ll3: 0,
	nav: 0,
	run: 0,
	vpos: 0,
	Pos: {
		alt: 0,
		heading: 0,
		headingSine: 0,
		headingCosine: 0,
		lat: 0,
		lon: 0,
	},
	update: func() {
		if (!me.run) {
			settimer ( func me.update(), 0.00);
			return;
		}
		
		me.curAlt = pts.Position.gearAglFt.getValue();
		if (me.curAlt > 100) {
			settimer ( func me.update(), 1);
			return;
		}
		
		me.ll1 = pts.Controls.Lighting.landingLights[1].getValue();
		me.ll2 = pts.Controls.Lighting.landingLights[2].getValue();
		me.ll3 = pts.Sim.Model.Lights.noseLights.getValue();
		me.nav = pts.Sim.Model.Lights.navLights.getValue();
			
		me.apos = geo.aircraft_position();
		me.vpos = geo.viewer_position();


		me.Pos.lat = me.apos.lat();
		me.Pos.lon = me.apos.lon();
		me.Pos.alt = me.apos.alt();
		me.Pos.heading = pts.Orientation.heading.getValue() * D2R;
		me.Pos.headingSine = math.sin(me.Pos.heading);
		me.Pos.headingCosine = math.cos(me.Pos.heading);
		me.lon_to_m = math.cos(me.Pos.lat*D2R) * me.lat_to_m;

		me.ELEC[0] = systems.ELEC.Bus.ac1.getValue();
		me.ELEC[1] = systems.ELEC.Bus.ac2.getValue();
			
		if ((me.ll1 == 1 and me.ELEC[0] >= 110) and (me.ll2 == 1 and me.ELEC[1] >= 110)) {
			me.Lights.light1.setPos(100,0,2);
			me.Lights.light1.setSize(16);
			me.Lights.light1.on();
		} else if (me.ll1 == 1 and me.ELEC[0] >= 110) {
			me.Lights.light1.setPos(100,3,2);
			me.Lights.light1.setSize(12);
			me.Lights.light1.on();
		} else if (me.ll2 == 1 and me.ELEC[1] >= 110) {
			me.Lights.light1.setPos(100,-3,2);
			me.Lights.light1.setSize(12);
			me.Lights.light1.on();
		} else {
			me.Lights.light1.off();
		}
			
		if (me.ll3 != 0) {
			me.Lights.light2.on();
		} else {
			me.Lights.light2.off();
		}
			
		if (me.ll3 == 1) {
			me.Lights.light2.setSize(8);
			me.Lights.light2.setPos(65,0,2);
		} else {
			me.Lights.light2.setSize(6);
			me.Lights.light2.setPos(60,0,2);
		}
			
		if (me.nav == 1) {
			me.Lights.light3.on();
			me.Lights.light4.on();
			me.Lights.light5.on();
		} else {
			me.Lights.light3.off();
			me.Lights.light4.off();
			me.Lights.light5.off();
		}
		
		
		# light 1 position
		me.apos.set_lat(me.Pos.lat + ((me.Lights.light1.Pos.x + me.curAlt) * me.Pos.headingCosine + me.Lights.light1.Pos.y * me.Pos.headingSine) / me.lat_to_m);
		me.apos.set_lon(me.Pos.lon + ((me.Lights.light1.Pos.x + me.curAlt) * me.Pos.headingSine - me.Lights.light1.Pos.y * me.Pos.headingCosine) / me.lon_to_m);
 
		me.Lights.light1.posx.setValue((me.apos.lat() - me.vpos.lat()) * me.lat_to_m);
		me.Lights.light1.posy.setValue(-(me.apos.lon() - me.vpos.lon()) * me.lon_to_m);
		me.Lights.light1.posz.setValue(me.apos.alt()- (me.curAlt / 10) - me.vpos.alt());
		me.Lights.light1.dir.setValue(me.Pos.heading);			

		# light 2 position
		me.apos.set_lat(me.Pos.lat + ((me.Lights.light2.Pos.x + me.curAlt) * me.Pos.headingCosine + me.Lights.light2.Pos.y * me.Pos.headingSine) / me.lat_to_m);
		me.apos.set_lon(me.Pos.lon + ((me.Lights.light2.Pos.x + me.curAlt) * me.Pos.headingSine - me.Lights.light2.Pos.y * me.Pos.headingCosine) / me.lon_to_m);
 
		me.Lights.light2.posx.setValue((me.apos.lat() - me.vpos.lat()) * me.lat_to_m);
		me.Lights.light2.posy.setValue(-(me.apos.lon() - me.vpos.lon()) * me.lon_to_m);
		me.Lights.light2.posz.setValue(me.apos.alt()- (me.curAlt / 10) - me.vpos.alt());
		me.Lights.light2.dir.setValue(me.Pos.heading);		
 
		# light 3 position
		me.apos.set_lat(me.Pos.lat + ((me.Lights.light3.Pos.x + me.curAlt) * me.Pos.headingCosine + me.Lights.light3.Pos.y * me.Pos.headingSine) / me.lat_to_m);
		me.apos.set_lon(me.Pos.lon + ((me.Lights.light3.Pos.x + me.curAlt) * me.Pos.headingSine - me.Lights.light3.Pos.y * me.Pos.headingCosine) / me.lon_to_m);
 
		me.Lights.light3.posx.setValue((me.apos.lat() - me.vpos.lat()) * me.lat_to_m);
		me.Lights.light3.posy.setValue(-(me.apos.lon() - me.vpos.lon()) * me.lon_to_m);
		me.Lights.light3.posz.setValue(me.apos.alt()- (me.curAlt / 10) - me.vpos.alt());
		me.Lights.light3.dir.setValue(me.Pos.heading);		
	
		# light 4 position
		me.apos.set_lat(me.Pos.lat + ((me.Lights.light4.Pos.x + me.curAlt) * me.Pos.headingCosine + me.Lights.light4.Pos.y * me.Pos.headingSine) / me.lat_to_m);
		me.apos.set_lon(me.Pos.lon + ((me.Lights.light4.Pos.x + me.curAlt) * me.Pos.headingSine - me.Lights.light4.Pos.y * me.Pos.headingCosine) / me.lon_to_m);
 
		me.Lights.light4.posx.setValue((me.apos.lat() - me.vpos.lat()) * me.lat_to_m);
		me.Lights.light4.posy.setValue(-(me.apos.lon() - me.vpos.lon()) * me.lon_to_m);
		me.Lights.light4.posz.setValue(me.apos.alt()- (me.curAlt / 10) - me.vpos.alt());
		me.Lights.light4.dir.setValue(me.Pos.heading);		
		
		# light 5 position
		me.apos.set_lat(me.Pos.lat + ((me.Lights.light5.Pos.x + me.curAlt) * me.Pos.headingCosine + me.Lights.light5.Pos.y * me.Pos.headingSine) / me.lat_to_m);
		me.apos.set_lon(me.Pos.lon + ((me.Lights.light5.Pos.x + me.curAlt) * me.Pos.headingSine - me.Lights.light5.Pos.y * me.Pos.headingCosine) / me.lon_to_m);
 
		me.Lights.light5.posx.setValue((me.apos.lat() - me.vpos.lat()) * me.lat_to_m);
		me.Lights.light5.posy.setValue(-(me.apos.lon() - me.vpos.lon()) * me.lon_to_m);
		me.Lights.light5.posz.setValue(me.apos.alt()- (me.curAlt / 10) - me.vpos.alt());
		me.Lights.light5.dir.setValue(me.Pos.heading);		
		
		settimer ( func me.update(), 0.00);
	},
};

setlistener(pts.Sim.Rendering.Shaders.skydome, func(v) {
	lightManager.run = v.getValue() ? 1 : 0;
}, 1, 0);