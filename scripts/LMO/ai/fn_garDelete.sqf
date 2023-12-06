/* 
	Author: [SGC] Xephros, [DMCL] Keystone
	Function to delete group after LMO is complete and players are no longer in range.

	Arguments:
		0: Enemy Group <GROUP>
		1: Range to start group delete <NUMBER> (Optional) - Delete group when no players are within this radius.

	Example:
		[_enyUnits] call LMO_fn_garDelete;
		[_enyUnits,400] call LMO_fn_garDelete;
 */

params ["_enyUnits",["_rng",400]];
[
	{
		!LMO_active;
	},
	{
		params ["_enyUnits","_rng"];
		if ({alive _x} count units _enyUnits > 0) then {
			["Starting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
			[
				{
					(_this select 0) params ["_enyUnits","_rng"];
					private _nearPlayers = [];
					private _near = [];
					if ({alive _x} count units _enyUnits > 0) then {
						
						{
							_nearPlayers = (nearestObjects [_x, ["CAManBase","LandVehicle"], _rng]) select {isPlayer _x};
							_near append _nearPlayers;
						}forEach units _enyUnits;
						
						if (count _near == 0) exitWith {
							{
								deleteVehicle _x;
							}forEach units _enyUnits;
							[_this select 1] call CBA_fnc_removePerFrameHandler;
							["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
						};
					} else {
						[_this select 1] call CBA_fnc_removePerFrameHandler;
						["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
					};
				},
				5,
				[_enyUnits,_rng]
			] call CBA_fnc_addPerFrameHandler;
		};
		
	},
	[_enyUnits,_rng]
] call CBA_fnc_waitUntilandExecute;
