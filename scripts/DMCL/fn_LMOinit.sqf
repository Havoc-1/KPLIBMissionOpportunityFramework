/*
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
 * @author  Xephros [SGC] - (Discord: paperboathat)
 * @co-author _keystone [DMCL] - (Discord: keystone_design) - Code review, Testing, Bug smashing, and optimization 
 *
 *
 */

//--------LMO Adjustable Parameters--------//

	//Mission Timer Range (minutes)
	LMO_TimeRng = [30,60];									//[Min,Max] minutes for LMO Objective
	LMO_TSTrng = [10,15];									//[Min,Max] minutes for Time Sensitive LMO Objective
	LMO_TST = true;											//Enable or disable Time Sensitive Tasks

	//Mission Chance
	LMO_mCheckRNG = 10;										//How often (in minutes) the server will check to start an LMO
	LMO_mChanceSelect = 20;									//Percentage chance of LMO per check rate
	LMO_TSTchance = 20;										//Percentage chance of Time Sensitive LMO after spawning objective

	//Building Params
	LMO_mkrRng = [50,300];									//[Min,Max] Objective Marker Radius Range
	LMO_bSize = 8;											//Minimum garrison spots in target building for LMO
	LMO_bRadius = 500;										//Distance to search building array on enemy units (Default: 500)
	LMO_objBlacklistRng = 500;								//Distance to blacklist buildings preventing objectives spawning in the same area
	LMO_bTypes = ["BUILDING", "HOUSE"];						//Types of buildings to consider for LMO target

	//LMO Range Params
	LMO_enyRng = 2500;										//Maximum distance of enemy to players to start LMO
	LMO_bPlayerRng = GRLIB_sector_size * 0.8;				//Minimum range of LMO target building to select on LMO start

	//Hostage Rescue win radius
	LMO_objMkrRadRescue = 300;

	//HVT Runner Params
	LMO_HVTrunSearchRng = 200;								//Runs away from player faction units within this range
	LMO_HVTrunSurRng = 5;									//Distance to determine whether HVT will consider surrender
	LMO_HVTescRng = LMO_bRadius * 0.6;						//HVT Escape radius from target building (LMO_spawnBldg)
	LMO_HVTrunDist = LMO_HVTescRng + 50;					//Distance HVT runs once spooked
	LMO_HVTchaseRng = 150;									//Distance from players to HVT to prevent escape once HVT leaves escape radius (LMO_HVTescRng)
	LMO_HVTallowRunner = true;								//Enable or disable HVT Runner chance
	LMO_HVTrunnerOnly = false;								//HVTs will all be runners (unarmed)

	//Cache Params
	LMO_CacheSqdMultiplier = true;							//Enable or disable QRF multiplier for cache obj
	LMO_CachePlayerRng = LMO_bRadius;						//Distance to count nearby players to cache for LMO_CacheSqdMultiply
	LMO_CacheSqdMultiply = 1.5;								//QRF multiplier based on amount of players near cache (Distance: LMO_CachePlayerRng)
	LMO_CacheSqdSpawnDist = 300;							//QRF Spawn distance when cache is secured
	LMO_CacheSqdMinDist = 200;								//QRF will not spawn within this distance to any player on cache secure
	
	LMO_CacheTimer = 5;										//Minutes to defend cache before fulton deploys
	LMO_CacheDefDist = 25;									//Distance to defend cache when secured
	LMO_CacheItems = true;									//Include LMO_CacheItemArray in cache contents
	LMO_CacheEmpty = true;									//Empty default contents of cache on spawn
	LMO_CacheItemArray = [									//Items to include in cache ["Item", Quantity]
		["DemoCharge_Remote_Mag", 2],
		["HandGrenade", 1]
	];

	//LMO Reward Settings
	LMO_TST_Reward = 1.5;									//Reward multipler for completing time sensitive missions
	LMO_HR_Win_CivRep = 40;									//Hostage Rescue Civilian Reputation Win
	LMO_HR_Win_Intel = 15;									//Hostage Rescue Intelligence Win
	LMO_HVT_Win_KillAlert = 30;								//HVT Killed Alert Level Win
	LMO_HVT_Win_CapAlert = 10;								//HVT Capture Alert Level Win
	LMO_HVT_Win_intelUnarmed = 25;							//HVT Unarmed Capture Intelligence Win
	LMO_HVT_Win_intelArmed = 40;							//HVT Armed Capture Intelligence Win
	LMO_Cache_Win_Alert = 20;								//Cache Destroyed Enemy Readiness Win
	LMO_Cache_supplyBoxes = [2,4];							//[Min,Max] Cache Secured Supply Boxes Win
	LMO_Cache_ammoBoxes = [2,4];							//[Min,Max] Cache Secured Ammo Boxes Win
	LMO_Cache_fuelBoxes = [2,4];							//[Min,Max] Cache Secured Fuel Boxes Win
	
	//LMO_Penalties array enables (true) or disables (false) resource penalties for failed LMOs <BOOL>
	LMO_Penalties = [
		true,		//Enabled/Disabled
		true,		//Hostage Rescue
		true,		//Capture or Kill HVT
		true		//Destroy or Secure Cache
	];

	LMO_HR_Lose_CivRep = KP_liberation_cr_kill_penalty;		//Hostage Rescue Killed Civilian Reputation Lose
	LMO_HVT_Lose_Intel = 20;								//HVT Escaped Intelligence Lose
	LMO_Cache_Lose_Alert = 20;								//Cache Lost Enemy Readiness Lose

	//Debug Mode (Adds Hints and diag_log)
	LMO_Debug = true;										//10s mission check rate for debugging in RPT
	LMO_HVTDebug = true;									//Debugging HVT missions in RPT
	LMO_Debug_Mkr = true;									//Shows marker on target objective position

	/* LMO_mType forces a mission type when LMO_Debug is true <NUMBER>
	 *	0: All missions
	 *	1: Hostage Rescue
	 *	2: Capture or Kill HVT
	 *	3: Destroy or Secure Cache
	 */
	LMO_mType = 3;

	//HVT Outfit Params

		//LMO_hvtOutfit Array to enable custom equipment for the HVT <BOOL>
		LMO_hvtOutfit = [
			true,		//Headgear
			true,		//Goggles
			false,		//Vest
			false,		//Uniform
			false,		//Backpack
			false,		//NVG
			false		//Weapons
		];

		//LMO_hvtNone Array to enable chance for empty equipment slot for the HVT <BOOL>
		LMO_hvtNone = [
			true,		//Headgear
			true,		//Backpack
			true		//NVG
		];

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
	LMO_Orbat = [
		opfor_squad_leader,
		opfor_medic,
		opfor_machinegunner,
		opfor_heavygunner,
		opfor_medic, 
		opfor_marksman, 
		opfor_grenadier, 
		opfor_rpg
	];
	//Squad Size [Min,Max]
	LMO_sqdSize = [7,10];

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

//Predefining Global Variables DO NOT TOUCH
LMO_active = false;
LMO_spawnBldg = [];
LMO_mChance = 0;
LMO_TimeSenRNG = 0;
LMO_VCOM_On = false;
LMO_objBlacklist = [];
LMO_TSTState = false;

//Compile all functions
#include "compile.sqf";

//Only runs for Server and HC Environments
if !(isDedicated || (isServer && hasInterface)) exitWith {};

[] call LMO_fn_cacheEH;

remoteExec ["LMO_fn_diaryContent",0,true];


//Checks if VCOM is loaded
if (Vcm_ActivateAI == false || isNil "Vcm_ActivateAI") then {LMO_VCOM_On = false} else {LMO_VCOM_On = true};

[
	{
		if ((count (allUnits select {side _x == GRLIB_side_enemy}) > 0) && !(LMO_active)) then {

			//calling populate enemy list function
			[] call LMO_fn_getEnemyList;
			
			if (count LMO_enyList > 0 && ((LMO_mChance <= LMO_mChanceSelect) || LMO_Debug)) then {
				LMO_active = true;
				diag_log "[LMO] LMO_active is now true.";
				[] call LMO_fn_getBuildings;
				if (LMO_active == false) exitWith {
					diag_log "[LMO] Debug: No suitable buildings found, exiting scope fn_getBuildings.sqf";
				};
				[] call LMO_fn_markerFunctions;
				[] call LMO_fn_pickMission;
			};
		};
		if (!(LMO_active)) then {
			diag_log format ["[LMO] Debug: Mission Chance: %1, TST Chance: %2, LMO_active: %3, Spawn Building: %4, EnyCount: %5, VCOM Enabled: %6", LMO_mChance,LMO_TimeSenRNG, LMO_active, LMO_spawnBldg, count LMO_enyList, LMO_VCOM_On];	
		};
	},
	LMO_mCheckRNG,
	[]
] call CBA_fnc_addPerFrameHandler;
