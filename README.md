# A320-family
A very advanced simulation of the Airbus A320 Family for FlightGear.

- Flight Dynamics: Josh Davidson (Octal450)</label>
- Systems: Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp), merspieler, Matthew Maring (mattmaring)</label>
- Displays: Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp), merspieler, Matthew Maring (mattmaring)</label>
- 3D/Textures: Thorsten Herrmann (TH-555), Semir Gebran (CaptB)</label>

Present pack includes the following Airbus A320 Family variants:
- A320-111
- A320-214
- A320-232
- A320-251N
- A320-271N


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

## External tools
Some external tools you might want to checkout and use with this Model.  
NOTE: These are external tools so make sure to check their terms of use
* [Trim Calculator (for FSLabs, but will work for us)](https://forums.flightsimlabs.com/index.php?/files/file/675-a320x-trim-calculation-tool/)
* [Take off performance calculator (excel)](https://forums.flightsimlabs.com/index.php?/files/file/763-a320-takeoff-and-landing-performance-calculator/)
* [Take off performance calculator (.exe -- different to above) ](http://www.avsimrus.com/f/for-pilots-19/popular-calculator-to-calculate-takeoff-parameters-in-from-airbus-type-36340.html)
* [Air Berlin Normal Checklist](https://forums.flightsimlabs.com/index.php?/files/file/778-airberlin-normal-procedures-checklist/)
* [Navdata hosted by pinto](https://github.com/l0k1/fg-navaiddata)
* [A320 Normal Procedures](https://www.theairlinepilots.com/forumarchive/a320/a320-normal-procedures.pdf)
* [A319/A320 Concise Checklist](https://forums.x-plane.org/index.php?/files/file/50904-toliss-a319-concise-checklist-pdf/) (you will need a free xplane.org account)
<!--* [Take off performance calculator (online)](http://wabpro.cz/A320/)-->
