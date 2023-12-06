//Ran as post-init
//Diary entry to show its active 

if !(hasInterface) exitWith {};

player createDiarySubject ["LMO_INFO", "LMO"];
player createDiaryRecord [
	"LMO_INFO",
	["Server Parameters",
	format [
	"<br/><font color='#FDFFAB' size=20>Server Parameters</font><br/><br/>" +
	"<font color='#AFAFAF'>Mission Objective Timer:</font> %2-%3 Minutes<br/>" +
	"<font color='#AFAFAF'>Mission Check Rate:</font> %4 Minutes<br/>" +
	"<font color='#AFAFAF'>Mission Chance:</font> %5%1<br/><br/>" +
	"<font color='#AFAFAF'>Time Sensitive Tasks Enabled:</font> %6<br/>" +
	"<font color='#AFAFAF'>Time Sensitive Task Timer:</font> %7-%8 Minutes<br/>" +
	"<font color='#AFAFAF'>Time Sensitive Task Chance:</font> %9%1<br/>" +
	"<font color='#AFAFAF'>Time Sensitive Task Reward Multiplier: </font>%10<br/><br/>" +
	"<font color='#AFAFAF'>Min Building Garrison Size:</font> %11<br/>" +
	"<font color='#AFAFAF'>Mission Start Distance:</font> %13-%12 Meters<br/>" +
	"<font color='#AFAFAF'>HVT Escape Radius:</font> %14 Metres<br/>" +
	"<font color='#AFAFAF'>Allow HVT Runners:</font> %15<br/></font>" +
	"<font color='#AFAFAF'>HVT Runners Only:</font> %16<br/>" +
	"<font color='#AFAFAF'>Defend Cache Time: </font>%17 Minutes<br/><br/>" +
	"<font color='#AFAFAF'>Include Custom Cache Items:</font> %18<br/>" +
	"<font color='#AFAFAF'>Empty Cache Contents:</font> %19<br/>" +
	"<font color='#AFAFAF'>Enable QRF Multiplier: </font>%20<br/>" +
	"<font color='#AFAFAF'>QRF Mulitplier: </font>%21<br/>" +
	"<font color='#AFAFAF'>Mission Failure Penalties:</font> %22<br/>" +
	"<font color='#AFAFAF'>      Hostage Rescue:</font> %23<br/>" +
	"<font color='#AFAFAF'>      HVT:</font> %24<br/>" +
	"<font color='#AFAFAF'>      Cache:</font> %25<br/><br/>" +
	"<font color='#AFAFAF'>Debug Mode:</font> %26<br/>" +
	"<font color='#AFAFAF'>Marker Debug Mode:</font> %27<br/><br/>" +
	"<font color='#AFAFAF'>Parameters can be modified in fn_LMOinit.sqf</font>",
	"%",						//1
	(LMO_TimeRng select 0),		//2
	(LMO_TimeRng select 1),		//3
	LMO_mCheckRNG,				//4
	LMO_mChanceSelect,			//5
	LMO_TST,					//6
	(LMO_TSTrng select 0),		//7
	(LMO_TSTrng select 1),		//8
	LMO_TSTchance,				//9
	LMO_TST_Reward,				//10
	LMO_bSize,					//11
	LMO_enyRng,					//12
	LMO_bPlayerRng,				//13
	LMO_HVTescRng,				//14
	LMO_HVTallowRunner,			//15
	LMO_HVTrunnerOnly,			//16
	LMO_CacheTimer,				//17
	LMO_CacheItems,				//18
	LMO_CacheEmpty,				//19
	LMO_qrfSqdMultiply,			//20
	LMO_qrfSqdMultiplier,		//21
	(LMO_Penalties select 0),	//22
	(LMO_Penalties select 1),	//23
	(LMO_Penalties select 2),	//24
	(LMO_Penalties select 3),	//25
	LMO_Debug,					//26
	LMO_Debug_Mkr				//27
]],
taskNull,
"",
false
];

player createDiaryRecord [
	"LMO_INFO",
	["Rewards System",
	format [
	"<br/><font color='#FDFFAB' size=20>Rewards System</font><br/><br/>" +
	"Reference table for mission rewards and possible outcomes.<br/><br/>" +
	"<font color='#4C62FF' size=16>Hostage Rescue</font>" +
	"<br/>    <font color='#AFAFAF'>Hostage Extracted:</font>" +
	"<br/>    <font color='#4DD74E'>+%2%1 Civilian Reputation     +%3% Intelligence<br/>" +
	"</font>    <font color='#AFAFAF'>Timer Expired/Hostage Killed:</font>" +
	"<br/>    <font color='#ff0000'>-%4%1 Civilian Reputation</font><br/><br/>" +
	"<font color='#F49434' size=16>HVT Capture or Kill</font>" +
	"<br/>    <font color='#AFAFAF'>Captured Armed:</font>" +
	"<br/>    <font color='#4DD74E'>+%5 Intelligence    -%6%1 Alert Level [ ! ]</font>" +
	"<br/>    <font color='#AFAFAF'>Captured Unarmed:</font>" +
	"<br/>    <font color='#4DD74E'>+%7 Intelligence    -%6%1 Alert Level [ ! ]</font>" +
	"<br/>    <font color='#AFAFAF'>Killed:</font>" +
	"<br/>    <font color='#4DD74E'>-%8%1 Alert Level [ ! ]</font><br/><br/>" +
	"<font color='#36FD9B' size=16>Destroy or Secure Cache</font>" +
	"<br/>    <font color='#AFAFAF'>Secured:</font>" +
	"<br/>    <font color='#4DD74E'>%9-%10 Supply Boxes    %11-%12 Ammo Boxes    %13-%14 Fuel Boxes<br/>" +
	"</font>    <font color='#AFAFAF'>Destroyed:</font>" +
	"<br/>    <font color='#4DD74E'>-%15%1 Alert Level [ ! ]<br/>" +
	"</font>    <font color='#AFAFAF'>Lost:</font>" +
	"<br/>    <font color='#ff0000'>+%16%1 Alert Level [ ! ]<br/></font>",
	"%",								//1
	LMO_HR_Win_CivRep,					//2
	LMO_HR_Win_Intel,					//3
	LMO_HR_Lose_CivRep,					//4
	LMO_HVT_Win_intelUnarmed,			//5
	LMO_HVT_Win_CapAlert,				//6
	LMO_HVT_Win_intelArmed,				//7
	LMO_HVT_Win_KillAlert,				//8
	(LMO_Cache_supplyBoxes select 0),	//9
	(LMO_Cache_supplyBoxes select 1),	//10
	(LMO_Cache_ammoBoxes select 0),		//11
	(LMO_Cache_ammoBoxes select 1),		//12
	(LMO_Cache_fuelBoxes select 0),		//13
	(LMO_Cache_fuelBoxes select 1),		//14
	LMO_Cache_Win_Alert,				//15
	LMO_Cache_Lose_Alert				//16
]],
taskNull,
"",
false
];

player createDiaryRecord [
	"LMO_INFO",
	["Liberation: Missions of Opportunity",
	"<br/><font color='#FDFFAB' size=20>Liberation: Missions of Opportunity</font>
	<br/><br/>LMO is a dynamic system that integrates small scale side-missions into active enemy zones for Liberation.<br/><br/>These missions are embedded within existing objectives objectives to add variety to Liberation. The outcome of these missions allow greater influence on the <font color='#ff0000'>alert level [ ! ]</font> and <font color='#4C62FF'>intelligence</font> on top of the secondary objectives.<br/><br/>Intended to be run alongside KP Liberation Mission Scenarios.<br/><br/><font color='#AFAFAF'>Refer to readme.md for setup.<br/><br/>Created by [SGC] Xephros and [DMCL] Keystone.</font>
	
	"],
	taskNull,
	"",
	false
];
["Diary created.", LMO_DebugFull] call LMO_fn_rptSysChat;
