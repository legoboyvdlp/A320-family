# A3XX High Frequency Radio
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)

var toneControl = props.globals.getNode("/systems/comm/hf/tone1000hz");
var reception = props.globals.getNode("/systems/comm/hf/reception");
var _toneTime = nil;

var highFrequencyRadio = {
	selectedChannelKhz: -9999,
	transmit: 0,
	tuned: 0,
	overrideDataLink: 0,
	datalinkConnected: 0,
	_transmitTime: nil,
	new: func(powerNode) {
        var a = { parents:[highFrequencyRadio] };
		a.powerNode = powerNode;
		me.selectChannel(2800);
        return a;
    },
	selectChannel: func(selectedKhz) {
		if (selectedKhz < 2000 or selectedKhz > 29999) { return; }
		if (selectedKhz - int(selectedKhz) != 0) { return; }
		me.selectedChannelKhz = selectedKhz;
		me.tuned = 0;
	},
	pttToggle: func() {
		if (me.powerNode.getValue() < 110) {
			me.transmit = 0;
			return;
		}
		
		if (me.transmit) {
			me.transmit = 0;
			reception.setValue(1);
		} else {
			me.transmit = 1;
			reception.setValue(0);
		}
		
		if (me.transmit) {
			_transmitTime = pts.Sim.Time.elapsedSec.getValue();
			if (me.selectedChannelKhz < 2800 or me.selectedChannelKhz > 23999) {
				me.generate1000Hz();
				return;
			}
			if (!me.tuned) {
				me.generate1000Hz(5);
				me.tuned = 1;
			}
		} else {
			ecam.transmitFlag = 0;
			if (_toneTime == nil) {
				toneControl.setValue(0);
			}
			_transmitTime = nil;
		}
	},
	monitorPTT: func() {
		if (transmit) {
			if (pts.Sim.Time.elapsedSec.getValue() > _transmitTime + 60) {
				ecam.transmitFlag = 1;
			}
		}
	},
	generate1000Hz: func(timeSec = 0) {
		if (timeSec == 0) {
			toneControl.setValue(1);
		} else {
			toneControl.setValue(1);
			_toneTime = pts.Sim.Time.elapsedSec.getValue() + timeSec;
			toneTimer.start();
		}
	},
	datalink: func() {
		if (me.powerNode.getValue() < 115) { 
			me.datalinkConnected = 0;
			return; 
		}
		
		if (overrideConnected or !pts.Gear.wow[0].getValue()) {
			datalinkConnected = 1;
		} else {
			datalinkConnected = 0;
		}
	},
};

var HFS = [highFrequencyRadio.new(systems.ELEC.Bus.acEssShed), highFrequencyRadio.new(systems.ELEC.Bus.ac2)];


var toneTimer = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > _toneTime) {
		toneControl.setValue(0);
		_toneTime = nil;
		toneTimer.stop();
	}	
});