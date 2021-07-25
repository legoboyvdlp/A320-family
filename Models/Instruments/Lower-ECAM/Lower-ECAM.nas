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
					SDRecipient.Page = SystemDisplayPageRecipient.pageList.door;
				}
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					SystemDisplayPageRecipient.pageList.apu.update(notification);
					SystemDisplayPageRecipient.pageList.bleed.update(notification);
					SystemDisplayPageRecipient.pageList.cond.update(notification);
					SystemDisplayPageRecipient.pageList.cruise.update(notification);
					SystemDisplayPageRecipient.pageList.door.update(notification);
					SystemDisplayPageRecipient.pageList.elec.update(notification);
					SystemDisplayPageRecipient.pageList.eng.update(notification);
					SystemDisplayPageRecipient.pageList.fctl.update(notification);
					SystemDisplayPageRecipient.pageList.fuel.update(notification);
					SystemDisplayPageRecipient.pageList.hyd.update(notification);
					SystemDisplayPageRecipient.pageList.press.update(notification);
					SystemDisplayPageRecipient.pageList.sts.update(notification);
					SystemDisplayPageRecipient.pageList.wheel.update(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return SDRecipient;
	},
	pageList: {
		apu: canvas_lowerECAMPageApu.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/apu.svg","apu"),
		bleed: canvas_lowerECAMPageBleed.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/bleed.svg","bleed"),
		cond: canvas_lowerECAMPageCond.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/cond.svg","cond"),
		cruise: canvas_lowerECAMPageCruise.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/crz.svg","cruise"),
		door: canvas_lowerECAMPageDoor.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/door.svg","door"),
		elec: canvas_lowerECAMPageElec.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/elec.svg","elec"),
		eng: canvas_lowerECAMPageEng.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/eng.svg","eng"),
		fctl: canvas_lowerECAMPageFctl.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/fctl.svg","fctl"),
		fuel: canvas_lowerECAMPageFuel.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/fuel.svg","fuel"),
		hyd: canvas_lowerECAMPageHyd.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/hyd.svg","hyd"),
		press: canvas_lowerECAMPagePress.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/press.svg","press"),
		sts: canvas_lowerECAMPageSts.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/status.svg","sts"),
		wheel: canvas_lowerECAMPageWheel.new("Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/wheel.svg","wheel")
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

var showLowerECAM = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(canvas_lowerECAM_base.canvas);
}

setlistener("/systems/electrical/bus/ac-2", func() {
	A320SD.MainScreen.powerTransient();
}, 0, 0);