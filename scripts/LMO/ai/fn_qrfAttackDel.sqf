/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to automatically delete QRF units when players are out of range and loop attack waypoint on position.
 *
 *	Arguments:
 *		0: QRF Group <GROUP>
 *		1: Position to move <ARRAY> - Static position for group to attack, does not update if position is moved.
 *		2: Object to attack <OBJECT> (Optional) - Argument 1 is not used if this is defined, group will attack position of this object (used for moving objects).
 *
 *	Examples:
 *		[enyGrp, [0,0,0], box1] call LMO_fn_qrfAttackDel;
 *	
 *	Return Value: None
 */

params ["_enyUnits","_pos",["_obj", nil]];

[
	{
		(_this select 0) params ["_enyUnits",["_pos",[0,0,0]],["_obj", nil]];
		
		if (!isNil "_obj") then {
			if (alive "_obj") then {
				_pos = getPos _obj;
			};
		};

		private _pCount = [];
		if ({alive _x} count units _enyUnits > 0) then {
			[_enyUnits] call CBA_fnc_clearWaypoints;
			[_enyUnits, _pos, 0] call CBA_fnc_taskAttack;
			{
				_pCount = (nearestObjects [_x, ["CAManBase"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
			}forEach units _enyUnits;
		};
		if (count _pCount == 0 && !LMO_active) exitWith {
			{deleteVehicle _x}forEach units _enyUnits;
			deleteGroup _enyUnits;
			[_this select 1] call CBA_fnc_removePerFrameHandler;
		};
	},
	20,
	[_enyUnits,_pos,_obj]
] call CBA_fnc_addPerFrameHandler;