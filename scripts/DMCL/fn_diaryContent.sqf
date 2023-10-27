//Ran as post-init
//Diary entry to show its active 

if !(hasInterface) exitWith {};
sleep 2;
player createDiarySubject ["LMO_INFO", "LMO"];
player createDiaryRecord [
    "LMO_INFO",
	["Server Parameters",
	format [
	"<br/><font color='#FDFFAB' size=20>Server Parameters</font><br/><br/><font color='#AFAFAF'>Mission Check Rate:</font> %2 Minutes<br/><font color='#AFAFAF'>Mission Chance:</font> %3%1<br/><font color='#AFAFAF'>Time Sensitive Mission Chance:</font> %4%1<br/><font color='#AFAFAF'>Minimum Building Garrison Size:</font> %5<br/><font color='#AFAFAF'>Maximum Mission Start Distance:</font> %6<br/><font color='#AFAFAF'>Minimum Mission Start Distance:</font> %7<br/><font color='#AFAFAF'>HVT Escape Radius:</font> %8 Metres<br/><font color='#AFAFAF'>Include Custom Cache Items:</font> %9<br/><font color='#AFAFAF'>Empty Cache Contents:</font> %10<br/><font color='#AFAFAF'>Mission Failure Penalties:</font> %11<br/><font color='#AFAFAF'>Debug Mode:</font> %12<br/><font color='#AFAFAF'>HVT Debug Mode:</font> %13<br/><br/>
	<font color='#AFAFAF'>Parameters can be modified in fn_LMOinit.sqf</font>
	","%",LMO_mCheckRNG,LMO_mChanceSelect,moTimeSenChanceSelect,LMO_bSize,LMO_enyRng,LMO_bPlayerRng,HVTescapeRng,LMO_CacheItems,LMO_CacheEmpty,LMO_Penalties,LMO_Debug,LMO_HVTDebug]
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
    <br/><br/><font color='#F49434' size=16>HVT Capture or Kill</font><br/>    <font color='#AFAFAF'>Captured and Exfiled:<br/>    Armed:</font> <font color='#4DD74E'>+%5 Intelligence    -%6%1 Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Unarmed:</font> <font color='#4DD74E'>+%7 Intelligence    -%6%1 Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Killed:</font> <font color='#4DD74E'>-%8%1 Alert Level [ ! ]</font><br/><br/><font color='#36FD9B' size=16>Destroy or Secure Cache</font><br/>    <font color='#AFAFAF'>TBD<br/><br/><font color='#E5E93E' size=16>Reconnaissance</font><br/>    <font color='#AFAFAF'>TBD<br/>
    ","%",XEPKEY_LMO_HR_REWARD_CIVREP, XEPKEY_LMO_HR_REWARD_INTEL, KP_liberation_cr_kill_penalty, XEPKEY_LMO_HVT_REWARD_INTEL1, XEPKEY_LMO_HVT_REWARD_ALERT_HIGH, XEPKEY_LMO_HVT_REWARD_INTEL2, XEPKEY_LMO_HVT_REWARD_ALERT_LOW]
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


