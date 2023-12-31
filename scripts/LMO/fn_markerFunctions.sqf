/*
 * Function to create objective marker and choose objective name
 * 
 * Return Value: 
 * NONE
 *
 * Example:
 * [] call LMO_fn_markerFunctions
 *
 */

//Variables
//Array for objective names
private _objNamesArray = ["Aegis", "Astral", "Aurora", "Albatross", "Alpaca", "Arcadia", "Arowana", "Bastion", "Beacon", "Catalyst", "Cicada", "Chimera", "Cipher", "Citadel", "Cobra", "Celestial", "Crow", "Phoenix", "Dynamo", "Eagle", "Eclipse", "Empyrean", "Enigma", "Falcon", "Firefly", "Goliath", "Havoc", "Hawk", "Heron", "Inferno", "Kingfish", "Lemur", "Lion", "Mallet", "Mantis", "Maverick", "Mirage", "Monolith", "Nebula", "Nexus", "Nighthawk", "Nebulus", "Obsidian", "Opah", "Orion", "Ostrich", "Otter", "Pantheon", "Paradigm", "Paragon", "Pelican", "Radiance", "Rhino", "Sapphire", "Seagull", "Serenade", "Sparrow", "Staple", "Swift", "Swan", "Tempest", "Pulsar", "Umbra", "Vanguard", "Velvet", "Vertex", "Vulture", "Weevil", "Zenith", "Zebra"];
private _TimeMin = 0;
private _TimeMax = 0;
LMO_MkrPos = nil;

//Create Ellipse Marker on Obj
LMO_MkrText = format ["OBJ %1", selectRandom _objNamesArray];
LMO_objMkrRad = LMO_mkrRng call BIS_fnc_randomInt;
LMO_MkrPos = [[[position LMO_spawnBldg, (LMO_objMkrRad/1.5)]], []] call BIS_fnc_randomPos;
LMO_Mkr = createMarker ["LMO_Mkr", LMO_MkrPos];
LMO_Mkr setMarkerShape "ELLIPSE";
LMO_Mkr setMarkerSize [LMO_objMkrRad,LMO_objMkrRad];
LMO_Mkr setMarkerBrush "FDiagonal";

//Time Sensitive Mission check
LMO_TimeSenRNG = random 100;

if (LMO_TimeSenRNG <= LMO_TSTchance) then {
	["Time Sensitive Mission Started.",LMO_Debug] call LMO_fn_rptSysChat;
	_TimeMin = (LMO_TSTrng select 0);
	_TimeMax = (LMO_TSTrng select 1);
} else {
	_TimeMin = (LMO_TimeRng select 0);
	_TimeMax = (LMO_TimeRng select 1);
};

//Set OBJ Marker Name & Timer
LMO_mTimer = [((_TimeMin)*60),((_TimeMax)*60)] call BIS_fnc_randomInt;
LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
LMO_MkrName = createMarker ["LMO_MkrName", LMO_MkrPos];
LMO_MkrName setMarkerShape "ICON";
LMO_MkrName setMarkerSize [1,1];
LMO_MkrName setMarkerType "mil_unknown";
["Objective markers created.", LMO_DebugFull] call LMO_fn_rptSysChat;