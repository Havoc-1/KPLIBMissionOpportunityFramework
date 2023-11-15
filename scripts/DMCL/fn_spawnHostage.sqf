/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to surrender hostage and attempts to place near elevated enemies
 *
 *	Arguments:
 *		0: Enemy Units Group <GROUP>
 *		1: Hostage Units Group <GROUP>
 *
 *	Example:
 *		[_enyUnits,_hostageGrp] call LMO_fn_spawnHostage;
 *
 */

params ["_enyUnits","_hostageGrp"];

_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1}) select {(getPosATL _x) select 2 > 3};
{
	//[_x, true] call ace_captives_fnc_setSurrendered;
	[_x, true, objNull] call ACE_captives_fnc_setHandcuffed;
	_hPosOffset = selectRandom [-0.5,0.5];

	_hDisOffset = random 2;
	
	if (_hDisOffset < 0.5) then {
		_hDisOffset = 0.5;
	};

	if (count _enyUnitsInside >= 1) then {
		
		_hTaker = selectRandom _enyUnitsInside;
		_hTaker disableAI "PATH";
		
		_hRelDir = _hTaker getDir LMO_spawnBldg;
		_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
		_x setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
	
	} else {
		_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
		if (count _enyUnitsInside > 0) then {
			
			_hTaker = selectRandom _enyUnitsInside;
			_hTaker disableAI "PATH";
			_hRelDir = _hTaker getDir LMO_spawnBldg;
			//_hPos = getPosASL _hTaker;
			_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
			_x setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
		
		} else {
			
			_hTaker = selectRandom units _enyUnits;
			_hTaker disableAI "PATH";
			_hRelDir = _hTaker getDir LMO_spawnBldg;
			//_hPos = getPosASL _hTaker;
			_hPos = [getPos _hTaker, _hDisOffset, _hRelDir] call BIS_fnc_relPos;
			_x setPosASL [((_hPos select 0) + _hPosOffset), ((_hPos select 1) + _hPosOffset), (getPosASL _hTaker) select 2];
			
		};
	};
	_x setDir random 360;
}forEach (units _hostageGrp);