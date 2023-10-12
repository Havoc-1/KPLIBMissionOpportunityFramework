/**
* 
* LIBERATION MISSIONS OF OPPORTUNITY
*
* Dynamic system to integrate small scale side-missions into larger objectives
* These missions are embedded within existing objectives objectives to add variety to Liberation
* Outcome of these missions allow greater influence on alert level [!] and intelligence apart from the secondary objectives 
*
* Intended to be run alongside KP Liberation Mission Scenarios 
* Refer to readme.md for setup 
*
* @author  Xephros [ANTEC] - (Discord: paperboathat)
* @co-author _keystone [DMCL] - (Discord: keystone_design) - Code review, Testing, Bug smashing, and optimization 
*
*
*/

//--------LMO Adjustable Parameters--------//

//Mission Timer Range (minutes)
moTimeMin = 10;
moTimeMax = 20;

//Objective Marker Radius Range
mkrRngLow = 50;
mkrRngHigh = 300;

//Minimum garrisonable spots in building to be considered a possible objective spot
buildingSize = 8;

//Distance to search building array on enemy units
Bradius = 500;

//How often (in minutes) the server will check to start an LMO
missionCheckRNG = 1;
//Percentage chance of determining LMO per check rate
missionChanceSelect = 60;

//Minimum range of MO target to spawn on MO start
BplayerRange = 1000;

//Hostage Rescue win radius
objMarkerRadiusRescue = 300;

//Building exclusion array to make sure seaports are not included, list is not exhaustive
XEPKEY_blacklistBuildings = [
	"Land_Pier_F",
	"Land_nav_pier_m_F",
	"Land_Pier_wall_F", 
	"Land_Pier_small_F",
	"Land_Pier_Box_F",
	"Land_Pier_addon", 
	"Land_Sea_Wall_F"
];

//-----------------------------------------//

//GLOBAL SETTINGS
activeMission = false;
Btypes = ["BUILDING", "HOUSE"];
spawnBuilding = [];
missionChance = 0;

//!!!!!
//add variable init

//--------------------------------

//Squad composition of enemies that will spawn on the objective, reference liberation global variables
XEPKEY_SideOpsORBAT = [
	opfor_squad_leader,
	opfor_medic, 
	opfor_machinegunner,
	opfor_heavygunner,
	opfor_medic, 
	opfor_marksman, 
	opfor_grenadier, 
	opfor_rpg
];

//Compile all functions
#include "compile.sqf";

if !(isDedicated || (isServer && hasInterface)) exitWith {};

while {true} do {

	//calling populate enemy list function
	if (activeMission == false) then {
		call XEPKEY_fn_getEnemyList;
	};
	//actual groupChat (format ["%1", enyList]);
	//call XEPKEY_fnc_getBuildings;
	if (activeMission == false && missionChance <= missionChanceSelect && count enyList > 1) then {
		activeMission = true;
		call XEPKEY_fn_getBuildings;
		if (activeMission == false) exitWith {activeMission = false};
		//actual groupChat (format ["Second run: %1", activeMission]);	
		//actual groupChat (format ["made it to line 34"]);
		//actual groupChat (format ["%1", spawnBuilding]);
		call XEPKEY_fn_markerFunctions;
		call XEPKEY_fn_pickMission;
	};
	hint format ["Mission Chance: %1\nActive Mission: %2\nSpawn Building: %3\nEnyCount: %4\nInsideBuilding Player: %5", missionChance, activeMission, spawnBuilding, count enyList, insideBuilding player];
	sleep missioncheckRNG;
};