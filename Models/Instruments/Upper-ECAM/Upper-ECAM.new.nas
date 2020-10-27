var canvas_upperECAM = {
	new: func(svg) {
		var obj = {parents: [canvas_upperECAM] };
		obj.canvas = canvas.new({
			"name": "upperECAM",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1,
		});
		
		obj.canvas.addPlacement({"node": "uecam.screen"});
        obj.group = obj.canvas.createGroup();
		
		obj.font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		
		foreach(var key; obj.getKeys()) {
			obj[key] = obj.group.getElementById(key);
			
			var clip_el = obj.group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();

				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1],
				tran_rect[2],
				tran_rect[3],
				tran_rect[0]);
				obj[key].set("clip", clip_rect);
				obj[key].set("clip-frame", canvas.Element.PARENT);
			}
		};
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("fuelTotalLbs", 1, func(val) {
				if (acconfig_weight_kgs.getValue())
				{
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
					obj["FOB-weight-unit"].setText("KG");
				} else {
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val, 10)));
					obj["FOB-weight-unit"].setText("LBS");
				}
			}),
			props.UpdateManager.FromHashList(["AcEssBus", "DisplayBrightness"], 0.01, func(val) {
				if (val.DisplayBrightness > 0.01 and val.AcEssBus >= 110) {
					obj.group.setVisible(1);
				} else {
					obj.group.setVisible(0);
				}
			}),
		];
		
		obj.page = obj.group;
		return obj;
	},
	getKeys: func() {
		return ["N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-box","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N11-XX2","N11-XX-box","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick",
		"EGT1-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal","N12-box","N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N12-XX2","N12-XX-box","EGT2-needle","EGT2",
		"EGT2-scale","EGT2-box","EGT2-scale2","EGT2-scaletick","EGT2-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","N1Lim-mode","N1Lim","N1Lim-decpnt","N1Lim-decimal","N1Lim-percent","N1Lim-XX","N1Lim-XX2","REV1",
		"REV1-box","REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8","ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FOB-weight-unit","FFlow-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine","aFloor","FlxLimDegreesC","FlxLimTemp"];
	},
	update: func(notification) {
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
	},
};

var UpperECAMRecipient =
{
	new: func(_ident)
	{
		var new_class = emesary.Recipient.new(_ident);
		new_class.MainScreen = nil;
		new_class.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (new_class.MainScreen == nil)
					new_class.MainScreen = canvas_upperECAM.new("Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/cfm-eis2.svg", "A320 Upper ECAM CFM");
					if (!math.mod(notifications.frameNotification.FrameCount,2)){
						new_class.MainScreen.update(notification);
					}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return new_class;
	},
};

emesary.GlobalTransmitter.Register(UpperECAMRecipient.new("A320 Upper ECAM"));

input = {
	fuelTotalLbs: "/consumables/fuel/total-fuel-lbs",
	AcEssBus: "/systems/electrical/bus/ac-ess",
	DisplayBrightness: "/controls/lighting/DU/du3",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 Upper ECAM", name, input[name]));
}

setlistener("/sim/signals/fdm-initialized", func() {
	execLoop();
}, 0, 0);