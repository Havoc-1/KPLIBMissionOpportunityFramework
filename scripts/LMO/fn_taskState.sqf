/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to change LMO Task State, remove markers, and end LMO active state
 *
 *	Task States:
 *		1 = Success
 *		2 = Failed
 *		3 = Cancelled
 *
 *	Arguments:
 *		0: Task State <NUMBER>
 *		1: Parent Task <STRING>
 *		2: Child Task <STRING>
 *
 *	Examples:
 *		[1,"_taskMO","_taskMisMO"] call LMO_fn_taskState;
 *		[_missionState,"_taskMO","_taskMisMO"] call LMO_fn_taskState;
 *
 *	Return Value: LMO_active
 */

params ["_s","_taskMO","_taskMisMO"];

switch (_s) do
{
	case 1:{_s = "SUCCEEDED"};
	case 2:{_s = "FAILED"};
	case 3:{_s = "CANCELLED"};
};

["_taskMO", _s, false] call BIS_fnc_taskSetState;
deleteMarker LMO_Mkr;
deleteMarker "LMO_Mkr";
LMO_Mkr = nil;
deleteMarker LMO_MkrName;
deleteMarker "LMO_MkrName";
LMO_MkrName = nil;

if (LMO_Debug_Mkr) then {deleteMarker LMO_MkrDebug};
[
	{
		params ["_taskMO","_taskMisMO"];
		["_taskMisMO"] call BIS_fnc_deleteTask;
		["_taskMO"] call BIS_fnc_deleteTask;
		LMO_active = false;
		["LMO_active set to false.",LMO_Debug] call LMO_fn_rptSysChat;
		missionNamespace setVariable ["LMO_MissionType",nil,true];
	},
	["_taskMO","_taskMisMO"],
	3
] call CBA_fnc_waitAndExecute;