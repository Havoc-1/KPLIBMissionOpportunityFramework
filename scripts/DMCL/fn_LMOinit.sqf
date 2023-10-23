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
moTimeMin = 30;
moTimeMax = 60;

//Time Sensitive Mission Timer Range (minutes)
moTimeSenMin = 10;
moTimeSenMax = 15;

//Percentage chance of Time Sensitive Mission
moTimeSenChanceSelect = 20;

//Objective Marker Radius Range
mkrRngLow = 50;
mkrRngHigh = 300;

//Minimum garrisonable spots in building to be considered a possible objective spot
LMO_bSize = 8;

//Distance to search building array on enemy units
LMO_bRadius = 500;

//Minimum distance of enemy to players to start LMO
LMO_enyRng = 2500;

//How often (in minutes) the server will check to start an LMO
LMO_mCheckRNG = 10;
//Percentage chance of determining LMO per check rate
LMO_mChanceSelect = 20;

//Minimum range of MO target to spawn on MO start
LMO_bPlayerRng = 1000;

//Hostage Rescue win radius
LMO_objMkrRadRescue = 300;

//HVT Runner Params
HVTrunSearchRng = 200;				//Runs away from BLUFOR units within this range
HVTrunSurRng = 5;			//Distance to determine whether HVT will consider surrender
HVTrunDist = 400;					//Distance HVT runs once spooked
HVTescapeRng = LMO_bRadius * 0.6;		//HVT Escape radius from LMO_spawnBldg

//Building exclusion array to make sure seaports are not included, list is not exhaustive
XEPKEY_blacklistBuildings = [
	"Land_Pier_F",
	"Land_nav_pier_m_F",
	"Land_Pier_wall_F", 
	"Land_Pier_small_F",
	"Land_Pier_Box_F",
	"Land_Pier_addon", 
	"Land_Sea_Wall_F",
	"Land_Airport_01_hangar_F",
	"Land_ContainerLine_01_F",
	"Land_ContainerLine_02_F",
	"Land_ContainerLine_03_F",
	"Land_SCF_01_heap_bagasse_F",
	"Land_SCF_01_heap_sugarcane_F",
	"Land_SCF_01_generalBuilding_F",
	"Land_SCF_01_clarifier_F"
];


//GLOBAL SETTINGS
activeMission = false;
LMO_bTypes = ["BUILDING", "HOUSE"];
LMO_spawnBldg = [];
LMO_mChance = 0;
LMO_mTimeSenChance = 0;
LMO_Debug = 1;
LMO_HVTDebug = 1;
LMO_VCOM_On = false;

//REWARDS SETTINGS 
XEPKEY_LMO_HR_REWARD_CIVREP = 40;
XEPKEY_LMO_HR_REWARD_INTEL = 15;
XEPKEY_LMO_HVT_REWARD_ALERT_LOW = 1;
XEPKEY_LMO_HVT_REWARD_ALERT_HIGH = 5;
XEPKEY_LMO_HVT_REWARD_INTEL1 = 25;
XEPKEY_LMO_HVT_REWARD_INTEL2 = 40;


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

//Checks if VCOM is loaded
if (isClass (configfile >> "CfgPatches" >> "VCOM_AI") || "VCOM_AI" in (allMissionObjects "Mod")) then {
  LMO_VCOM_On = true;
};

while {true} do {

	//calling populate enemy list function
	if (activeMission == false) then {
		call XEPKEY_fn_getEnemyList;
	};
	
	if (activeMission == false && count LMO_enyList > 0 && ((LMO_mChance <= LMO_mChanceSelect) || LMO_Debug == 1)) then {
		activeMission = true;
		call XEPKEY_fn_getBuildings;
		if (activeMission == false) exitWith {
			activeMission = false;
			if (LMO_Debug == 1) then {systemChat "LMO Debug: No suitable buildings found, exiting scope fn_getBuildings.sqf"};
		};
		call XEPKEY_fn_markerFunctions;
		call XEPKEY_fn_pickMission;
	};
	
	if (LMO_Debug == 1) then {
		sleep 10;
		hintSilent format ["LMO Debug Hint\n\nMission Chance: %1\nActive Mission: %2\nSpawn Building: %3\nEnyCount: %4\nInsideBuilding Player: %5, VCOM Enabled: %6", LMO_mChance, activeMission, LMO_spawnBldg, count LMO_enyList, insideBuilding player, LMO_VCOM_On];	
	} else {sleep (LMO_mCheckRNG*60)};
};