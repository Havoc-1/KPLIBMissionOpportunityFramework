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
	LMO_TimeMin = 30;			//Minimum minutes for LMO Objective
	LMO_TimeMax = 60;			//Maximum minutes for LMO Objective
	LMO_TSTmin = 10;			//Minimum minutes for Time Sensitive LMO Objective
	LMO_TSTmax = 15;			//Maximum minutes for Time Sensitive LMO Objective
	LMO_TST = true;				//Enable or disable Time Sensitive Tasks

	//Mission Chance
	LMO_mCheckRNG = 10;			//How often (in minutes) the server will check to start an LMO
	LMO_mChanceSelect = 20;		//Percentage chance of LMO per check rate
	LMO_TSTchance = 20;			//Percentage chance of Time Sensitive LMO per check rate once LMO has been determined

	//Enable or disable failed LMO penalties
	LMO_Penalties = true;

	//Building Params
	LMO_mkrRngLow = 50;				//Objective Marker Minimum Radius Range
	LMO_mkrRngHigh = 300;			//Objective Marker Maximum Radius Range
	LMO_bSize = 8;					//Minimum garrison spots in target building for LMO
	LMO_bRadius = 500;				//Distance to search building array on enemy units (Default: 500)
	LMO_objBlacklistRng = 500;		//Distance to blacklist buildings preventing objectives spawning in the same area

	//LMO Range Params
	LMO_enyRng = 2500;				//Minimum distance of enemy to players to start LMO
	LMO_bPlayerRng = 1000;			//Minimum range of MO target to spawn on MO start

	//Hostage Rescue win radius
	LMO_objMkrRadRescue = 300;

	//HVT Runner Params
	LMO_HVTrunSearchRng = 200;				//Runs away from BLUFOR units within this range
	LMO_HVTrunSurRng = 5;					//Distance to determine whether HVT will consider surrender
	LMO_HVTrunDist = 400;					//Distance HVT runs once spooked
	LMO_HVTescRng = LMO_bRadius * 0.6;		//HVT Escape radius from target building (LMO_spawnBldg)
	LMO_allowRunnerHVT = true;				//Enable or disable HVT Runner chance
	LMO_RunnerOnlyHVT = false;				//HVTs will all be runners (unarmed)

	//Cache Params
	LMO_FultonRng = 150;					//No players in radius to begin fulton uplift
	LMO_CacheItems = true;					//Include LMO_CacheItemArray in cache contents
	LMO_CacheEmpty = true;					//Empty default contents of cache on spawn
	LMO_CacheItemArray = [					//Items to include in cache ["Item", Quantity]
		["DemoCharge_Remote_Mag", 2],
		["HandGrenade", 1]
	];

	//LMO Reward Settings
	XEPKEY_LMO_HR_REWARD_CIVREP = 40;			//Hostage Rescue Civilian Reputation Win
	XEPKEY_LMO_HR_REWARD_INTEL = 15;			//Hostage Rescue Intelligence Win
	XEPKEY_LMO_HVT_REWARD_ALERT_LOW = 1;		//HVT Killed Alert Level Win
	XEPKEY_LMO_HVT_REWARD_ALERT_HIGH = 5;		//HVT Capture Alert Level Win
	XEPKEY_LMO_HVT_REWARD_INTEL1 = 25;			//HVT Unarmed Capture Intelligence Win
	XEPKEY_LMO_HVT_REWARD_INTEL2 = 40;			//HVT Armed Capture Intelligence Win

	//Debug Mode (Adds Hints and systemChat)
	LMO_Debug = false;				//10s mission check rate for debugging
	LMO_HVTDebug = false;			//Debugging HVT missions
	
		/* LMO_mType forces a mission type when LMO_Debug is true
		 *	0: All missions
		 *	1: Hostage Rescue
		 *	2: Capture or Kill HVT
		 *	3: Destroy or Secure Cache
		 */
	LMO_mType = 0;

	//HVT Outfit Params

		/* LMO_hvtOutfit Array to enable custom equipment for the HVT <BOOL>
		*	0: Headgear
		*	1: Goggles
		*	2: Vest
		*	3: Uniform
		*	4: Backpack
		*	5: NVG
		*	6: Weapons
		*/
		LMO_hvtOutfit = [true, true, false, false, false, false, false];

		/* LMO_hvtNone Array to enable chance for empty equipment slot for the HVT <BOOL>
		*	0: Headgear
		*	1: Backpack
		*	2: NVG
		*/
		LMO_hvtNone = [true, true, true];

		LMO_hvtHead = [
			"H_Bandanna_khk",
			"H_Bandanna_khk_hs",
			"H_bandanna_gry",
			"H_Bandanna_cbr",
			"H_Bandanna_blu",
			"H_Bandanna_mcamo",
			"H_Bandanna_sgg",
			"H_Bandanna_sand",
			"H_Bandanna_camo",
			"H_Watchcap_blk",
			"H_Watchcap_cbr",
			"H_Watchcap_camo",
			"H_Watchcap_khk",
			"H_Watchcap_sgg",
			"H_Beret_blk"
		];
		LMO_hvtGog = [
			"G_Balaclava_Skull1",
			"G_Balaclava_Tropentarn",
			"G_Balaclava_lowprofile",
			"G_Bandanna_beast",
			"G_Bandanna_aviator",
			"G_Bandanna_blk",
			"G_Bandanna_shades",
			"G_Bandanna_Skull1",
			"G_Bandanna_Skull2",
			"G_Bandanna_Syndikat1",
			"G_Bandanna_Syndikat2",
			"G_Bandanna_sport",
			"G_Aviator",
			"G_AirPurifyingRespirator_02_black_F",
			"G_AirPurifyingRespirator_02_olive_F",
			"G_AirPurifyingRespirator_02_sand_F",
			"None"
		];
		LMO_hvtVest = [
			"V_TacVestIR_blk",
			"V_Rangemaster_belt"
		];
		LMO_hvtBpk = [
			"B_AssaultPack_khk"
		];
		LMO_hvtUni = [
			"U_C_Uniform_Scientist_01_formal_F",
			"U_I_C_Soldier_Bandit_2_F"
		];
		LMO_hvtNVG = [
			"NVGoggles_OPFOR"
		];
			/* LMO_hvtWeap Array to assign custom weapon for the HVT 
			*	0: Weapon Class Name <STRING>
			*	1: Magazine Class name <STRING>
			*	2: Magazine Quantity <NUMBER>
			*/
		LMO_hvtWeap = [
			["arifle_AK12_F","30Rnd_762x39_AK12_Mag_F",7],
			["SMG_03_black","50Rnd_570x28_SMG_03",7]
		];


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

	//Building blacklist array to make sure seaports are not included, list is not exhaustive
	LMO_bListBldg = [
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

//-----------------------------------------//

//GLOBAL SETTINGS
LMO_active = false;
LMO_bTypes = ["BUILDING", "HOUSE"];		//Types of buildings to consider for LMO target
LMO_spawnBldg = [];
LMO_mChance = 0;
LMO_TimeSenRNG = 0;
LMO_VCOM_On = false;
LMO_objBlacklist = [];
LMO_TSTState = false;

//Compile all functions
#include "compile.sqf";

if !(isDedicated || (isServer && hasInterface)) exitWith {};

//Checks if VCOM is loaded
if (Vcm_ActivateAI == false || Vcm_ActivateAI == nil) then {
	LMO_VCOM_On = false;
} else {
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
		hintSilent format ["LMO Debug Hint\n\nMission Chance: %1\nTime Sensitive Chance: %7\nActive Mission: %2\nSpawn Building: %3\nEnyCount: %4\nInsideBuilding Player: %5\nVCOM Enabled: %6", LMO_mChance, LMO_active, LMO_spawnBldg, count LMO_enyList, insideBuilding player, LMO_VCOM_On, LMO_TSTchance];	
	} else {sleep (LMO_mCheckRNG*60)};
};