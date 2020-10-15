# A3XX CPDLC
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var DictionaryItem = {
	new: func(item, string) {
		var DI = {parents: [DictionaryItem]};
		DI.item = item;
		DI.string = string;
		return DI;
	},
};

var Dictionary = {
	database: std.Vector.new(),
	addToDatabase: func(dictItem) {
		me.database.append(dictItem);
	},
	fetchString: func(string) {
		foreach (var item; me.database.vector) {
			if (me.item.string == string) {
				return item;
			}
		}
	},
	fetchItem: func(itemObj) {
		foreach (var item; me.database.vector) {
			if (item.item == itemObj) {
				return item;
			}
		}
	},
};

makeNewDictionaryItem = func(item, string) {
	var dictItem = DictionaryItem.new(item, string);
	Dictionary.addToDatabase(dictItem);
};

var CPDLCmessage = {
	new: func(text) {
		var cpdlcMessage = {parents: [CPDLCmessage] };
		cpdlcMessage.text = text;
		return cpdlcMessage;
	},
};

makeNewDictionaryItem(CPDLCmessage.new("CONNECT"), "CONNECT");