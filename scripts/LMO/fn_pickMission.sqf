/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Main body of LMO, function to create mission sets and tasks. Evalutes the outcome state and assigns rewards to KP Resources.
 *
 *	Arguments:
 *		0: Missions <ARRAY> - Contains all of the enabled missions for the session (Refer to LMO_missions in fn_LMOinit.sqf)
 *
 *	Examples:
 *		[_missions] call LMO_fn_pickMission;
 *	
 *	Return Value: None
 */

params ["_missions"];

//predef vars
private _missionType = 0;
private _missionTypeName = "";
private _missionHist = missionNamespace getVariable "LMO_missionHist";

//Randomizes LMO Mission Type
if (LMO_Debug && LMO_mType != 0) then {
	_missionType = LMO_mType;
} else {

	//Prevents same mission from occuring 3 times in a row
	if (!isNil "_missionHist") then {
		if ((count _missionHist >= 2) && count _missions > 1) then {
			if ((_missionHist select 0) == (_missionHist select 1)) then {
				_missions = _missions - [(_missionHist select 0)];
				_missionHist deleteAt 0;
				["Preventing mission from being selected a third time.",LMO_Debug] call LMO_fn_rptSysChat;
				missionNamespace setVariable ["LMO_missionHist",_missionHist,true];
			} else {
				_missionHist deleteAt 0;
				missionNamespace setVariable ["LMO_missionHist",_missionHist,true];
			};
		};
	} else {
		_missionHist = [];
	};
	_missionType = selectRandom _missions;
	_missionHist pushback _missionType;
	missionNamespace setVariable ["LMO_missionHist",_missionHist,true];
	if (count _missionHist > 0) then {
		[format ["Mission History: %1", _missionHist],LMO_DebugFull] call LMO_fn_rptSysChat;
	};
};

missionNamespace setVariable ["LMO_MissionType",_missionType,true];



switch (_missionType) do {
	
	//Hostage Rescue
	case 1:{
		_missionTypeName = "Hostage Rescue";
		[] call LMO_fn_missionHostage;
	};
	//Capture or Kill HVT
	case 2:{
		_missionTypeName = "Capture or Kill HVT";
		[] call LMO_fn_missionHVT
	};
	//Destroy or Secure Cache
	case 3:{
		_missionTypeName = "Destroy or Secure Cache";
		[] call LMO_fn_missionCache
	};
	default {
		_missionTypeName = "Undefined Mission";
		[format ["Invalid Mission Type: %1. Setting LMO_active to false.", _missionType],LMO_Debug] call LMO_fn_rptSysChat;
		LMO_active = false;
	};
};

[format ["Mission assigned: %1 (%2)", _missionTypeName,_missionType],LMO_Debug] call LMO_fn_rptSysChat;