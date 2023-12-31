/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to temporarily remove throwables from LMO spawned unit inventory when interior, given back when exterior.
 *
 *	Arguments:
 *		0: Unit Group <GROUP>
 *
 *	Return Value:
 *	None
 */

params ["_enyUnits"];
[
	{
		(_this select 0) params ["_enyUnits"];
		if (count units _enyUnits > 0) then {
			{
				_unit = _x;
				_removeVar = _unit getVariable "LMO_removeThrow";
				if (insideBuilding _unit == 1 && (isNil "_removeVar")) then {
					_throwItems = [];
					_inv = magazinesAmmo _unit;
					//Adds throwables to _throwItems array
					{
						if (((_x select 0) call BIS_fnc_isThrowable) == true) then {
						_throwItems pushback _x;
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
		} else {
			["removeThrowables PFH removed.",LMO_DebugFull] call LMO_fn_rptSysChat;
			[_this select 1] call CBA_fnc_removePerFrameHandler;
		};
	},
	1,
	[_enyUnits]
] call CBA_fnc_addPerFrameHandler;
["removeThrowables PFH initialized.",LMO_DebugFull] call LMO_fn_rptSysChat;
