# A3XX CPDLC
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var CPDLCmessage = {
	new: func(text) {
		var cpdlcMessage = {parents: [CPDLCmessage] };
		cpdlcMessage.text = text;
		return cpdlcMessage;
	},
};

makeNewDictionaryItem(CPDLCmessage.new("CONNECT"), "CONNECT");