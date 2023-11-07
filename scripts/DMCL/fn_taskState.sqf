/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Function to change LMO Task State, remove markers, and end LMO active state
 *
 *	Task States:
 *		1 = Success
 *		2 = Failed
 *		3 = Cancelled
 *
 *	Arguments:
 *		0: Task State <NUMBER>
 *
 *	Examples:
 *		[1] call XEPKEY_fn_taskState;
 *		[_missionState] call XEPKEY_fn_taskState;
 *
 *	Return Value: LMO_active
 */

params ["_s"];
private _interval = 5;


switch (_s) do
{
	case 1:{_s = "SUCCEEDED"};
	case 2:{_s = "FAILED"};
	case 3:{_s = "CANCELLED"};
};

["_taskMO", _s, false] call BIS_fnc_taskSetState;
deleteMarker LMO_Mkr;
deleteMarker LMO_MkrName;

[{
    systemChat "LMO Debug: Inside of task state";
	if (LMO_Debug == true) then {deleteMarker LMO_MkrDebug};
}, _interval, []] call CBA_fnc_addPerFrameHandler;

["_taskMO"] call BIS_fnc_deleteTask;
["_taskMisMO"] call BIS_fnc_deleteTask;
LMO_active = false;