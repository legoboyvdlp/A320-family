
#Font Mapper
var font_mapper = func(family, weight) {
	return "Orbitron/Orbitron-Bold.ttf";
};



var clamp = func(value,min=0.0,max=0.0){
	if(value < min) {value = min;}
	if(value > max) {value = max;}
	return value;
}

var MyWindow = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, type = nil, id = nil)
  {
    var ghost = canvas._newWindowGhost(id);
    var m = {
      parents: [MyWindow, canvas.PropertyElement, ghost],
      _node: props.wrapNode(ghost._node_ghost)
    };

    m.setInt("size[0]", size[0]);
    m.setInt("size[1]", size[1]);

    # TODO better default position
    m.move(0,0);

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);
    if( type )
      m.set("type", type);

    m._isOpen = 1;
    return m;
  },
  # Destructor
  del: func
  {
    me._node.remove();
    me._node = nil;

    if( me["_canvas"] != nil )
    {
      me._canvas.del();
      me._canvas = nil;
    }
     me._isOpen = 0;
  },
  # Create the canvas to be used for this Window
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size = [
      me.get("size[0]"),
      me.get("size[1]")
    ];

    me._canvas = canvas.new({
      size: [2 * size[0], 2 * size[1]],
      view: size,
      placement: {
        type: "window",
        id: me.get("id")
      }
    });

    me._canvas.addEventListener("mousedown", func me.raise());
    return me._canvas;
  },
  # Set an existing canvas to be used for this Window
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");

    canvas_.addPlacement({type: "window", index: me._node.getIndex()});
    me['_canvas'] = canvas_;
  },
  # Get the displayed canvas
  getCanvas: func()
  {
    return me['_canvas'];
  },
  getCanvasDecoration: func()
  {
    return canvas.wrapCanvas(me._getCanvasDecoration());
  },
  setPosition: func(x, y)
  {
    me.setInt("tf/t[0]", x);
    me.setInt("tf/t[1]", y);
  },
  move: func(x, y)
  {
    me.setInt("tf/t[0]", me.get("tf/t[0]", 10) + x);
    me.setInt("tf/t[1]", me.get("tf/t[1]", 30) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    # on writing the z-index the window always is moved to the top of all other
    # windows with the same z-index.
    me.setInt("z-index", me.get("z-index", 0));
  },
# private:
  _propCallback: func(child, mode)
  {
    if( !me._node.equals(child.getParent()) )
      return;
    var name = child.getName();

    # support for CSS like position: absolute; with right and/or bottom margin
    if( name == "right" )
      me._handlePositionAbsolute(child, mode, name, 0);
    else if( name == "bottom" )
      me._handlePositionAbsolute(child, mode, name, 1);

    # update decoration on type change
    else if( name == "type" )
    {
      if( mode == 0 )
        settimer(func me._updateDecoration(), 0);
    }
  },
  _handlePositionAbsolute: func(child, mode, name, index)
  {
    # mode
    #   -1 child removed
    #    0 value changed
    #    1 child added

    if( mode == 0 )
      me._updatePos(index, name);
    else if( mode == 1 )
      me["_listener_" ~ name] = [
        setlistener
        (
          "/sim/gui/canvas/size[" ~ index ~ "]",
          func me._updatePos(index, name)
        ),
        setlistener
        (
          me._node.getNode("size[" ~ index ~ "]"),
          func me._updatePos(index, name)
        )
      ];
    else if( mode == -1 )
      for(var i = 0; i < 2; i += 1)
        removelistener(me["_listener_" ~ name][i]);
  },
  _updatePos: func(index, name)
  {
    me.setInt
    (
      "tf/t[" ~ index ~ "]",
      getprop("/sim/gui/canvas/size[" ~ index ~ "]")
      - me.get(name)
      - me.get("size[" ~ index ~ "]")
    );
  },
  _onClose : func(){
	me.del();
  },
  _updateDecoration: func()
  {
    var border_radius = 9;
    me.set("decoration-border", "25 1 1");
    me.set("shadow-inset", int((1 - math.cos(45 * D2R)) * border_radius + 0.5));
    me.set("shadow-radius", 5);
    me.setBool("update", 1);

    var canvas_deco = me.getCanvasDecoration();
    canvas_deco.addEventListener("mousedown", func me.raise());
    canvas_deco.set("blend-source-rgb", "src-alpha");
    canvas_deco.set("blend-destination-rgb", "one-minus-src-alpha");
    canvas_deco.set("blend-source-alpha", "one");
    canvas_deco.set("blend-destination-alpha", "one");

    var group_deco = canvas_deco.getGroup("decoration");
    var title_bar = group_deco.createChild("group", "title_bar");
    title_bar
      .rect( 0, 0,
             me.get("size[0]"),
             me.get("size[1]"), #25,
             {"border-top-radius": border_radius} )
      .setColorFill(0.25,0.24,0.22)
      .setStrokeLineWidth(0);

    var style_dir = "gui/styles/AmbianceClassic/decoration/";

    # close icon
    var x = 10;
    var y = 3;
    var w = 19;
    var h = 19;
    var ico = title_bar.createChild("image", "icon-close")
                       .set("file", style_dir ~ "close_focused_normal.png")
                       .setTranslation(x,y);
    ico.addEventListener("click", func me._onClose());
    ico.addEventListener("mouseover", func ico.set("file", style_dir ~ "close_focused_prelight.png"));
    ico.addEventListener("mousedown", func ico.set("file", style_dir ~ "close_focused_pressed.png"));
    ico.addEventListener("mouseout",  func ico.set("file", style_dir ~ "close_focused_normal.png"));

    # title
    me._title = title_bar.createChild("text", "title")
                         .set("alignment", "left-center")
                         .set("character-size", 14)
                         .set("font", "Orbitron/Orbitron-Bold.ttf")
                         .setTranslation( int(x + 1.5 * w + 0.5),
                                          int(y + 0.5 * h + 0.5) );

    var title = me.get("title", "Canvas Dialog");
    me._node.getNode("title", 1).alias(me._title._node.getPath() ~ "/text");
    me.set("title", title);

    title_bar.addEventListener("drag", func(e) {
      if( !ico.equals(e.target) )
        me.move(e.deltaX, e.deltaY);
    });
  }
};

var COLOR = {};
COLOR["Red"] 			= "rgb(244,28,33)";
COLOR["Black"] 			= "#000000";


var SvgWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[SvgWidget]};
		m._class = "SvgWidget";
		m._dialog 	= dialog;
		m._listeners 	= [];
		m._name 	= name;
		m._group	= canvasGroup;
		return m;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	
};

var BatteryWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[BatteryWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "BatteryWidget";
		m._name		= name;
		
		if(m._name=="Front"){
			m._nLevelPct 	= props.globals.initNode("/systems/electrical/battery-charge-percent-front",0.0,"DOUBLE");
		}else{
			m._nLevelPct 	= props.globals.initNode("/systems/electrical/battery-charge-percent-back",0.0,"DOUBLE");
		}
		
		m._fraction	= m._nLevelPct.getValue();
		m._capacity	= 10.5; #10.5 kWh (per pack)
			
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cFrameV 	= m._group.getElementById(m._name~"_Frame_Vis");
		m._cLevel 	= m._group.getElementById(m._name~"_Charge_Level");
		m._cDataLevel 	= m._group.getElementById(m._name~"_Data_Level");
		m._cDataAbs 	= m._group.getElementById(m._name~"_Data_Abs");
				
		m._cDataLevel.setText(sprintf("%3d",m._fraction*100)~" %");
		m._cDataAbs.setText(sprintf("%3.1f",m._fraction*m._capacity)~" kWh");
		
		m._left		= m._cFrame.get("coord[0]");
		m._right	= m._cFrame.get("coord[2]");
		m._width	= m._right - m._left;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nLevelPct,func(n){me._onChargeLevelChange(n);},1,0) );
		
		me._cFrameV.addEventListener("drag",func(e){me._onChargeInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onChargeInputChange(e);});
		me._cFrameV.addEventListener("wheel",func(e){me._onChargeInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onChargeInputChange(e);});
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onChargeLevelChange : func(n){
		me._fraction	= n.getValue();
		
		me._cDataLevel.setText(sprintf("%3d",me._fraction*100)~" %");
		me._cDataAbs.setText(sprintf("%3.1f",me._fraction*me._capacity)~" kWh");
		
		me._cLevel.set("coord[2]", me._left + (me._width * me._fraction));
			
	},
	_onChargeInputChange : func(e){
		var newFraction = 0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._width);
		}else{
			newFraction = me._fraction + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._nLevelPct.setValue(newFraction);
		
	},
};


var WeightWidget = {
	new: func(dialog,canvasGroup,name,widgets){
		var m = {parents:[WeightWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "WeightWidget";
		m._widget = {};
		
		foreach(w;keys(widgets)){
			if(widgets[w] != nil){
				if(widgets[w]._class == "PayloadWidget"){
					m._widget[w] = widgets[w];
				}
			}
		}
		
		m._cWeightGrossKg 		= m._group.getElementById("Weight_Gross_Kg");
		m._cWeightGrossLbs 		= m._group.getElementById("Weight_Gross_Lbs");
		m._cWeightWarning	 	= m._group.getElementById("Weight_Warning");
		m._cWeightPilotKg		 = m._group.getElementById("Weight_Pilot_Kg");
		m._cWeightPilotLbs		 = m._group.getElementById("Weight_Pilot_Lbs");
		m._cWeightCopilotKg		 = m._group.getElementById("Weight_Copilot_Kg");
		m._cWeightCopilotLbs		 = m._group.getElementById("Weight_Copilot_Lbs");
		m._cWeightBaggageKg	 	= m._group.getElementById("Weight_Baggage_Kg");
		m._cWeightBaggageLbs	 	= m._group.getElementById("Weight_Baggage_Lbs");
		
		m._cCenterGravityX	 	= m._group.getElementById("Center_Gravity_X");
		m._cCenterGravityXWarning 	= m._group.getElementById("Center_Gravity_Warn");
		
		m._nCGx		= props.globals.initNode("/fdm/jsbsim/inertia/cg-x-mm-rp",0.0,"DOUBLE"); #calculated CG distance to reference point, set via system in Systems/dialogs.xml
		m._nGross 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nPilot 	= props.globals.initNode("/payload/weight[0]/weight-lb");
		m._nCopilot 	= props.globals.initNode("/payload/weight[1]/weight-lb");
		m._nBaggage 	= props.globals.initNode("/payload/weight[2]/weight-lb");
		m._nTakeoff 	= props.globals.initNode("/limits/mtow-lbs");
		
		
		m._cgX  	= 0;
		m._pilot 	= 0;
		m._copilot 	= 0;
		m._baggage 	= 0;
		m._gross 	= 0;
		m._takeoff  	= 0;
		
		m._takeoff = m._nTakeoff.getValue();
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(maintainance._nGrossWeight,func(n){me._onGrossWeightChange(n);},1,0) );
		append(me._listeners, setlistener(me._nCGx,func(n){me._onCGChange(n);},1,0) );
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onGrossWeightChange : func(n){
		
		me._gross = me._nGross.getValue();
		me._cWeightGrossKg.setText(sprintf("%5d",me._gross/KG2LB));
		me._cWeightGrossLbs.setText(sprintf("%4d",me._gross));
		
		me._pilot = me._nPilot.getValue();
		me._cWeightPilotKg.setText(sprintf("%5d",me._pilot/KG2LB));
		me._cWeightPilotLbs.setText(sprintf("%4d",me._pilot));
		
		me._copilot = me._nCopilot.getValue();
		me._cWeightCopilotKg.setText(sprintf("%5d",me._copilot/KG2LB));
		me._cWeightCopilotLbs.setText(sprintf("%4d",me._copilot));
		
		me._baggage = me._nBaggage.getValue();
		me._cWeightBaggageKg.setText(sprintf("%5d",me._baggage/KG2LB));
		me._cWeightBaggageLbs.setText(sprintf("%4d",me._baggage));
		
		
		if (me._gross > me._takeoff){
			me._cWeightWarning.show();
			me._cWeightGrossKg.setColor(COLOR["Red"]);
			me._cWeightGrossLbs.setColor(COLOR["Red"]);
		}else{
			me._cWeightWarning.hide();
			me._cWeightGrossKg.setColor(COLOR["Black"]);
			me._cWeightGrossLbs.setColor(COLOR["Black"]);
		}
		
		
	},
	_onCGChange : func(n){
		
		me._cgX = me._nCGx.getValue();
		
 		me._cCenterGravityX.setTranslation((me._cgX-200),0);
 		
 		if(me._cgX>195 and me._cgX<368){
			me._cCenterGravityXWarning.hide();
		}else{
			me._cCenterGravityXWarning.show();
		}
		
	},
	
	
	
};

var PayloadWidget = {
	new: func(dialog,canvasGroup,name,index){
		var m = {parents:[PayloadWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "PayloadWidget";
		m._index 	= index;
		
		#debug.dump(m._listCategoryKeys);
		
		m._nRoot	= props.globals.getNode("/payload/weight["~m._index~"]");
		m._nLable 	= m._nRoot.initNode("name","","STRING");
		
		### HACK : listener on /payload/weight[0]/weight-lb not working
		###	   two props one for fdm(weight-lb) one for dialog(nt-weight-lb) listener
		m._nWeightFdm 	= m._nRoot.initNode("weight-lb",0.0,"DOUBLE");
		m._weight	= m._nWeightFdm.getValue(); # lbs
		m._nWeight 	= m._nRoot.initNode("nt-weight-lb",m._weight,"DOUBLE");
		
		m._nCapacity 	= m._nRoot.initNode("max-lb",0.0,"DOUBLE");
		
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._weight / m._capacity;
		
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cFrame_Pick 	= m._group.getElementById(m._name~"_Frame_Pick");
		m._cLevel 	= m._group.getElementById(m._name~"_Level");
		m._cLBS 	= m._group.getElementById(m._name~"_Lbs");
		m._cKG		= m._group.getElementById(m._name~"_Kg");
	
		m._cLBS.setText(sprintf("%3.0f",m._weight));
		m._cKG.setText(sprintf("%3.0f",m._weight));
				
		
		m._left		= m._cFrame.get("coord[0]");
		m._right	= m._cFrame.get("coord[2]");
		m._width	= m._right - m._left;
		
		return m;
	},
	setListeners : func(instance) {
		### FIXME : use one property remove the HACK
		append(me._listeners, setlistener(me._nWeight,func(n){me._onWeightChange(n);},1,0) );
		
		me._cFrame_Pick.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cFrame_Pick.addEventListener("wheel",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onInputChange(e);});
		
			
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	setWeight : func(weight){
		me._weight = weight;
		
		### HACK : set two props 
		me._nWeight.setValue(me._weight);
		me._nWeightFdm.setValue(me._weight);
		
	},
	_onWeightChange : func(n){
		me._weight	= me._nWeight.getValue();
		#print("PayloadWidget._onWeightChange() ... "~me._weight);
		
		me._fraction	= me._weight / me._capacity;
		
		me._cLBS.setText(sprintf("%3.0f",me._weight));
		me._cKG.setText(sprintf("%3.0f",me._weight/KG2LB));
		
		me._cLevel.set("coord[2]", me._left + (me._width * me._fraction));
	},
	_onInputChange : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._width);
		}else{
			newFraction = me._fraction + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._weight = me._capacity * newFraction;
		
		me.setWeight(me._weight);

	},
};


var maintainanceClass = {
	new : func(){
		var m = {parents:[maintainanceClass]};
		m._nRoot 	= props.globals.initNode("/alphaelectro/dialog/config");
		
		m._nGrossWeight	= props.globals.initNode("/fdm/jsbsim/inertia/nt-weight-lbs",0.0,"DOUBLE"); #listener on weight-lbs not possible, set via system in Systems/fuelpayload.xml
		
		m._name  = "Maintainance";
		m._title = "Maintainance";
		m._fdmdata = {
			grosswgt : "/fdm/jsbsim/inertia/weight-lbs",
			payload  : "/payload",
			cg       : "/fdm/jsbsim/inertia/cg-x-in",
		};
		
		
		m._listeners = [];
		m._dlg 		= nil;
		m._canvas 	= nil;
		
		m._isOpen = 0;
		m._isNotInitialized = 1;
		
		m._widget = {
			Front	 	: nil,
			Rear	 	: nil,
			Pilot	 	: nil,
			Copilot		: nil,
			Baggage	 	: nil,
			weight	 	: nil,
		};
		

		return m;
	},
	toggle : func(){
		if(me._dlg != nil){
			if (me._dlg._isOpen){
				me.close();
			}else{
				me.open();	
			}
		}else{
			me.open();
		}
	},
	close : func(){
		me._dlg.del();
		me._dlg = nil;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
	
		
	},
	_onClose : func(){
		me.removeListeners();
		me._dlg.del();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
				me._widget[widget] = nil;
			}
		}
		
	},
	open : func(){
		if(getprop("/gear/gear[1]/wow") == 1){
			me.openBAP();
		}else{
			screen.log.write("Maintainance dialog not available in air!");
		}
		
	},
	openBAP : func(){
		
		
		me._dlg = MyWindow.new([1024, 512], "dialog");
		me._dlg._onClose = func(){
			maintainance._onClose();
		}
		me._dlg.set("title", "Maintainance");
		me._dlg.move(100,100);
		
		
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#c5c5c5ff");
		
		me._group = me._canvas.createGroup();

		canvas.parsesvg(me._group, "Aircraft/A320-family/gui/dialogs/maintainance.svg",{"font-mapper": font_mapper});
		
		
		
		me._widget.Front 		= BatteryWidget.new(me,me._group,"Front");
		me._widget.Rear 		= BatteryWidget.new(me,me._group,"Rear");

		me._widget.Pilot		= PayloadWidget.new(me,me._group,"Pilot",0);
		me._widget.Copilot		= PayloadWidget.new(me,me._group,"Copilot",1);
		me._widget.Baggage		= PayloadWidget.new(me,me._group,"Baggage",2);
		
		me._widget.weight = WeightWidget.new(me,me._group,"Weight",me._widget);
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].init();
			}
		}
		
		
	},
	_onNotifyChange : func(n){

	},
	
};

var maintainance = maintainanceClass.new();
