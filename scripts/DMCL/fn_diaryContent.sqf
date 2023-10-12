//Ran as post-init
//Diary entry to show its active

if !(hasInterface) exitWith {};

player createDiarySubject ["LMO_INFO", "LMO"];
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
