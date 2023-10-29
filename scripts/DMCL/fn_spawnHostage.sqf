/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Function to surrender hostage and attempts to place near elevated enemies
 *
 *	Arguments:
 *	0: Enemy Units Group <GROUP>
 *	1: Hostage Units Group <GROUP>
 *
 *	Example:
 *	[_enyUnits,_hostageGrp] call XEPKEY_fn_spawnHostage;
 *
 */

params ["_enyUnits","_hostageGrp"];

_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1}) select {(getPosATL _x) select 2 > 3};
{
	//[_x, true] call ace_captives_fnc_setSurrendered;
	[_x, true, objNull] call ACE_captives_fnc_setHandcuffed;
	_hostagePosOffset = selectRandom [-0.5,0.5];

	_hostageDisOffset = random 2;
	
	if (_hostageDisOffset < 0.5) then {
		_hostageDisOffset = 0.5;
	};

	if (count _enyUnitsInside >= 1) then {
		
		_hostageTaker = selectRandom _enyUnitsInside;
		_hostageTaker disableAI "PATH";
		
		_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
		_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
		_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
	
	} else {
		_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
		if (count _enyUnitsInside > 0) then {
			
			_hostageTaker = selectRandom _enyUnitsInside;
			_hostageTaker disableAI "PATH";
			_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
			//_hostagePos = getPosASL _hostageTaker;
			_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
			_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
		
		} else {
			
			_hostageTaker = selectRandom units _enyUnits;
			_hostageTaker disableAI "PATH";
			_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
			//_hostagePos = getPosASL _hostageTaker;
			_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
			_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
			
		};
	};
	_x setDir random 360;
}forEach (units _hostageGrp);