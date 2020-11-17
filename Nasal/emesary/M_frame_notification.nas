 #---------------------------------------------------------------------------
 #
 # Title                : Emesary based rt exec frame  notifications
 #
 # File Type            : Implementation File
 #
 # Description          : Uses emesary notifications to permit nasal subsystems to be notified each frame. 
 #                       : A frame is defined by the timer rate; which is usually the maximum rate as determined by the FPS.
 #                       : This is an alternative to the timer based or explicit function calling way of invoking
 #                       : aircraft systems.
 #                       : It has the advantage of using less timers and remaining modular, as each aircraft subsytem
 #                       : can simply register itself with the global transmitter to receive the frame notification.
 #
 # Author               : Richard Harrison (richard@zaretto.com)
 #
 # Creation Date        : 4 June 2018
 #
 # Version              : 1.0
 #
 # Copyright (C) 2018 Richard Harrison           Released under GPL V2
 #
 #---------------------------------------------------------------------------*/


var FrameNotification = 
{
 debug: 0,
    new: func(_rate)
    {
        var new_class = emesary.Notification.new("FrameNotification", _rate);
        new_class.Rate = _rate;
        new_class.FrameRate = 60;
        new_class.FrameCount = 0;
        new_class.ElapsedSeconds = 0;
        new_class.monitored = {};
        new_class.properties = {};

        #
        # embed a recipient within this notification to allow the monitored property
        # mapping list to be modified.
        new_class.Recipient = emesary.Recipient.new("FrameNotification");
        new_class.Recipient.Receive = func(notification)
        {
            if (notification.NotificationType == "FrameNotificationAddProperty")
            {
                var root_node = props.globals;
                if (notification.root_node != nil) {
                    root_node = notification.root_node;
                }
                if (new_class.properties[notification.property] != nil 
                    and new_class.properties[notification.property] != notification.variable)
                  print("[WARNING]: (",notification.module,") FrameNotification: already have variable ",new_class.properties[notification.property]," for ",notification.variable, " referencing property ",notification.property);

                if (new_class.monitored[notification.variable] != nil 
                    and new_class.monitored[notification.variable].getPath() != notification.property
                    and new_class.monitored[notification.variable].getPath() != "/"~notification.property)
                  print("[WARNING]: (",notification.module,") FrameNotification: already have variable ",notification.variable,"=",new_class.monitored[notification.variable].getPath(), " using different property ",notification.property);
                #                else if (new_class.monitored[notification.variable] == nil)
                #                  print("[INFO]: (",notification.module,") FrameNotification.",notification.variable, " = ",notification.property);

                new_class.monitored[notification.variable] = root_node.getNode(notification.property,1);
                new_class.properties[notification.property] = notification.variable;

                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        new_class.fetchvars = func() {
            foreach (var mp; keys(new_class.monitored)){
                if(new_class.monitored[mp] != nil){
                    if (FrameNotification.debug > 1)
                      print(" ",mp, " = ",new_class.monitored[mp].getValue());
                    new_class[mp] = new_class.monitored[mp].getValue();
                }
            }
        };
        emesary.GlobalTransmitter.Register(new_class.Recipient);
        return new_class;
    },
};

var FrameNotificationAddProperty = 
{
    new: func(module, variable, property, root_node=nil)
    {
        var new_class = emesary.Notification.new("FrameNotificationAddProperty", variable);
        if (root_node == nil)
          root_node = props.globals;
        new_class.module = module ;
        new_class.variable = variable;
        new_class.property = property;
        new_class.root_node = root_node;
        return new_class;
    },
};
#    
var frameNotification = FrameNotification.new(1);


# Frame count
# 5 = ECAM
# 7 = FWC phases
# 10 = ECAM messages