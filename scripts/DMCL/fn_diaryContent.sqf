//Ran as post-init
//Diary entry to show its active 

if !(hasInterface) exitWith {};
sleep 2;
player createDiarySubject ["LMO_INFO", "LMO"];
player createDiaryRecord [
    "LMO_INFO",
    ["Rewards System",
    format [
    "<br/><font color='#FDFFAB' size=20>Rewards System</font><br/><br/>Reference table for mission rewards and possible outcomes.<br/><br/><font color='#4C62FF' size=16>Hostage Rescue</font>
    <br/>    <font color='#AFAFAF'>Hostage Extracted:</font><br/>    <font color='#4DD74E'>+%1%% Civilian Reputation     +%2% Intelligence<br/></font>    <font color='#AFAFAF'>Timer Expired/Hostage Killed:</font><br/>    <font color='#ff0000'>-%3%% Civilian Reputation</font>
    <br/><br/><font color='#F49434' size=16>HVT Capture or Kill</font><br/>    <font color='#AFAFAF'>Captured and Exfiled:<br/>    Armed:</font> <font color='#4DD74E'>+%4 Intelligence    -%5%% Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Unarmed:</font> <font color='#4DD74E'>+%6 Intelligence    -%5%% Alert Level [ ! ]</font><br/>    <font color='#AFAFAF'>Killed:</font> <font color='#4DD74E'>-%7%% Alert Level [ ! ]</font><br/><br/><font color='#36FD9B' size=16>Destroy or Secure Cache</font><br/>    <font color='#AFAFAF'>TBD<br/><br/><font color='#E5E93E' size=16>Reconnaissance</font><br/>    <font color='#AFAFAF'>TBD<br/>
    ", XEPKEY_LMO_HR_REWARD_CIVREP, XEPKEY_LMO_HR_REWARD_INTEL, KP_liberation_cr_kill_penalty, XEPKEY_LMO_HVT_REWARD_INTEL1, XEPKEY_LMO_HVT_REWARD_ALERT_HIGH, XEPKEY_LMO_HVT_REWARD_INTEL2, XEPKEY_LMO_HVT_REWARD_ALERT_LOW]
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


