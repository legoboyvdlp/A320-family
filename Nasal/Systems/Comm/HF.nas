# A3XX High Frequency Radio
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)

var highFrequencyRadio = {
	overrideDataLink: 0,
	datalinkConnected: 0,
	new: func(powerNode, num) {
        var a = { parents:[highFrequencyRadio] };
		a.powerNode = powerNode;
		a.selectedChannelKhz = int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10);
		a.num = num;
		a.receptionProp = props.globals.getNode("/systems/comm/hf/reception-" ~ (num + 1));
		a.toneControl = props.globals.getNode("/systems/comm/hf/tone1000hz-" ~ (num + 1));
		a._toneTime = nil;
		a._transmitTime = nil;
		a.transmit = 0;
		a.tuned = 0;
        return a;
    },
	selectChannel: func(selectedKhz) {
		if (selectedKhz < 2000 or selectedKhz > 29999) { return; }
		if (selectedKhz - int(selectedKhz) != 0) { return; }
		me.selectedChannelKhz = selectedKhz;
		me.tuned = 0;
		rmp.update_active_vhf(me.num + 4);
	},
	pttToggle: func() {
		if (me.powerNode.getValue() < 110) {
			me.transmit = 0;
			return;
		}
		
		if (me.transmit) {
			me.transmit = 0;
			me.receptionProp.setValue(1);
		} else {
			me.transmit = 1;
			me.receptionProp.setValue(0);
		}
		
		if (me.transmit) {
			me._transmitTime = pts.Sim.Time.elapsedSec.getValue();
			if (me.num == 0) {
				transmitTimer1.start();
			} else {
				transmitTimer2.start();
			}
			
			if (me.selectedChannelKhz < 2800 or me.selectedChannelKhz > 23999) {
				me.generate1000Hz();
				return;
			}
			if (!me.tuned) {
				me.generate1000Hz(5);
				me.tuned = 1;
			}
		} else {
			if (me.num == 0) {
				transmitTimer1.stop();
			} else {
				transmitTimer2.stop();
			}
			
			if (me.num == 0) {
				ecam.transmitFlag1 = 0;
			} else {
				ecam.transmitFlag2 = 0;
			}
			
			if (me._toneTime == nil) {
				me.toneControl.setValue(0);
			}
			me._transmitTime = nil;
		}
	},
	monitorPTT: func() {
		if (me.transmit) {
			if (pts.Sim.Time.elapsedSec.getValue() > me._transmitTime + 60) {
				if (me.num == 0) {
					ecam.transmitFlag1 = 1;
				} else {
					ecam.transmitFlag2 = 1;
				}
			}
		}
	},
	generate1000Hz: func(timeSec = 0) {
		if (timeSec == 0) {
			me.toneControl.setValue(1);
		} else {
			me.toneControl.setValue(1);
			me._toneTime = pts.Sim.Time.elapsedSec.getValue() + timeSec;
			if (me.num == 0) {
				toneTimer1.start();
			} else {
				toneTimer2.start();
			}
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

var HFS = [highFrequencyRadio.new(systems.ELEC.Bus.acEssShed, 0), highFrequencyRadio.new(systems.ELEC.Bus.ac2, 1)];

# Can't use setlistener on the voltage as it always gets written to by JSB (and changes according to engine rpm)

var update_items_HF_radio = [
	props.UpdateManager.FromHashValue("elecACEssShed", 0.1, func(val)
		{
			if (val < 110) {
				HFS[0].transmit = 0;
				HFS[0].receptionProp.setValue(0);
				toneTimer1.stop();
				transmitTimer1.stop();
				HFS[0].toneControl.setValue(0);
				HFS[0]._toneTime = nil;
				ecam.transmitFlag1 = 0;
			} else {
				HFS[0].receptionProp.setValue(1);
			}
		}
	),
	props.UpdateManager.FromHashValue("elecAC2", 0.1, func(val)
		{
			if (val) {
				HFS[1].transmit = 0;
				HFS[1].receptionProp.setValue(0);
				toneTimer2.stop();
				transmitTimer2.stop();
				HFS[1].toneControl.setValue(0);
				HFS[1]._toneTime = nil;
				ecam.transmitFlag2 = 0;
			} else {
				HFS[1].receptionProp.setValue(1);
			}
		}
	),
];

var HFLoop = func(notification) {
	foreach (var update_item_HF; update_items_HF_radio) {
		update_item_HF.update(notification);
	}
}

var toneTimer1 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > HFS[0]._toneTime) {
		HFS[0].toneControl.setValue(0);
		HFS[0]._toneTime = nil;
		toneTimer1.stop();
	}	
});

var toneTimer2 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > HFS[1]._toneTime) {
		HFS[1].toneControl.setValue(0);
		HFS[1]._toneTime = nil;
		toneTimer2.stop();
	}	
});

var transmitTimer1 = maketimer(1, func() {
	HFS[0].monitorPTT();
});

var transmitTimer2 = maketimer(1, func() {
	HFS[1].monitorPTT();
});
