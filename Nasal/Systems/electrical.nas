# A3XX Electrical System
# Copyright (c) 2021 Jonathan Redpath (legoboyvdlp)

# Main class
var ELEC = {
	EmerElec: props.globals.getNode("/systems/electrical/some-electric-thingie/emer-elec-config"),
	EmerElec45: props.globals.getNode("/systems/electrical/some-electric-thingie/emer-elec-config-45"),
	Bus: {
		acEss: props.globals.getNode("/systems/electrical/bus/ac-ess"),
		acEssShed: props.globals.getNode("/systems/electrical/bus/ac-ess-shed"),
		ac1: props.globals.getNode("/systems/electrical/bus/ac-1"),
		ac2: props.globals.getNode("/systems/electrical/bus/ac-2"),
		dcBat: props.globals.getNode("/systems/electrical/bus/dc-bat"),
		dcEss: props.globals.getNode("/systems/electrical/bus/dc-ess"),
		dcEssShed: props.globals.getNode("/systems/electrical/bus/dc-ess-shed"),
		dc1: props.globals.getNode("/systems/electrical/bus/dc-1"),
		dc2: props.globals.getNode("/systems/electrical/bus/dc-2"),
		dcHot1: props.globals.getNode("/systems/electrical/bus/dc-hot-1"),
		dcHot1703: props.globals.getNode("/systems/electrical/bus/sub-bus/dc-hot-1-703"),
		dcHot2: props.globals.getNode("/systems/electrical/bus/dc-hot-2"),
		dcHot2704: props.globals.getNode("/systems/electrical/bus/sub-bus/dc-hot-2-704"),
	},
	Fail: {
		acEssBusFault: props.globals.getNode("/systems/failures/electrical/ac-ess-bus"),
		ac1BusFault: props.globals.getNode("/systems/failures/electrical/ac-1-bus"),
		ac2BusFault: props.globals.getNode("/systems/failures/electrical/ac-2-bus"),
		dcEssBusFault: props.globals.getNode("/systems/failures/electrical/dc-ess-bus"),
		dc1BusFault: props.globals.getNode("/systems/failures/electrical/dc-1-bus"),
		dc2BusFault: props.globals.getNode("/systems/failures/electrical/dc-2-bus"),
		emerGenFault: props.globals.getNode("/systems/failures/electrical/emer-gen"),
		essTrFault: props.globals.getNode("/systems/failures/electrical/ess-tr"),
		gen1Fault: props.globals.getNode("/systems/failures/electrical/gen-1"),
		gen2Fault: props.globals.getNode("/systems/failures/electrical/gen-2"),
		genApuFault: props.globals.getNode("/systems/failures/electrical/apu"),
		idg1Fault: props.globals.getNode("/systems/failures/electrical/idg-1"), # oil leak or low press
		idg2Fault: props.globals.getNode("/systems/failures/electrical/idg-2"),
		statInvFault: props.globals.getNode("/systems/failures/electrical/stat-inv"),
		tr1Fault: props.globals.getNode("/systems/failures/electrical/tr-1"),
		tr2Fault: props.globals.getNode("/systems/failures/electrical/tr-2"),
	},
	Generic: {
		efis: props.globals.initNode("/systems/electrical/outputs/efis", 0, "DOUBLE"),
		fcpPower: props.globals.initNode("/systems/electrical/outputs/fcp-power", 0, "DOUBLE"),
		fuelPump0: props.globals.initNode("/systems/electrical/outputs/fuel-pump[0]", 0, "DOUBLE"),
		fuelPump1: props.globals.initNode("/systems/electrical/outputs/fuel-pump[1]", 0, "DOUBLE"),
		fuelPump2: props.globals.initNode("/systems/electrical/outputs/fuel-pump[2]", 0, "DOUBLE"),
		gps: props.globals.initNode("/systems/electrical/outputs/gps", 0, "DOUBLE"),
		mkViii: props.globals.initNode("/systems/electrical/outputs/mk-viii", 0, "DOUBLE"),
		tacan: props.globals.initNode("/systems/electrical/outputs/tacan", 0, "DOUBLE"),
		transponder: props.globals.initNode("/systems/electrical/outputs/transponder", 0, "DOUBLE"),
		turnCoordinator: props.globals.initNode("/systems/electrical/outputs/turn-coordinator", 0, "DOUBLE"),
	},
	Light: {
		bat1Fault: props.globals.getNode("/systems/electrical/light/bat-1-fault"),
		bat2Fault: props.globals.getNode("/systems/electrical/light/bat-2-fault"),
	},
	Misc: {
	},
	Relay: {
		acEssFeed1: props.globals.getNode("/systems/electrical/relay/ac-ess-feed-1/contact-pos"),
		acEssFeed2: props.globals.getNode("/systems/electrical/relay/ac-ess-feed-2/contact-pos"),
		acEssEmerGenFeed: props.globals.getNode("/systems/electrical/relay/ac-ess-feed-emer-gen/contact-pos"),
		acTie1: props.globals.getNode("/systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos"),
		acTie2: props.globals.getNode("/systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos"),
		apuGlc: props.globals.getNode("/systems/electrical/relay/apu-glc/contact-pos"),
		dcEssFeedBat: props.globals.getNode("/systems/electrical/relay/dc-bat-tie-dc-ess/contact-pos"),
		essTrContactor: props.globals.getNode("/systems/electrical/relay/ess-tr-contactor/contact-pos"),
		extEpc: props.globals.getNode("/systems/electrical/relay/ext-epc/contact-pos"),
		dcTie1: props.globals.getNode("/systems/electrical/relay/dc-bat-tie-dc-1/contact-pos"),
		dcTie2: props.globals.getNode("/systems/electrical/relay/dc-bat-tie-dc-2/contact-pos"),
		glc1: props.globals.getNode("/systems/electrical/relay/gen-1-glc/contact-pos"),
		glc2: props.globals.getNode("/systems/electrical/relay/gen-2-glc/contact-pos"),
		relay7XB: props.globals.getNode("/systems/electrical/sources/si-1/inverter-control/relay-7xb"),
		relay15XE2: props.globals.getNode("/systems/electrical/relay/relay-15XE2/contact-pos"),
		tr1Contactor: props.globals.getNode("/systems/electrical/relay/tr-contactor-1/contact-pos"),
		tr2Contactor: props.globals.getNode("/systems/electrical/relay/tr-contactor-2/contact-pos"),
	},
	SomeThing: {
		emerGenSignal: props.globals.getNode("/systems/electrical/some-electric-thingie/emer-gen-operate"),
		galley: props.globals.getNode("/systems/electrical/some-electric-thingie/galley-shed"),
	},
	Source: {
		Apu: {
			volts: props.globals.getNode("/systems/electrical/sources/apu/output-volt"),
			hertz: props.globals.getNode("/systems/electrical/sources/apu/output-hertz"),
			contact: props.globals.getNode("/systems/electrical/relay/apu-glc/contact-pos"),
		},
		Bat1: {
			volt: props.globals.getNode("/systems/electrical/sources/bat-1/volt"),
			amps: props.globals.getNode("/systems/electrical/sources/bat-1/amps"),
			contact: props.globals.getNode("/systems/electrical/sources/bat-1/bcl-supply"),
			percent: props.globals.getNode("/systems/electrical/sources/bat-1/percent"),
			direction: props.globals.getNode("/systems/electrical/sources/bat-1/direction"),
			time: props.globals.getNode("/systems/electrical/sources/bat-1/time"),
		},
		Bat2: {
			volt: props.globals.getNode("/systems/electrical/sources/bat-2/volt"),
			amps: props.globals.getNode("/systems/electrical/sources/bat-2/amps"),
			contact: props.globals.getNode("/systems/electrical/sources/bat-2/bcl-supply"),
			percent: props.globals.getNode("/systems/electrical/sources/bat-2/percent"),
			direction: props.globals.getNode("/systems/electrical/sources/bat-2/direction"),
			time: props.globals.getNode("/systems/electrical/sources/bat-2/time"),
		},
		EmerGen: {
			volts: props.globals.getNode("/systems/electrical/sources/emer-gen/output-volt"),
			hertz: props.globals.getNode("/systems/electrical/sources/emer-gen/output-hertz"),
			voltsRelay: props.globals.getNode("/systems/electrical/relay/emer-glc/output"),
			relayPos: props.globals.getNode("/systems/electrical/relay/emer-glc/contact-pos"),
		},
		Ext: {
			volts: props.globals.getNode("/systems/electrical/sources/ext/output-volt"),
			hertz: props.globals.getNode("/systems/electrical/sources/ext/output-hertz"),
		},
		Idg1: {
			gcrRelay: props.globals.getNode("/systems/electrical/sources/idg-1/gcr-relay"),
			hertz: props.globals.getNode("/systems/electrical/sources/idg-1/output-hertz"),
			volts: props.globals.getNode("/systems/electrical/sources/idg-1/output-volt"),
		},
		Idg2: {
			gcrRelay: props.globals.getNode("/systems/electrical/sources/idg-2/gcr-relay"),
			hertz: props.globals.getNode("/systems/electrical/sources/idg-2/output-hertz"),
			volts: props.globals.getNode("/systems/electrical/sources/idg-2/output-volt"),
		},
		Inverter: {
			hertz: props.globals.getNode("/systems/electrical/sources/si-1/output-hertz"),
			volts: props.globals.getNode("/systems/electrical/sources/si-1/output-volt"),
		},
		tr1: {
			outputVolt: props.globals.getNode("/systems/electrical/relay/tr-contactor-1/output"),
			outputAmp: props.globals.getNode("/systems/electrical/relay/tr-contactor-1/output-amp"),
		},
		tr2: {
			outputVolt: props.globals.getNode("/systems/electrical/relay/tr-contactor-2/output"),
			outputAmp: props.globals.getNode("/systems/electrical/relay/tr-contactor-2/output-amp"),
		},
		trEss: {
			outputVolt: props.globals.getNode("/systems/electrical/sources/ess-tr/output-volt"),
			outputAmp: props.globals.getNode("/systems/electrical/sources/ess-tr/output-amp"),
			outputVoltRelay: props.globals.getNode("/systems/electrical/relay/ess-tr-contactor/output"),
			outputAmpRelay: props.globals.getNode("/systems/electrical/relay/ess-tr-contactor/output-amp"),
		},
	},
	Switch: {
		acEssFeed: props.globals.getNode("/controls/electrical/switches/ac-ess-feed"),
		bat1: props.globals.getNode("/controls/electrical/switches/bat-1"),
		bat2: props.globals.getNode("/controls/electrical/switches/bat-2"),
		busTie: props.globals.getNode("/controls/electrical/switches/bus-tie"),
		emerElecManOn: props.globals.getNode("/controls/electrical/switches/emer-elec-man-on"), # non-reset
		emerGenTest: props.globals.getNode("/controls/electrical/switches/emer-gen-test"),
		extPwr: props.globals.getNode("/controls/electrical/switches/ext-pwr"),
		galley: props.globals.getNode("/controls/electrical/switches/galley"),
		gen1: props.globals.getNode("/controls/electrical/switches/gen-1"),
		gen2: props.globals.getNode("/controls/electrical/switches/gen-2"),
		genApu: props.globals.getNode("/controls/electrical/switches/apu"),
		gen1Line: props.globals.getNode("/controls/electrical/switches/gen-1-line-contactor"),
		groundCart: props.globals.getNode("/controls/electrical/switches/ground-cart"),
		idg1Disc: props.globals.getNode("/controls/electrical/switches/idg-1-disc"),
		idg2Disc: props.globals.getNode("/controls/electrical/switches/idg-2-disc"),
	},
	init: func() {
		me.resetFailures();
		me.SomeThing.emerGenSignal.setBoolValue(0);
		me.Switch.acEssFeed.setBoolValue(0);
		me.Switch.bat1.setBoolValue(0);
		me.Switch.bat2.setBoolValue(0);
		me.Switch.busTie.setBoolValue(1);
		me.Switch.emerGenTest.setBoolValue(0);
		me.Switch.extPwr.setBoolValue(0);
		me.Switch.galley.setBoolValue(1);
		me.Switch.gen1.setBoolValue(1);
		me.Switch.gen2.setBoolValue(1);
		me.Switch.genApu.setBoolValue(1);
		me.Switch.gen1Line.setBoolValue(0);
		me.Switch.groundCart.setBoolValue(0);
		me.Switch.idg1Disc.setBoolValue(1);
		me.Switch.idg2Disc.setBoolValue(1);
		me.Switch.emerElecManOn.setBoolValue(0);
	},
	resetFailures: func() {
		me.Fail.acEssBusFault.setBoolValue(0);
		me.Fail.ac1BusFault.setBoolValue(0);
		me.Fail.ac2BusFault.setBoolValue(0);
		me.Fail.dcEssBusFault.setBoolValue(0);
		me.Fail.dc1BusFault.setBoolValue(0);
		me.Fail.dc2BusFault.setBoolValue(0);
		me.Fail.emerGenFault.setBoolValue(0);
		me.Fail.essTrFault.setBoolValue(0);
		me.Fail.gen1Fault.setBoolValue(0);
		me.Fail.gen2Fault.setBoolValue(0);
		me.Fail.genApuFault.setBoolValue(0);
		me.Fail.idg1Fault.setBoolValue(0);
		me.Fail.idg2Fault.setBoolValue(0);
		me.Fail.statInvFault.setBoolValue(0);
		me.Fail.tr1Fault.setBoolValue(0);
		me.Fail.tr2Fault.setBoolValue(0);
	},
	loop: func() {
		# Empty, required for Emesary
	},
};

setlistener("/systems/fmgc/power/power-1-on", func(val) {
	if (!val.getBoolValue()) {
		if (fmgc.Output.ap1.getValue()) {
			fcu.apOff("hard", 1);
		}
		if (fcu.FCUController.activeFMGC.getValue() == 1 and fmgc.Output.athr.getValue()) {
			fcu.athrOff("hard");
		}
	}
}, 0, 0);

setlistener("/systems/fmgc/power/power-2-on", func(val) {
	if (!val.getBoolValue()) {
		if (fmgc.Output.ap2.getValue()) {
			fcu.apOff("hard", 2);
		}
		if (fcu.FCUController.activeFMGC.getValue() == 2 and fmgc.Output.athr.getValue()) {
			fcu.athrOff("hard");
		}
	}
}, 0, 0);

# Emesary
var A320Electrical = notifications.SystemRecipient.new("A320 Electrical",ELEC.loop,ELEC);
emesary.GlobalTransmitter.Register(A320Electrical);

var input = {
	"elecAC1": "/systems/electrical/bus/ac-1",
	"elecAC2": "/systems/electrical/bus/ac-2",
	"elecACEss": "/systems/electrical/bus/ac-ess",
	"elecACEssShed": "/systems/electrical/bus/ac-ess-shed",
	"dc1": "/systems/electrical/bus/dc-1",
	"dc2": "/systems/electrical/bus/dc-2",
	"dcBat": "/systems/electrical/bus/dc-bat",
	"dcEss": "/systems/electrical/bus/dc-ess",
	"dcEssShed": "/systems/electrical/bus/dc-ess-shed",
	"dcHot1": "/systems/electrical/bus/dc-hot-1",
	"dcHot1703": "/systems/electrical/bus/sub-bus/dc-hot-1-703",
	"dcHot2": "/systems/electrical/bus/dc-hot-2",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 Electrical", name, input[name]));
}