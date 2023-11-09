//Ran as post-init
//Diary entry to show its active 

if !(hasInterface) exitWith {};
sleep 2;
player createDiarySubject ["LMO_INFO", "LMO"];
player createDiaryRecord [
    "LMO_INFO",
	["Server Parameters",
	format [
	"<br/><font color='#FDFFAB' size=20>Server Parameters</font><br/><br/><font color='#AFAFAF'>Mission Objective Timer:</font> %2-%3 Minutes<br/><font color='#AFAFAF'>Mission Check Rate:</font> %4 Minutes<br/><font color='#AFAFAF'>Mission Chance:</font> %5%1<br/><br/><font color='#AFAFAF'>Time Sensitive Tasks Enabled:</font> %6<br/><font color='#AFAFAF'>Time Sensitive Task Timer:</font> %7-%8 Minutes<br/><font color='#AFAFAF'>Time Sensitive Task Chance:</font> %9%1<br/><font color='#AFAFAF'>Time Sensitive Task Reward Multiplier: </font>%10<br/><br/><font color='#AFAFAF'>Min Building Garrison Size:</font> %11<br/><font color='#AFAFAF'>Mission Start Distance:</font> %12-%13 Meters<br/><font color='#AFAFAF'>HVT Escape Radius:</font> %14 Metres<br/><font color='#AFAFAF'>Allow HVT Runners:</font> %15<br/></font><font color='#AFAFAF'>HVT Runners Only:</font> %16<br/><font color='#AFAFAF'>Include Custom Cache Items:</font> %17<br/><font color='#AFAFAF'>Empty Cache Contents:</font> %18<br/><font color='#AFAFAF'>Enable Cache QRF Multiplier: </font>%19<br/><font color='#AFAFAF'>Cache QRF Mulitplier: </font>%20<br/><font color='#AFAFAF'>Defend Cache Time: </font>%21 Minutes<br/><br/><font color='#AFAFAF'>Mission Failure Penalties:</font> %22<br/><font color='#AFAFAF'>      Hostage Rescue:</font> %23<br/><font color='#AFAFAF'>      HVT:</font> %24<br/><font color='#AFAFAF'>      Cache:</font> %25<br/><br/><font color='#AFAFAF'>Debug Mode:</font> %26<br/><font color='#AFAFAF'>HVT Debug Mode:</font> %27<br/><br/><font color='#AFAFAF'>Parameters can be modified in fn_LMOinit.sqf</font>
	","%",(LMO_TimeRng select 0),(LMO_TimeRng select 1),LMO_mCheckRNG,LMO_mChanceSelect,LMO_TST,(LMO_TSTrng select 0),(LMO_TSTrng select 1),LMO_TSTchance,LMO_TST_Reward,LMO_bSize,LMO_enyRng,LMO_bPlayerRng,LMO_HVTescRng,LMO_HVTallowRunner,LMO_HVTrunnerOnly,LMO_CacheItems,LMO_CacheEmpty,LMO_CacheSqdMultiplier,LMO_CacheSqdMultiply,LMO_CacheTimer,(LMO_Penalties select 0),(LMO_Penalties select 1),(LMO_Penalties select 2),(LMO_Penalties select 3),LMO_Debug,LMO_HVTDebug]
	],
	taskNull,
	"",
	false
];

player createDiaryRecord [
    "LMO_INFO",
    ["Rewards System",
    format [
    "<br/><font color='#FDFFAB' size=20>Rewards System</font><br/><br/>Reference table for mission rewards and possible outcomes.<br/><br/><font color='#4C62FF' size=16>Hostage Rescue</font>
    <br/>    <font color='#AFAFAF'>Hostage Extracted:</font><br/>    <font color='#4DD74E'>+%2%1 Civilian Reputation     +%3% Intelligence<br/></font>    <font color='#AFAFAF'>Timer Expired/Hostage Killed:</font><br/>    <font color='#ff0000'>-%4%1 Civilian Reputation</font>
    <br/><br/><font color='#F49434' size=16>HVT Capture or Kill</font><br/>    <font color='#AFAFAF'>Captured Armed:</font><br/>    <font color='#4DD74E'>+%5 Intelligence    -%6%1 Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Captured Unarmed:</font><br/>    <font color='#4DD74E'>+%7 Intelligence    -%6%1 Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Killed:</font><br/>    <font color='#4DD74E'>-%8%1 Alert Level [ ! ]</font><br/><br/><font color='#36FD9B' size=16>Destroy or Secure Cache</font><br/>    <font color='#AFAFAF'>Secured:</font><br/>    <font color='#4DD74E'>%9-%10 Supply Boxes    %11-%12 Ammo Boxes    %13-%14 Fuel Boxes<br/></font>    <font color='#AFAFAF'>Destroyed:</font><br/>    <font color='#4DD74E'>-%15%1 Alert Level [ ! ]<br/></font>    <font color='#AFAFAF'>Lost:</font><br/>    <font color='#ff0000'>+%16%1 Alert Level [ ! ]<br/></font>
    ","%",LMO_HR_Win_CivRep, LMO_HR_Win_Intel, LMO_HR_Lose_CivRep, LMO_HVT_Win_intelUnarmed, LMO_HVT_Win_CapAlert, LMO_HVT_Win_intelArmed, LMO_HVT_Win_KillAlert, (LMO_Cache_supplyBoxes select 0),(LMO_Cache_supplyBoxes select 1),(LMO_Cache_ammoBoxes select 0),(LMO_Cache_ammoBoxes select 1),(LMO_Cache_fuelBoxes select 0),(LMO_Cache_fuelBoxes select 1), LMO_Cache_Win_Alert, LMO_Cache_Lose_Alert]
    ],
    taskNull,
    "",
    false
];

player createDiaryRecord [
	"LMO_INFO",
	["Liberation: Missions of Opportunity",
	"<br/><font color='#FDFFAB' size=20>Liberation: Missions of Opportunity</font>
	<br/><br/>LMO is a dynamic system that integrates small scale side-missions into active enemy zones for Liberation.<br/><br/>These missions are embedded within existing objectives objectives to add variety to Liberation. The outcome of these missions allow greater influence on the <font color='#ff0000'>alert level [ ! ]</font> and <font color='#4C62FF'>intelligence</font> on top of the secondary objectives.<br/><br/>Intended to be run alongside KP Liberation Mission Scenarios.<br/><br/><font color='#AFAFAF'>Refer to readme.md for setup.<br/><br/>Created by [ANTEC] Xephros and [DMCL] Keystone.</font>
	
	"],
	taskNull,
	"",
	false
];


