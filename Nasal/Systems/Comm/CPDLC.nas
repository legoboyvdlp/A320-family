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

makeNewDictionaryItem(CPDLCmessage.new("CONNECT",0), "CONNECT");


makeNewDictionaryItem(CPDLCmessage.new("WILCO",0), "WILCO");
makeNewDictionaryItem(CPDLCmessage.new("UNABLE",0), "UNABLE");
makeNewDictionaryItem(CPDLCmessage.new("STANDBY",0), "STANDBY");
makeNewDictionaryItem(CPDLCmessage.new("ROGER",0), "ROGER");
makeNewDictionaryItem(CPDLCmessage.new("AFFIRM",0), "AFFIRM");
makeNewDictionaryItem(CPDLCmessage.new("NEGATIVE",0), "NEGATIVE");


makeNewDictionaryItem(CPDLCmessage.new("REQUEST ALTITUDE",0), "REQUEST ALTITUDE");

var freeText = {
	new: func(index) {
		var freeTextObj = {parents: [freeText]};
		freeTextObj.index = index;
		return freeTextObj;
	},
	selection: 9,
	changed: 0,
};

var freeTexts = [freeText.new(0), freeText.new(1)];