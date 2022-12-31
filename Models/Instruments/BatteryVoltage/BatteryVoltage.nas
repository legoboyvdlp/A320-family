# A3XX IESI

# Copyright (c) 2023 Josh Davidson (Octal450)

var canvas_battery = {
	new: func(name, num) {
		var obj = {parents: [canvas_battery] };
		obj.canvas = canvas.new({
			"name": "Battery",
			"size": [600, 256],
			"view": [600, 256],
			"mipmapping": 1,
		});
		
		obj.canvas.addPlacement({"node": "batt_voltage.canvas." ~ (num == 0 ? "L" : "R")});
        obj.group = obj.canvas.createGroup();
		
		obj.text = obj.group.createChild("text", "optional-id-for element");
		obj.text.setText("28.8V");
        obj.text.setTranslation(50, 128);
        obj.text.setAlignment("left-center");
        obj.text.setFont("Airbus7Seg.ttf");
		obj.text.setFontSize(180);
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("annunTest", 1, func(val) {
				obj.test = val;
			}),
		];
		
		if (num == 0) {
			append(obj.update_items, props.UpdateManager.FromHashValue("dcHot1", 0.05, func(val) {
				obj.voltage = sprintf("%4.1fV", val);
			}));
		} else {
			append(obj.update_items, props.UpdateManager.FromHashValue("dcHot2", 0.05, func(val) {
				obj.voltage = sprintf("%4.1fV", val);
			}));
		}
		
		return obj;
	},
	update: func(notification) {
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		if (me.test) {
			me.text.setText("88.8V");
		} else {
			me.text.setText(me.voltage);
		}
	},
};

var BatteryRecipient =
{
	new: func(_ident, num)
	{
		var NewIESIRecipient = emesary.Recipient.new(_ident);
		NewIESIRecipient.MainScreen = nil;
		NewIESIRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (NewIESIRecipient.MainScreen == nil) {
					NewIESIRecipient.MainScreen = canvas_battery.new("A320 Battery", num);
				}
				
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					NewIESIRecipient.MainScreen.update(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return NewIESIRecipient;
	},
};

var A320BatteryL = BatteryRecipient.new("A320 Battery", 0);
var A320BatteryR = BatteryRecipient.new("A320 Battery", 1);
emesary.GlobalTransmitter.Register(A320BatteryL);
emesary.GlobalTransmitter.Register(A320BatteryR);
