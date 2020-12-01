# A3XX Canvas QRH
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

var QRHpageNo = props.globals.initNode("/canvas/canvasQRH/page-number", 1, "INT");

var _pageNo = 1;
var _MAXPAGE = 3;

var width = 550;
var height = 625;

var QRH = nil;

var prevPage = func() {
	_pageNo = QRHpageNo.getValue();
	if (_pageNo == 1) { return; }
	QRHpageNo.setValue(_pageNo - 1);
};

var nextPage = func() {
	_pageNo = QRHpageNo.getValue();
	if (_pageNo == _MAXPAGE) { return; }
	QRHpageNo.setValue(_pageNo + 1);
};


var createCanvasQRH = func() {
	var window = canvas.Window.new([width,height],"dialog")
		.set("title","A320 QRH");
		
	var qrhCanvas = window.createCanvas().set("background", canvas.style.getColor("bg_color"));
	var root = qrhCanvas.createGroup();

	var myHBox = canvas.HBoxLayout.new();
	qrhCanvas.setLayout(myHBox);

	QRH = canvas.gui.widgets.Label.new(root, canvas.style, {} )
		.setImage(resolvepath("Aircraft/A320-family/Models/FlightDeck/QRH/" ~ QRHpageNo.getValue() ~ ".jpeg"))
		.move(0,-25)
		.setSize(400,625);
	myHBox.addItem(QRH);

	var verticalGroup = canvas.VBoxLayout.new();
	myHBox.addItem(verticalGroup);
	
	var buttonInc = canvas.gui.widgets.Button.new(root, canvas.style, {})
		.setText("Size Up")
		.setFixedSize(75,25);
	var buttonReset = canvas.gui.widgets.Button.new(root, canvas.style, {})
		.setText("Reset Size")
		.setFixedSize(75,25);
	var buttonDec = canvas.gui.widgets.Button.new(root, canvas.style, {})
		.setText("Size Down")
		.setFixedSize(75,25);
	var buttonPrev = canvas.gui.widgets.Button.new(root, canvas.style, {})
		.setText("Prev Page")
		.setFixedSize(75,25);
	var buttonNext = canvas.gui.widgets.Button.new(root, canvas.style, {})
		.setText("Next Page")
		.setFixedSize(75,25);

	buttonInc.listen("clicked", func {
		width = width * 1.10;
		height = height * 1.10;
		window.setSize(width, height);
	});
	buttonReset.listen("clicked", func {
		width = 550;
		height = 650;
		window.setSize(width, height);
	});
	buttonDec.listen("clicked", func {
		width = width * 0.91;
		height = height * 0.91;
		window.setSize(width, height);
	});
	buttonPrev.listen("clicked", func {
		prevPage();
		QRH.setImage(resolvepath("Aircraft/A320-family/Models/FlightDeck/QRH/" ~ QRHpageNo.getValue() ~ ".jpeg"));
	});
	buttonNext.listen("clicked", func {
		nextPage();
		QRH.setImage(resolvepath("Aircraft/A320-family/Models/FlightDeck/QRH/" ~ QRHpageNo.getValue() ~ ".jpeg"));
	});


	verticalGroup.addItem(buttonInc);
	verticalGroup.addItem(buttonReset);
	verticalGroup.addItem(buttonDec);
	verticalGroup.addItem(buttonPrev);
	verticalGroup.addItem(buttonNext);
}