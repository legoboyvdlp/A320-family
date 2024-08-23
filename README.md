# A320-family - Development on hold

Main development is on hold awaiting refactoring. However, this is the newest version and still receives fixes and minor improvements.

A very advanced simulation of the Airbus A320 Family for FlightGear.

Present pack includes the following Airbus A320 Family variants:
- A320-214 (CFM56)
- A320-232 (IAE V2500)
- A320-251N (CFM Leap)
- A320-271N (PW1100G)

You can find a Checklist to download and print [here](https://raw.githubusercontent.com/legoboyvdlp/A320-family/dev/checklist.pdf)

## Navdata
It is highly reccomended to purchase a NAVIGRAPH subscription and download their level d FMSDATA / waypoint / navaid data! If you do not wish to do that, there is older data linked below. But it won't have most of the newer procedures, and is only for a limited number of airports, as naturally it is not possible to distribute commercial data. If runway numbering changed, it is quite possible that it will not work due to FlightGear limitations in the routing code.

To install navdata, create a folder FMSDATA, and add it to your additional scenery folders, at the top of the list. Inside that folder, place all the XXXX.procedures.xml files, in the format FMSDATA/X/X/X/XXXX.procedures.xml. For instance, FMSDATA/Airports/E/G/K/EGKK.procedures.xml. 

## Remote MCDU
If you want to run the MCDU on a your smarthphone or tablet for better realism and easier input, run FlightGear with enabled HTTP server (i.e. command line --httpd=<Port; e.g. 8080>) then go to main menu -> Instruments -> Remote MCDU.
You can generate a QR-code to lauch directly on your smartphone/tablet, first insert your local ip. Your device must run on the same local network of your computer.

## Installation
If you have issues installing, please check INSTALL.MD!
Specifically, make sure you remove -dev from the folder name!

## Hardware configuration
Here are bindings for commonly used buttons

### FO Sidestick
Bind the axis to:
* elevator: `/controls/flight/elevator[1]`
* aileron: `/controls/flight/aileron[1]`

### AP Disconnect
```
  <button n="X">
    <desc type="string">Custom</desc>
    <binding>
      <command type="string">nasal</command>
      <script type="string">
        fcu.FCUController.APDisc(side=1, press=1);
        </script>
      <module type="string">__js3</module>
      <offset type="double">1</offset>
    </binding>
    <mod-up>
         <binding>
           <command type="string">nasal</command>
                <script type="string">
                  fcu.FCUController.APDisc(side=1, press=0);
                  </script>
           <module type="string">__js3</module>
           <offset type="double">1</offset>
         </binding>
    </mod-up>
    <repeatable type="double">0</repeatable>
  </button>
```
For the FO Sidestick, use `side=2`

### A/THR Disconnect
```
  <button n="X">
    <desc type="string">A/THR Disc</desc>
    <binding>
      <command type="string">nasal</command>
      <script type="string">
        fcu.FCUController.ATDisc();
      </script>
    </binding>
  </button>
```

### ENG Mode Selector
```
	<button n="6">
		<desc type="string">ENG Mode Crank</desc>
		<repeatable type="string">false</repeatable>
		<binding>
			<command>property-assign</command>
			<property>controls/ignition/start-sw</property>
			<value>0</value>
		</binding>
		<mod-up>
			<binding>
				<command>property-assign</command>
				<property>controls/ignition/start-sw</property>
				<value>1</value>
			</binding>
		</mod-up>
	</button>
	<button n="7">
		<desc type="string">ENG Mode Start</desc>
		<repeatable type="string">false</repeatable>
		<binding>
			<command>property-assign</command>
			<property>controls/ignition/start-sw</property>
			<value>2</value>
		</binding>
		<mod-up>
			<binding>
				<command>property-assign</command>
				<property>controls/ignition/start-sw</property>
				<value>1</value>
			</binding>
		</mod-up>
	</button>
```

If you only want these bindings for the A320 family,
add the following to the script:
```
if (string.match(getprop("/sim/aero"), "A3[12][0189]*"))
{
	<command-above>
}
else
{
	<other-command>
}
```

## External tools
Some external tools you might want to checkout and use with this Model.  
NOTE: These are external tools so make sure to check their terms of use
* [Trim Calculator (for FSLabs, but will work for us)](https://forums.flightsimlabs.com/index.php?/files/file/675-a320x-trim-calculation-tool/)
* [Take off performance calculator (excel)](https://forums.flightsimlabs.com/index.php?/files/file/763-a320-takeoff-and-landing-performance-calculator/)
* [Take off performance calculator (.exe -- different to above) ](http://www.avsimrus.com/f/for-pilots-19/popular-calculator-to-calculate-takeoff-parameters-in-from-airbus-type-36340.html)
* [Air Berlin Normal Checklist](https://forums.flightsimlabs.com/index.php?/files/file/778-airberlin-normal-procedures-checklist/)
* [Navdata hosted by jojo2357](https://github.com/jojo2357/flightgear-star-sid-manager)
* [Navdata hosted by pinto](https://github.com/l0k1/fg-navaiddata)
* [A320 Normal Procedures](https://www.theairlinepilots.com/forumarchive/a320/a320-normal-procedures.pdf)
* [A319/A320 Concise Checklist](https://forums.x-plane.org/index.php?/files/file/50904-toliss-a319-concise-checklist-pdf/) (you will need a free xplane.org account)
<!--* [Take off performance calculator (online)](http://wabpro.cz/A320/)-->
