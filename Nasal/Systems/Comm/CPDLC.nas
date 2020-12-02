# A3XX CPDLC
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var CPDLCmessage = {
	new: func(text, response = 0) {
		var cpdlcMessage = {parents: [CPDLCmessage] };
		cpdlcMessage.text = text;
		cpdlcMessage.response = response;
		return cpdlcMessage;
	},
};

var CPDLCnewMsgFlag = props.globals.getNode("/network/cpdlc/rx/new-message");
var CPDLCnewMsgAlert = props.globals.initNode("/network/cpdlc/new-message-ringtone", 0, "BOOL");
var CPDLCnewMsgLight = props.globals.initNode("/network/cpdlc/new-message-light", 0, "BOOL");

setlistener("/network/cpdlc/rx/new-message", func() {
	if (CPDLCnewMsgFlag.getBoolValue()) {
		fgcommand("cpdlc-next-message");
		# add to DCDU message buffer to display
		ATCMSGRingCancel = 0;
		var messageType = 0; # urgent or normal
		ATCMSGRing(messageType);
		ATCMsgFlashCancel = 0;
		ATCMSGFlash();
		# ATC MSG pushbutton: flashes, ringtone after 15 secs, therafter every 15 secs
		# add DCDU prompts (wilco, etc) associated to message --> so the CPDLC message object must store the correct response for the actual message
	}
}, 0, 1);

var ATCMSGRingCancel = 0;
var ATCMSGRing = func(messageType) {
	print("Going to ring");
	settimer(func() {
		if (!ATCMSGRingCancel) {
			print("Rang, will ring 15 seconds later again");
			CPDLCnewMsgAlert.setBoolValue(0);
			settimer(func() {
				CPDLCnewMsgAlert.setBoolValue(1);
				ATCMSGRing(messageType);
			}, 0.1);
		}
	}, (messageType == 0 ? 15 : 5));
};

var ATCMsgFlashCancel = 0;
var ATCMSGFlash = func() {
	CPDLCnewMsgLight.setBoolValue(!CPDLCnewMsgLight.getBoolValue());
	settimer(func() {
		if (!ATCMsgFlashCancel) {
			ATCMSGFlash();
		}
	}, 0.2);
};

# issue fgcommand with cpdlc message to send

var prefixes = {
	acPerf: "DUE TO A/C PERFORMANCE",
	weather: "DUE TO WEATHER",
	turbulence: "DUE TO TURBULENCE",
	medical: "DUE TO MEDICAL",
	technical: "DUE TO TECHNICAL",
	discretion: "AT PILOTS DISCRETION",
};

var responses = {
	w: "WILCO",
	u: "UNABLE",
	a: "AFFIRM",
	n: "NEGATIVE",
	r: "ROGER",
	s: "STBY",
	#o: "none?",
	#y: "any?",
};

var freeText = {
	new: func() {
		return {parents: [freeText]};
	},
	selection: 9,
	changed: 0,
	getText: func() {
		if (me.selection == 0) {
			return prefixes["acPerf"];
		} elsif (me.selection == 1) {
			return prefixes["weather"];
		} elsif (me.selection == 2) {
			return prefixes["turbulence"];
		} elsif (me.selection == 3) {
			return prefixes["medical"];
		} elsif (me.selection == 4) {
			return prefixes["technical"];
		} elsif (me.selection == 5) {
			return prefixes["discretion"];
		} else {
			return "";
		}
	}
};

var freeTexts = [freeText.new(), freeText.new()];