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

//GLOBAL SETTINGS
activeMission = false;
Btypes = ["BUILDING", "HOUSE"];
spawnBuilding = [];
//Minimum garrisonable spots in building to be considered a possible objective spot
buildingSize = 8;

//Distance to search building array on enemy units
Bradius = 500;
missionChance = 0;
missionChanceSelect = 60;
//Minimum range of MO target to spawn on MO start
BplayerRange = 1000;

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

//!!!!!
//add missioncheckRNG sleep func + variable init



// make a space for array of enemy units 

//UNIT ARRAYS
//LIBERATION VARIABLES
//--------------------------------
civilians = [
    "C_Man_casual_1_F_tanoan",
    "C_Man_casual_2_F_tanoan",
    "C_Man_casual_3_F_tanoan",
    "C_Man_casual_4_F_tanoan",
    "C_Man_casual_5_F_tanoan",
    "C_Man_casual_6_F_tanoan",
    "C_man_sport_1_F_tanoan",
    "C_man_sport_2_F_tanoan",
    "C_man_sport_3_F_tanoan",
    "C_Man_Fisherman_01_F",
    "C_Man_UtilityWorker_01_F",
    "C_man_hunter_1_F",
    "C_journalist_F",
    "C_Journalist_01_War_F"
];

opfor_officer = "I_officer_F";                                          // Officer
opfor_squad_leader = "I_Soldier_SL_F";                                  // Squad Leader
opfor_team_leader = "I_Soldier_TL_F";                                   // Team Leader
opfor_sentry = "I_Soldier_lite_F";                                      // Rifleman (Lite)
opfor_rifleman = "I_soldier_F";                                         // Rifleman
opfor_rpg = "I_Soldier_LAT2_F";                                         // Rifleman (LAT)
opfor_grenadier = "I_Soldier_GL_F";                                     // Grenadier
opfor_machinegunner = "I_Soldier_AR_F";                                 // Autorifleman
opfor_heavygunner = "I_Soldier_AR_F";                                   // Heavy Gunner
opfor_marksman = "I_Soldier_M_F";                                       // Marksman
opfor_sharpshooter = "I_Soldier_M_F";                                   // Sharpshooter
opfor_sniper = "I_ghillie_sard_F";                                      // Sniper
opfor_at = "I_Soldier_AT_F";                                            // AT Specialist
opfor_aa = "I_Soldier_AA_F";                                            // AA Specialist
opfor_medic = "I_medic_F";                                              // Combat Life Saver
opfor_engineer = "I_engineer_F";                                        // Engineer
opfor_paratrooper = "I_Soldier_lite_F";      

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
	sleep 5;
};