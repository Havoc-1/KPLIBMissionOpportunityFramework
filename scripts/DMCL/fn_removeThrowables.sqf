/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Function to temporarily remove throwables from LMO spawned unit inventory when interior, given back when exterior.
 *
 *	Arguments:
 *	None
 *
 *	Return Value:
 *	None
 */

[_enyUnits] spawn {
	params ["_enyUnits"];
	sleep 5;
	while {count units _enyUnits > 0} do {
		{
			_unit = _x;
			_removeVar = _unit getVariable "LMO_removeThrow";
			if (insideBuilding _unit == 1 && (isNil "_removeVar")) then {
				_throwItems = [];
				_inv = magazinesAmmo _unit;
				//Adds throwables to _throwItems array
				{
					if (((_x select 0) call BIS_fnc_isThrowable) == true) then {
					_throwItems append [_x];
					};
				}forEach _inv;
				//Marks unit as throwables removed, offloads inv to variable, and removes throwable items
				_unit setVariable ["LMO_removeThrow", true];
				_unit setVariable ["LMO_Throwables", _throwItems];
				{_unit removeMagazines (_x select 0)}forEach _throwItems;
			};
			if (insideBuilding _unit == 0 && ((_unit getVariable ["LMO_removeThrow", false]) == true)) then {
				{_unit addMagazines _x}forEach (_unit getVariable "LMO_Throwables");
				_unit setVariable ["LMO_removeThrow", nil];
				_unit setVariable ["LMO_Throwables", nil];
				_throwItems = [];
			};
		}forEach units _enyUnits;
		sleep 1;
	};
};