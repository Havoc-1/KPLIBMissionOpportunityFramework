//Ran as post-init
//Diary entry to show its active 

if !(hasInterface) exitWith {};

player createDiarySubject ["LMO_INFO", "LMO"];
player createDiaryRecord [
    "LMO_INFO",
    ["Rewards System",
    format ["
    <br/>
    HOSTAGE RESCUE:
    <br/><br/>
    Win:
    <br/>
    Successfully exfiled = +%1 CIVILIAN REPUTATION and +%2 INTELLIGENCE
	<br/>
    Lose:
	<br/>
    Hostage killed = -%3 CIVILIAN REPUTATION
    <br/><br/>
    HVT KILL OR CAPTURE
    <br/><br/>
    Captured, no weapon = +%4 INTELLIGENCE and -%5 ALERT LEVEL<br/>
    Captured, weapon = +%6 INTELLIGENCE and -%5 ALERT LEVEL<br/>
    Killed, no weapon/weapon = -%7 ALERT LEVEL
    ", XEPKEY_LMO_HR_REWARD_CIVREP, XEPKEY_LMO_HR_REWARD_INTEL, KP_liberation_cr_kill_penalty, XEPKEY_LMO_HVT_REWARD_INTEL1, XEPKEY_LMO_HVT_REWARD_ALERT_HIGH, XEPKEY_LMO_HVT_REWARD_INTEL2, XEPKEY_LMO_HVT_REWARD_ALERT_LOW]
    ],
    taskNull,
    "",
    false
];

player createDiaryRecord [
	"LMO_INFO",
	["Liberation Missions of Opportunity",

	"
	<br/>
	Liberation Missions of Opportunity
	<br/><br/>

	Dynamic system to integrate small scale side-missions into larger objectives
	These missions are embedded within existing objectives objectives to add variety to Liberation
	Outcome of these missions allow greater influence on alert level [!] and intelligence apart from the secondary objectives 
	Intended to be run alongside KP Liberation Mission Scenarios.<br/><br/>
	Refer to readme.md for setup."],
	taskNull,
	"",
	false
];


