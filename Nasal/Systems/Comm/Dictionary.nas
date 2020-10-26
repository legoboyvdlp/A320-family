# A3XX Dictionary
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var DictionaryItemObj = {
	new: func(item, string) {
		var DI = {parents: [DictionaryItemObj]};
		DI.item = item;
		DI.string = string;
		return DI;
	},
};

var DictionaryObj = {
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

var makeNewDictionaryItem = func(item, string) {
	var dictItem = DictionaryItemObj.new(item, string);
	DictionaryObj.addToDatabase(dictItem);
};

var DictionaryItemString = {
	new: func(string1, string2) {
		var DI = {parents: [DictionaryItemString]};
		DI.string1 = string1;
		DI.string2 = string2;
		return DI;
	},
};

var DictionaryString = {
	database: std.Vector.new(),
	addToDatabase: func(dictItem) {
		me.database.append(dictItem);
	},
	fetchString1: func(stringSearch) {
		foreach (var item; me.database.vector) {
			if (string.uc(item.string1) == string.uc(stringSearch)) {
				return item;
			}
		}
		return "";
	},
	fetchString2: func(stringSearch) {
		foreach (var item; me.database.vector) {
			if (string.uc(item.string2) == string.uc(stringSearch)) {
				return item;
			}
		}
		return "";
	},
};

var makeNewDictionaryString = func(string1, string2) {
	var dictItem = DictionaryItemString.new(string1, string2);
	DictionaryString.addToDatabase(dictItem);
};