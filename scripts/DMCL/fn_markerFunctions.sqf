//XEPKEY_fnc_markerFunctions
//Function to 
//Params: NONE
//Returns: 
//	

//Variables
//Objective Marker Radius Range
_mkrRngLow = 50;
_mkrRngHigh = 300;

<<<<<<< Updated upstream
//Array for objective names
_objNamesArray = ["Albatross","Alpaca","Arcadia","Aegis","Arowana","Astral","Aurora","Bastion","Beacon","Catalyst","Cicada","Cipher","Citadel","Cobra","Crow","Dynamo","Eagle","Eclipse","Empyrean","Enigma","Falcon","Firefly","Goliath","Havoc","Hawk","Heron","Inferno","Kingfish","Lemur","Lion","Mallet","Mantis","Maverick","Mirage","Monolith","Nebula","Nexus","Nighthawk","Obsidian","Opah","Ostrich","Otter","Pantheon","Paradigm","Paragon","Pelican","Phoenix","Radiance","Rhino","Robin","Ruby","Sapphire","Seagull","Sparrow","Staple","Swift","Swan","Umbra","Vanguard","Velvet","Vertex","Vulture","Weevil","Zenith","Zebra"];

//Mission Timer Range (minutes)
_moTimeMin = 10;
_moTimeMax = 20;
=======
//Time Sensitive Mission check
LMO_TimeSenRNG = random 100;
if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
	LMO_TSTState = true;
	if (LMO_Debug) then {diag_log "Time Sensitive Mission Started."};
} else {
	LMO_TSTState = false;
};
>>>>>>> Stashed changes

//Create Ellipse Marker on Obj
objMarkerText = format ["OBJ %1", selectRandom _objNamesArray];
objMarkerRadius = [_mkrRngLow,_mkrRngHigh] call BIS_fnc_randomInt;
objMarkerPos = [[[position spawnBuilding, (objMarkerRadius/1.5)]], []] call BIS_fnc_randomPos;
objMarker = createMarker ["", objMarkerPos];
objMarker setMarkerShape "ELLIPSE";
objMarker setMarkerSize [objMarkerRadius,objMarkerRadius];
objMarker setMarkerBrush "FDiagonal";

//Set OBJ Marker Name & Timer
missionTimer = [((_moTimeMin)*60),((_moTimeMax)*60)] call BIS_fnc_randomInt;
missionTimerStr = [missionTimer, "MM:SS"] call BIS_fnc_secondsToString;
objMarkerName = createMarker ["Marker1", objMarkerPos];
objMarkerName setMarkerShape "ICON";
objMarkerName setMarkerSize [1,1];
objMarkerName setMarkerType "mil_unknown";
	
