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

	LMO_missions = [										//Booleans to enable or disable mission types
		true,		//Hostage Rescue
		true,		//Capture or Kill HVT
		true		//Destroy or Secure Cache
	];									

	//Mission Timer Range (minutes)
	LMO_TimeRng = [30,60];									//[Min,Max] minutes for LMO Objective
	LMO_TSTrng = [10,15];									//[Min,Max] minutes for Time Sensitive LMO Objective
	LMO_TST = true;											//Enable or disable Time Sensitive Tasks

	//Mission Chance
	LMO_mCheckRNG = 1/6;									//How often (in minutes) the server will check to start an LMO
	LMO_mChanceSelect = 30;									//Percentage chance of LMO per check rate
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

	//Hostage Rescue Params
	LMO_objMkrRadRescue = 300;								//Win radius for hostage extraction
	LMO_bHRrad = 15;										//Expand LMO_objMkrRadRescue if target building is surrounded by less than LMO_bHRrad buildings
	LMO_HRradMultiplier = 1.5;								//Multiply LMO_objMkrRadRescue by this if target building is surrounded by less than LMO_bHRrad
	LMO_HRallowBomb = true;									//Allow hostages to wear bomb vests (Detonates if timer expires, killed, or removed without defuse)
	LMO_HRbombChance = 0.9;									//Chance for bomb vest to appear on hostage (1 = 100%)
	LMO_HRbombVest = "V_TacVest_blk";						//Model of bomb vest for hostage to wear
	LMO_HRbomb = "APERSMine_Range_Ammo";					//Bomb explosion if vest is detonated
	LMO_HRbombBeep = true;									//Enable beeping sound of vest is close to detonation
	LMO_HRbeepTime = 10;									//Seconds to begin beeping for detonation
	LMO_HRbombDelay = 2;									//Delay in seconds to trigger bomb vest if activated
	LMO_HRdefuseTime = 10;
	/* LMO_HRdefuse allows types of units to defuse bomb vest <NUMBER>
	 *	0: Any Unit
	 *	1: Must be Engineer
	 *	2: Must be Explosive Specialist
	 *	3: Must be Engineer and Explosives Specialist
	 */
	LMO_HRdefuse = 2;

	//HVT Runner Params
	LMO_HVTrunSearchRng = 200;								//Runs away from player faction units within this range
	LMO_HVTrunSurRng = 5;									//Distance to determine whether HVT will consider surrender
	LMO_HVTholdRng = 10;									//Distance to halt mission timer when HVT is being escorted
	LMO_HVTescRng = LMO_bRadius * 0.6;						//HVT Escape radius from target building (LMO_spawnBldg)
	LMO_HVTrunDist = LMO_HVTescRng + 50;					//Distance HVT runs once spooked
	LMO_HVTchaseRng = 150;									//Distance from players to HVT to prevent escape once HVT leaves escape radius (LMO_HVTescRng)
	LMO_HVTallowRunner = true;								//Enable or disable HVT Runner chance
	LMO_HVTrunnerOnly = false;								//HVTs will all be runners (unarmed)
	LMO_HVTqrfChance = 0.3;									//Chance for QRF to spawn for HVT (1 = 100%)

	//Cache Params
	LMO_CacheModel = "Box_FIA_Wps_F";						//Model used for Cache
	LMO_CacheTimer = 5;										//Minutes to defend cache before fulton deploys
	LMO_CacheDefDist = 25;									//Distance to defend cache when secured
	LMO_CacheItems = false;									//Include LMO_CacheItemArray in cache contents
	LMO_CacheEmpty = true;									//Empty default contents of cache on spawn
	LMO_CacheItemArray = [									//Items to include in cache ["Item", Quantity]
		["DemoCharge_Remote_Mag", 2],
		["HandGrenade", 1]
	];

	//QRF
	LMO_qrfSqdMultiplier = true;							//Enable or disable QRF multiplier for objectives
	LMO_qrfPlayerRng = LMO_bRadius;							//Distance to count nearby players to cache for LMO_qrfSqdMultiply
	LMO_qrfSqdMultiply = 1.5;								//QRF multiplier based on amount of players near objective
	LMO_qrfSplit = 0.5;										//Chance to split QRF
	LMO_qrfSqdSpawnDist = [300,350];						//QRF Spawn distance [Min,Max]

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

	//Debug Mode
	LMO_Debug = true;										//Makes the mission chance 100% on every check rate
	LMO_DebugFull = false;									//Shows non-essential RPT logs in systemChat
	LMO_Debug_Mkr = false;									//Shows marker on target objective position

	/* LMO_mType forces a mission type when LMO_Debug is true <NUMBER>
	 *	0: All missions
	 *	1: Hostage Rescue
	 *	2: Capture or Kill HVT
	 *	3: Destroy or Secure Cache
	 */
	LMO_mType = 0;

	/* Outfit Params
	 *	0: Outfit <ARRAY> - An array containing arrays of item class name strings.
	 *		0: Headgear <ARRAY>
	 *		1: Goggles <ARRAY>
	 *		2: Vest <ARRAY>
	 *		3: Uniform <ARRAY>
	 *		4: Backpack <ARRAY>
	 *		5: NVG <ARRAY>
	 *		6: Weapon <ARRAY>
	 *			0: Weapon Class Name <STRING>
	 *			1: Magazine Class Name <STRING>
	 *			2: Magazine Quantity <NUMBER> (Optional)
	 *			3: Optic Class Name <STRING> (Optional)
	 *			4: Muzzle Class Name <STRING> (Optional)
	 *			5: Rail Attachment Class Name <STRING> (Optional)
	 *			6: Inventory Items <ARRAY> (Optional)
	 *				0: Item Class Name <STRING>
	 *				1: Quantity <NUMBER>
	 *			7: Secondary Magazine Class Name <STRING> (Optional)
	 *			8: Secondary Magazine Quantity <NUMBER> (Optional)
	 *
	 *	1: Boolean array enable custom equipment <ARRAY> (Optional)
	 *		0: Headgear <BOOL>
	 *		1: Goggles <BOOL>
	 *		2: Vest <BOOL>
	 *		3: Uniform <BOOL>
	 *		4: Backpack <BOOL>
	 *		5: NVG <BOOL>
	 *		6: Weapon <BOOL>
	 *	
	 *	2: Boolean array to enable chance for empty equipment slot <ARRAY> (Optional)
	 *		0: Headgear <BOOL>
	 *		1: Backpack <BOOL>
	 *		2: NVG <BOOL>
	 */

	LMO_garOutfit = [
		[
			[ //Headgear
				"H_HelmetHBK_chops_F",
				"H_HelmetHBK_ear_F"
			],
			[ //Goggles
				"G_Balaclava_TI_blk_F",
				"G_Balaclava_TI_G_blk_F"
			],
			[ //Vest
				"V_CarrierRigKBT_01_light_EAF_F",
				"V_CarrierRigKBT_01_light_Olive_F"
			],
			[ //Uniform
				"U_O_R_Gorka_01_F",
				"U_O_R_Gorka_01_camo_F"
			],
			[ //Backpack
				"B_AssaultPack_khk"
			],
			[ //NVG
				"NVGoggles_OPFOR"
			],
			[ //Weapon
				["arifle_AK12_F","30Rnd_762x39_AK12_Mag_F",7,"optic_Arco_AK_blk_F","ACE_muzzle_mzls_B","acc_flashlight"],
				["arifle_SPAR_02_blk_F","30Rnd_556x45_Stanag",7,"optic_Holosight_blk_F","ACE_muzzle_mzls_L","acc_flashlight"]
			]
		],
		[
			false,		//Headgear
			true,		//Goggles
			true,		//Vest
			false,		//Uniform
			false,		//Backpack
			false,		//NVG
			false		//Weapons
		]
	];

	LMO_hvtOutfit = [
		[
			[ //Headgear
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
			],
			[ //Goggles
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
			],
			[ //Vest
				"V_TacVestIR_blk",
				"V_Rangemaster_belt"
			],
			[ //Backpack
				"B_AssaultPack_khk"
			],
			[ //Uniform
				"U_C_Uniform_Scientist_01_formal_F",
				"U_I_C_Soldier_Bandit_2_F"
			],
			[ //NVG
				"NVGoggles_OPFOR"
			],
			[
				["arifle_AK12_F","30Rnd_762x39_AK12_Mag_F",7,"optic_Arco_AK_blk_F","muzzle_snds_B","acc_pointer_IR"],
				["SMG_03_black","50Rnd_570x28_SMG_03",7]
			]
		],
		[
			true,		//Headgear
			true,		//Goggles
			false,		//Vest
			false,		//Uniform
			false,		//Backpack
			false,		//NVG
			false		//Weapons
		],
		[
			true,		//Headgear
			true,		//Backpack
			true		//NVG
		]
	];

	
	LMO_qrfOutfit = [		
		[
			[ //Headgear
				"H_HelmetHBK_chops_F",
				"H_HelmetHBK_ear_F"
			],
			[ //Goggles
				"G_Balaclava_TI_blk_F",
				"G_Balaclava_TI_G_blk_F"
			],
			[ //Vest
				"V_CarrierRigKBT_01_light_EAF_F",
				"V_CarrierRigKBT_01_light_Olive_F"
			],
			[ //Uniform
				"U_O_R_Gorka_01_F",
				"U_O_R_Gorka_01_camo_F"
			],
			[ //Backpack
				"B_AssaultPack_khk"
			],
			[ //NVG
				"NVGoggles_OPFOR"
			],
			[
				[
					"arifle_AK12_GL_F","30Rnd_762x39_AK12_Mag_F",7,"optic_Arco_AK_blk_F","muzzle_snds_B","acc_pointer_IR",
					[
						["MiniGrenade",3],
						["SmokeShell",2]
					],
					"1Rnd_HE_Grenade_shell",3
				],
				[
					"arifle_SPAR_02_blk_F","30Rnd_556x45_Stanag",7,"optic_Holosight_blk_F","muzzle_snds_M","acc_pointer_IR",
					[
						["MiniGrenade",3],
						["SmokeShell",2]
					]
				]
			]
		],
		[
			true,		//Headgear
			true,		//Goggles
			true,		//Vest
			false,		//Uniform
			true,		//Backpack
			true,		//NVG
			true		//Weapons
		]
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
LMO_spawnBldg = objnull;
LMO_TimeSenRNG = 0;
LMO_VCOM_On = false;
LMO_objBlacklist = [];

//Compile all functions
#include "compile.sqf";
[] execVM "LMO\fn_diaryContent.sqf";

//Only runs for Server and HC Environments
if !(isDedicated || (isServer && hasInterface)) exitWith {};

diag_log "[LMO] Initializing LMO on server.";

//Checks if VCOM is loaded
if (!Vcm_ActivateAI || isNil "Vcm_ActivateAI") then {
	LMO_VCOM_On = false;
	diag_log "[LMO] VCOM is not enabled.";
} else {
	LMO_VCOM_On = true;
	diag_log "[LMO] VCOM is enabled.";
};

[] call LMO_fn_missionCheck;
