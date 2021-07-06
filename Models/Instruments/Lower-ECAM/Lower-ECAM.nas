# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var SystemDisplayPageRecipient =
{
	new: func(_ident)
	{
		var SDRecipient = emesary.Recipient.new(_ident);
		SDRecipient.MainScreen = canvas_lowerECAM_base;
		SDRecipient.Page = nil;
		SDRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (SDRecipient.Page == nil) {
					SDRecipient.Page = SystemDisplayPageRecipient.pageList.apu;
				}
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					SDRecipient.Page.update(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return SDRecipient;
	},
	pageList: {
		apu: canvas_lowerECAMPageApu.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/apu.svg"),
	},
};

var A320SD = SystemDisplayPageRecipient.new("A320 SD");
emesary.GlobalTransmitter.Register(A320SD);

var input = {
	gForce: "/accelerations/pilot-gdamped",
	gForceDisplay: "/ECAM/Lower/g-force-display",
	hour: "/sim/time/utc/hour",
	minute: "/sim/time/utc/minute",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}

setlistener("/systems/electrical/bus/ac-2", func() {
	A320SD.MainScreen.powerTransient();
}, 0, 0);