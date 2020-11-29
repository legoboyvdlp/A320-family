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

setlistener("/network/cpdlc/rx/new-message", func() {
	if (CPDLCnewMsgflag.getBoolValue()) {
		# add to DCDU message buffer
		# make alert on DCDU
		# add DCDU prompts (wilco, etc)
		CPDLCnewMsgFlag.setBoolValue(0);
	}
}, 0, 0);

# issue fgcommand with cpdlc message to send

var freeText = {
	new: func(index) {
		var freeTextObj = {parents: [freeText]};
		freeTextObj.index = index;
		return freeTextObj;
	},
	selection: 9,
	changed: 0,
	getText: func() {
		if (me.selection == 0) {
			return "DUE TO A/C PERFORMANCE";
		} elsif (me.selection == 1) {
			return "DUE TO WEATHER";
		} elsif (me.selection == 2) {
			return "DUE TO TURBULENCE";
		} elsif (me.selection == 3) {
			return "DUE TO MEDICAL";
		} elsif (me.selection == 4) {
			return "DUE TO TECHNICAL";
		} elsif (me.selection == 5) {
			return "AT PILOTS DISCRETION";
		} else {
			return nil;
		}
	}
};

var freeTexts = [freeText.new(0), freeText.new(1)];