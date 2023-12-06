/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to create LMO parent and child task.
 *
 *	Arguments:
 *	None
 *	
 *	Example:
 *		_tasks = [] call LMO_fn_taskCreate;
 *
 *	Return Value:
 *		[Parent Task, Child Task] <ARRAY>
 */

private _t1 = "";
private _t2 = "";
private _t3 = "";
private _taskDesc = "";
private _taskTitle = "";
private _taskIcon = "";
private _notifTitle = "";
private _notifIcon = "";
private _mkrColor = "";



switch (_missionType) do {

	case 1: {
		_t1 = ["Our intel indicates a small group of combatants holding a hostage at","Rescuing the hostage will greatly increase civilian reputation while failing the rescue will decrease civilian reputation.<br/><br/>Locate and extract the hostage."];

		_t2 = ["According to our intel, a hostage is currently held by a small faction of combatants at","Rescuing the hostage will greatly increase civilian reputation while failing the rescue will decrease civilian reputation.<br/><br/>Locate and extract the hostage."];

		_t3 = ["Gathered intelligence points to a hostage scenario being held by armed combatants at","Rescuing the hostage will greatly increase civilian reputation while failing the rescue will decrease civilian reputation.<br/><br/>Locate and extract the hostage."];

		_taskDesc = selectRandom [_t1,_t2,_t3];
		_taskTitle = "LMO: Hostage Rescue";
		_taskIcon = "Meet";
		_notifTitle = "Hostage Rescue";
		_notifIcon = "\A3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa";
		_mkrColor = "ColorBlue";
	};

	case 2: {
		_t1 = ["A high value target was reported to be within the vicinity nearby","Capturing HVT will provide intelligence and slightly reduce enemy readiness while killing the HVT will provide no intelligence while greatly reducing enemy readiness.<br/><br/>Locate and extract kill the high value target."];

		_t2 = ["Intelligence has disclosed the presence of a high-value target believed to be at","Capturing HVT will provide intelligence and slightly reduce enemy readiness while killing the HVT will provide no intelligence while greatly reducing enemy readiness.<br/><br/>Locate and extract kill the high value target."];

		_t3 = ["Recent reports have highlighted the probable presence of a high-value target within","Capturing HVT will provide intelligence and slightly reduce enemy readiness while killing the HVT will provide no intelligence while greatly reducing enemy readiness.<br/><br/>Locate and extract kill the high value target."];
		
		_taskDesc = selectRandom [_t1,_t2,_t3];
		_taskTitle = "LMO: Capture or Kill HVT";
		_taskIcon = "Kill";
		_notifTitle = "Kill or Capture HVT";
		_notifIcon = "\A3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa";
		_mkrColor = "ColorOrange";
	};

	case 3: {
		_t1 = ["Reconnaissance has identified enemy forces moving a supply cache around","The supply cache appears to be a stack of wooden boxes covered with a net. Secured supples will be air lifted to the nearest FOB while destroying the cache will reduce enemy readiness.<br/><br/>Locate and destroy or secure the supply cache."];

		_t2 = ["Surveillance operations have detected enemy forces in the process of relocating a supply cache near","The supply cache appears to be a stack of wooden boxes covered with a net. Secured supples will be air lifted to the nearest FOB while destroying the cache will reduce enemy readiness.<br/><br/>Locate and destroy or secure the supply cache."];

		_t3 = ["It has been ascertained that enemy forces are actively transporting a supply cache in","The supply cache appears to be a stack of wooden boxes covered with a net. Secured supples will be air lifted to the nearest FOB while destroying the cache will reduce enemy readiness.<br/><br/>Locate and destroy or secure the supply cache."];

		_taskDesc = selectRandom [_t1,_t2,_t3];
		_taskTitle = "LMO: Destroy or Secure Cache";
		_taskIcon = "Destroy";
		_notifTitle = "Destroy or Secure Cache";
		_notifIcon = "a3\missions_f_oldman\data\img\holdactions\holdaction_box_ca.paa";
		_mkrColor = "ColorGreen";
	};
};

//Creates Parent Task
[GRLIB_side_friendly, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "LMO_Mkr"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
["_taskMO","Box"] call BIS_fnc_taskSetType;

[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["%2 <marker name ='LMO_MkrName'>%1</marker>. %3",LMO_MkrText, _taskDesc select 0, _taskDesc select 1], _taskTitle, _taskIcon], objNull, 1, 3, false] call BIS_fnc_taskCreate;																						
["_taskMisMO",_taskIcon] call BIS_fnc_taskSetType;

if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
	["LMOTaskOutcomeO", [_notifTitle, _notifIcon]] remoteExec ["BIS_fnc_showNotification"];
} else {
	["LMOTask", [_notifTitle, _notifIcon]] remoteExec ["BIS_fnc_showNotification"];
};

LMO_MkrName setMarkerColor _mkrColor;
LMO_Mkr setMarkerColor _mkrColor;

if (LMO_Debug_Mkr && _missionType != 3) then {
	LMO_MkrDebug = createMarker ["LMO_MkrDebug", position LMO_spawnBldg];
	LMO_MkrDebug setMarkerShape "ICON";
	LMO_MkrDebug setMarkerSize [1,1];
	LMO_MkrDebug setMarkerType "mil_dot";
	["Debug Marker created", LMO_DebugFull] call LMO_fn_rptSysChat;
};

["Task Made",LMO_DebugFull] call LMO_fn_rptSysChat;

//Return Value
["_taskMO","_taskMisMO"];