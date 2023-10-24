/*
 * Function to create objective marker and choose objective name
 * 
 * Return Value: 
 * NONE
 *
 * Example:
 * call XEPKEY_fn_markerFunctions
 *
 */

//Variables
//Array for objective names
_objNamesArray = ["Aegis", "Astral", "Aurora", "Albatross", "Alpaca", "Arcadia", "Arowana", "Bastion", "Beacon", "Catalyst", "Cicada", "Chimera", "Cipher", "Citadel", "Cobra", "Celestial", "Crow", "Phoenix", "Dynamo", "Eagle", "Eclipse", "Empyrean", "Enigma", "Falcon", "Firefly", "Goliath", "Havoc", "Hawk", "Heron", "Inferno", "Kingfish", "Lemur", "Lion", "Mallet", "Mantis", "Maverick", "Mirage", "Monolith", "Nebula", "Nexus", "Nighthawk", "Nebulus", "Obsidian", "Opah", "Orion", "Ostrich", "Otter", "Pantheon", "Paradigm", "Paragon", "Pelican", "Radiance", "Rhino", "Sapphire", "Seagull", "Serenade", "Sparrow", "Staple", "Swift", "Swan", "Tempest", "Pulsar", "Umbra", "Vanguard", "Velvet", "Vertex", "Vulture", "Weevil", "Zenith", "Zebra"];

//Create Ellipse Marker on Obj
LMO_MkrText = format ["OBJ %1", selectRandom _objNamesArray];
LMO_objMkrRad = [mkrRngLow,mkrRngHigh] call BIS_fnc_randomInt;
LMO_MkrPos = [[[position LMO_spawnBldg, (LMO_objMkrRad/1.5)]], []] call BIS_fnc_randomPos;
LMO_Mkr = createMarker ["LMO_Mkr", LMO_MkrPos];
LMO_Mkr setMarkerShape "ELLIPSE";
LMO_Mkr setMarkerSize [LMO_objMkrRad,LMO_objMkrRad];
LMO_Mkr setMarkerBrush "FDiagonal";

//Set OBJ Marker Name & Timer

//if (missionTimeSenChance <= moTimeSenChanceSelect) then {
//	_moTimeMin = moTimeSenMin;
//	_moTimeMax = moTimeSenMax;
//} else {
//	_moTimeMin = moTimeMin;
//	_moTimeMax = moTimeMax;
//};
LMO_mTimer = [((moTimeMin)*60),((moTimeMax)*60)] call BIS_fnc_randomInt;
LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
LMO_MkrName = createMarker ["Marker1", LMO_MkrPos];
LMO_MkrName setMarkerShape "ICON";
LMO_MkrName setMarkerSize [1,1];
LMO_MkrName setMarkerType "mil_unknown";