# A3XX CPDLC - Jonathan Redpath
# Copyright (c) 2022 Josh Davidson (Octal450)
var A320CPDLCMessageHandler = cpdlc.CPDLCMessageHandler.new();

var CPDLCmessage = {
	new: func(text,responses) {
		var cpdlcMessage = {parents: [CPDLCmessage] };
		cpdlcMessage.text = text;
		cpdlcMessage.responses = responses;
		cpdlcMessage._receivedTime = left(getprop("/sim/time/gmt-string"), 5);
		cpdlcMessage.receivedTime = split(":", cpdlcMessage._receivedTime)[0] ~ "." ~ split(":", cpdlcMessage._receivedTime)[1] ~ "Z";
		return cpdlcMessage;
	},
};

var DCDUBuffer = {
	buffer: std.Vector.new(),
	insertMessage: func(message) {
		me.buffer.append(message);
	},
	popMessage: func() {
		return me.buffer.pop(0);
	},
};

var CPDLCnewMsgFlag = props.globals.getNode("/network/cpdlc/rx/new-message");
var CPDLCnewMsgAlert = props.globals.initNode("/network/cpdlc/new-message-ringtone", 0, "BOOL");
var CPDLCnewMsgLight = props.globals.initNode("/network/cpdlc/new-message-light", 0, "BOOL");

var ATCMSGRingCancel = 0;
var ATCMsgFlashCancel = 0;

setlistener("/network/cpdlc/rx/new-message", func() {
	if (CPDLCnewMsgFlag.getBoolValue()) {
		fgcommand("cpdlc-next-message");
		# add to DCDU message buffer to display
		var message = CPDLCmessage.new(A320CPDLCMessageHandler.getMessage(),A320CPDLCMessageHandler.getReplyOptions());
		DCDUBuffer.insertMessage(message);
		if (!canvas_dcdu.DCDU.showingMessage) {
			canvas_dcdu.DCDU.showNextMessage();
		}
		
		ATCMSGRingCancel = 1;
		var messageType = 0; # urgent or normal
		ATCMSGRing(messageType);
		ATCMSGRingCancel = 0;
		ATCMsgFlashCancel = 1;
		ATCMSGFlash();
		ATCMsgFlashCancel = 0;
		
		# ATC MSG pushbutton: flashes, ringtone after 15 secs, therafter every 15 secs
		# add DCDU prompts (wilco, etc) associated to message --> so the CPDLC message object must store the correct response for the actual message
	}
}, 0, 1);

var ATCMSGRing = func(messageType) {
	settimer(func() {
		if (!ATCMSGRingCancel) {
			CPDLCnewMsgAlert.setBoolValue(0);
			settimer(func() {
				CPDLCnewMsgAlert.setBoolValue(1);
				ATCMSGRing(messageType);
			}, 0.1);
		}
	}, (messageType == 0 ? 15 : 5));
};

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