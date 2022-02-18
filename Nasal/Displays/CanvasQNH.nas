# A3XX Canvas QNH
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

var QNH1 = nil;
var QNH2 = nil;

var QNHCanvasParent = {
	canvasQNH: nil,
	qnhGroup: nil,
	line1: nil,
	new: func(placement, tex) {
		var QNHCanvas = {parents: [QNHCanvasParent]};
		QNHCanvas.canvasQNH = canvas.new({
			"name": "QNH1",
			"size": [256, 128],
			"view": [256, 128],
			"mipmapping": 0
		});
		
		QNHCanvas.canvasQNH.addPlacement({"node": placement, "texture": tex});
		QNHCanvas.canvasQNH.setColorBackground(0.01, 0.075, 0.00, 1.00);
		QNHCanvas.qnhGroup = QNHCanvas.canvasQNH.createGroup();
		QNHCanvas.qnhGroup.show();
		QNHCanvas.line1 = QNHCanvas.qnhGroup.createChild("text")
			.setFontSize(13, 1)
			.setColor([0.45,0.98,0.06])
			.setAlignment("left-bottom-baseline")
			.setFont("Airbus7Seg.ttf")
			.setText("8888");
			
		return QNHCanvas;
	},
};

if (QNH1 == nil) {
	# QNH1 = QNHCanvasParent.new("efis_foil_display", "glare_sw.png");
}