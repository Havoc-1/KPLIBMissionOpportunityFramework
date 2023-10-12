//XEPKEY_fnc_markerFunctions
//Function to 
//Params: NONE
//Returns: 
//	

//Variables

//Array for objective names
_objNamesArray = ["Albatross","Alpaca","Arcadia","Aegis","Arowana","Astral","Aurora","Bastion","Beacon","Catalyst","Cicada","Cipher","Citadel","Cobra","Crow","Dynamo","Eagle","Eclipse","Empyrean","Enigma","Falcon","Firefly","Goliath","Havoc","Hawk","Heron","Inferno","Kingfish","Lemur","Lion","Mallet","Mantis","Maverick","Mirage","Monolith","Nebula","Nexus","Nighthawk","Obsidian","Opah","Ostrich","Otter","Pantheon","Paradigm","Paragon","Pelican","Phoenix","Radiance","Rhino","Robin","Ruby","Sapphire","Seagull","Sparrow","Staple","Swift","Swan","Umbra","Vanguard","Velvet","Vertex","Vulture","Weevil","Zenith","Zebra"];

//Create Ellipse Marker on Obj
objMarkerText = format ["OBJ %1", selectRandom _objNamesArray];
objMarkerRadius = [mkrRngLow,mkrRngHigh] call BIS_fnc_randomInt;
objMarkerPos = [[[position spawnBuilding, (objMarkerRadius/1.5)]], []] call BIS_fnc_randomPos;
objMarker = createMarker ["", objMarkerPos];
objMarker setMarkerShape "ELLIPSE";
objMarker setMarkerSize [objMarkerRadius,objMarkerRadius];
objMarker setMarkerBrush "FDiagonal";

//Set OBJ Marker Name & Timer
missionTimer = [((moTimeMin)*60),((moTimeMax)*60)] call BIS_fnc_randomInt;
missionTimerStr = [missionTimer, "MM:SS"] call BIS_fnc_secondsToString;
objMarkerName = createMarker ["Marker1", objMarkerPos];
objMarkerName setMarkerShape "ICON";
objMarkerName setMarkerSize [1,1];
objMarkerName setMarkerType "mil_unknown";