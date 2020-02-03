# A3XX Auxilliary Power Unit
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var APU = {
	state: 0, # power up, watch, starting, run, cooldown, shutdown
	nRpm: 0,
	fuelValve: aircraft.door.new("/controls/apu/fuel-valve", 1),
	inletFlap: aircraft.door.new("/controls/apu/inlet-flap", 12),
	listenSignals: 0,
	start: 0,
	cancelCheckFlap: 0,
	new: func() {
		var a = { parents:[APU] };
		return a;
	},
	setState: func(num) {
		me.state = num;
	},
	powerOn: func() {
		# apu able to receive emergency stop or start signals
		me.fuelValve.open();
		me.inletFlap.open();
		me.listenSignals = 1;
		settimer(me.setState(1), 3);
	},
	getStartSignal: func() {
		if (me.listenSignals and me.state < 2 and me.nRpm < 7) {
			me.start = 1;
			me.startCheckFlap();
		} elsif (me.listenSignals) {
			settimer(me.getStartSignal(), 0);
		}
	},
	startCheckFlap: func() {
		if (me.inletFlap.getpos() != 1 and me.cancelCheckFlap == 0 and me.state == 1) {
			settimer(me.startCheckFlap(), 0);
		} elsif (me.cancelCheckFlap) {
			me.cancelCheckFlap = 0;
		} else {
			me.setState(2);
		}
	},
	getStopSignal: func() {
		if (me.listenSignals) {
			me.cancelCheckFlap = 1;
			me.inletFlap.close();
			# wait for flap close --> power down relay output
		}
	},
};

var APUController = {
	_init: 0,
	APU: nil,
	init: func() {
		if (!me._init) {
			me.APU = APU.new();
		}
	},
	loop: func() {
		if (me.APU != nil) {
			APU.update();
		}
	},
};