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
moTimeMin = 30;				//Minimum minutes for LMO Objective
moTimeMax = 60;				//Maximum minutes for LMO Objective
moTimeSenMin = 10;			//Minimum minutes for Time Sensitive LMO Objective
moTimeSenMax = 15;			//Maximum minutes for Time Sensitive LMO Objective
LMO_TimeSen = true;			//Enable or disable Time Sensitive Missions

//Mission Chance
LMO_mCheckRNG = 10;			//How often (in minutes) the server will check to start an LMO
LMO_mChanceSelect = 20;		//Percentage chance of LMO per check rate
moTimeSenChanceSelect = 20;	//Percentage chance of Time Sensitive LMO per check rate once LMO has been determined

//Building Params
mkrRngLow = 50;				//Objective Marker Minimum Radius Range
mkrRngHigh = 300;				//Objective Marker Maximum Radius Range
LMO_bSize = 8;				//Minimum garrison spots in target building for LMO
LMO_bRadius = 500;			//Distance to search building array on enemy units (Default: 500)
LMO_objBlacklistRng = 500;		//Distance to blacklist buildings preventing objectives spawning in the same area

//LMO Range Params
LMO_enyRng = 2500;			//Minimum distance of enemy to players to start LMO
LMO_bPlayerRng = 1000;			//Minimum range of MO target to spawn on MO start

//Hostage Rescue win radius
LMO_objMkrRadRescue = 300;

//HVT Runner Params
HVTrunSearchRng = 200;				//Runs away from BLUFOR units within this range
HVTrunSurRng = 5;					//Distance to determine whether HVT will consider surrender
HVTrunDist = 400;					//Distance HVT runs once spooked
HVTescapeRng = LMO_bRadius * 0.6;	//HVT Escape radius from LMO_spawnBldg

//Cache Params
LMO_FultonRng = 150;					//No players in radius to begin fulton uplift
LMO_CacheItems = true;					//Include explosives in cache spawn
LMO_CacheEmpty = true;					//Empty contents of cache on spawn
LMO_CacheItemArray = [					//Items to include in cache ["Item", Quantity]
	["DemoCharge_Remote_Mag", 2],
	["HandGrenade", 1]
];


//Enable or disable failed LMO penalties
LMO_Penalties = true;

//Debug Mode (Adds Hints and systemChat)
LMO_Debug = true;				//10s mission check rate for debugging
LMO_HVTDebug = true;				//Debugging HVT missions

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
LMO_active = false;
LMO_bTypes = ["BUILDING", "HOUSE"];		//Types of buildings to consider for LMO target
LMO_spawnBldg = [];
LMO_mChance = 0;
LMO_mTimeSenChance = 0;
LMO_VCOM_On = false;
LMO_objBlacklist = [];
LMO_TimeSenState = false;
moTimeSenRNG = 0;

//REWARDS SETTINGS 
XEPKEY_LMO_HR_REWARD_CIVREP = 40;			//Hostage Rescue Civilian Reputation Win
XEPKEY_LMO_HR_REWARD_INTEL = 15;			//Hostage Rescue Intelligence Win
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
	if (LMO_active == false) then {
		call XEPKEY_fn_getEnemyList;
	};
	
	if (LMO_active == false && count LMO_enyList > 0 && ((LMO_mChance <= LMO_mChanceSelect) || LMO_Debug == true)) then {
		LMO_active = true;
		call XEPKEY_fn_getBuildings;
		if (LMO_active == false) exitWith {
			if (LMO_Debug == true) then {systemChat "LMO Debug: No suitable buildings found, exiting scope fn_getBuildings.sqf"};
		};
		call XEPKEY_fn_markerFunctions;
		call XEPKEY_fn_pickMission;
	};
	
	if (LMO_Debug == true) then {
		sleep 10;
		hintSilent format ["LMO Debug Hint\n\nMission Chance: %1\nTime Sensitive Chance: %7\nActive Mission: %2\nSpawn Building: %3\nEnyCount: %4\nInsideBuilding Player: %5\nVCOM Enabled: %6", LMO_mChance, LMO_active, LMO_spawnBldg, count LMO_enyList, insideBuilding player, LMO_VCOM_On, moTimeSenRNG];	
	} else {sleep (LMO_mCheckRNG*60)};
};