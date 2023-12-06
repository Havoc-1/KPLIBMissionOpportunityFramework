/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to surrender hostage and attempts to place near elevated enemies
 *
 *	Arguments:
 *		0: Enemy Units Group <GROUP>
 *		1: Hostage Units Group <GROUP>
 *
 *	Example:
 *		[_enyUnits,_hostage] call LMO_fn_moveHostage;
 *
 */

params ["_enyUnits","_hostage"];

//Predefine variables
private _hPosOffset = selectRandom [-0.5,0.5];
private _hDisOffset = [0.5,2] call BIS_fnc_randomNum;
private _hTaker = objNull;

//Handcuffs hostage
[_hostage, true, objNull] call ACE_captives_fnc_setHandcuffed;
_enyUnitsInside = ((units _enyUnits) select {insideBuilding _hostage > 0 && {(getPosATL _hostage) select 2 > 3}});
if (count _enyUnitsInside > 0) then {
	
	_hTaker = selectRandom _enyUnitsInside;
	_hTaker disableAI "PATH";
	
	_hRelDir = _hTaker getDir LMO_spawnBldg;
	_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
	_hostage setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
	diag_log "[LMO] [Hostage Rescue] Hostage moved to elevated interior enemy.";

} else {
	_enyUnitsInside = ((units _enyUnits) select {insideBuilding _hostage > 0});
	if (count _enyUnitsInside > 0) then {
		
		_hTaker = selectRandom _enyUnitsInside;
		_hTaker disableAI "PATH";
		_hRelDir = _hTaker getDir LMO_spawnBldg;
		_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
		_hostage setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
		diag_log "[LMO] [Hostage Rescue] No elevated interior enemies found, moving hostage to random interior enemy.";

	} else {
		
		_hTaker = selectRandom units _enyUnits;
		_hTaker disableAI "PATH";
		_hRelDir = _hTaker getDir LMO_spawnBldg;
		_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
		_hostage setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
		diag_log "[LMO] [Hostage Rescue] No interior enemies found, hostage moved to random enemy at target building.";
	};
};
_hostage setDir random 360;

[
	{
		params ["_enyUnits","_hostage","_hDisOffset","_hPosOffset"];
		_hostage setVariable ["LMO_counter",3];
		if (insideBuilding _hostage == 0) then {
			[
				{
					(_this select 0) params ["_enyUnits","_hostage","_hDisOffset","_hPosOffset"];
					private _enyCount = units _enyUnits select {insideBuilding _x > 0};
					private _counter = _hostage getVariable "LMO_counter";
					if ((insideBuilding _hostage != 1) && (count _enyCount > 0)) then {
						["Hostage is outside, attempting to relocate to interior with PFH.", LMO_Debug] call LMO_fn_rptSysChat;
						private _hTaker = selectRandom ((units _enyUnits) select {insideBuilding _x > 0});
						_hTaker disableAI "PATH";
						_hPos = [getPos _hTaker, _hDisOffset, (_hTaker getDir (nearestBuilding _hTaker))] call BIS_fnc_relPos;
						_hostage setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
						_counter = _counter - 1;
						_hostage setVariable ["LMO_counter",_counter];
						if (insideBuilding _hostage == 1 || _counter == 0) exitWith {
							_hostage setVariable ["LMO_counter",nil];
							[_this select 1] call CBA_fnc_removePerFrameHandler;
							["Hostage relocate complete. Exiting PFH.", LMO_Debug] call LMO_fn_rptSysChat;
						};
					} else {
						_hostage setVariable ["LMO_counter",nil];
						[_this select 1] call CBA_fnc_removePerFrameHandler;
						["Hostage relocate complete. Exiting PFH.", LMO_Debug] call LMO_fn_rptSysChat;
					};
				},
				0.1,
				[_enyUnits,_hostage,_hDisOffset,_hPosOffset]
			] call CBA_fnc_addPerFrameHandler;
		};
	},
	[_enyUnits,_hostage,_hDisOffset,_hPosOffset],
	10
] call CBA_fnc_waitAndExecute;
