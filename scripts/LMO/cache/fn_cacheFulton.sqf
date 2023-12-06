/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Fulton system to airlift cache
 *
 *	Arguments:
 *	0: Cache Object <OBJECT>
 *
 *	Examples:
 *	[_cache] call LMO_fn_cacheFulton;
 *	
 *	Return Value: _missionState
 */

params ["_cache","_tasks"];
diag_log format ["[LMO] [Cache] Delete loop started for Cache at %1.", getPos _cache];
[format ["Delete loop started for Cache at %1.", getPos _cache],LMO_Debug] call LMO_fn_rptSysChat;
	
[	
	{
		(_this select 0) params ["_cache","_tasks"];
		//Checks whether concious players and enemies are nearby cache
		private _cNear = (nearestObjects [_cache, ["CAManBase", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_enemy && {!(_x getVariable ["ACE_isUnconscious", false])}};
		private _cNearPlayer = (nearestObjects [_cache, ["CAManBase", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_friendly && {!(_x getVariable ["ACE_isUnconscious", false])}};
		if ((count _cNear > 0) && (count _cNearPlayer == 0)) exitWith {

			["Cache was secured by the enemy.",LMO_Debug] call LMO_fn_rptSysChat;
			[LMO_Cache_Lose_Alert,0,true] call LMO_fn_rewards;

			[
				{
					params ["_cache","_tasks"];
					private _cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
					if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
					deleteVehicle _cache;
					["LMOTaskOutcomeR", ["Cache was retaken by the enemy", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
					[
						{!LMO_active},
						{
							missionNamespace setVariable ["LMO_CacheTagged", nil, true];
							["LMO_CacheTagged set to nil.",LMO_DebugFull] call LMO_fn_rptSysChat;
						},
						[]
					] call CBA_fnc_waitUntilAndExecute;
					[2,_tasks] call LMO_fn_taskState;
				},
				[_cache,_tasks],
				5
			] call CBA_fnc_waitAndExecute;
			[_this select 1] call CBA_fnc_removePerFrameHandler;	
		};

		//Fail if cache is destroyed before uplift
		if (!alive _cache) exitWith {
			[
				{!LMO_active},
				{
					missionNamespace setVariable ["LMO_CacheTagged", nil, true];
					["LMO_CacheTagged set to nil.",LMO_DebugFull] call LMO_fn_rptSysChat;
				},
				[]
			] call CBA_fnc_waitUntilAndExecute;
			["Cache was destroyed before uplift.",LMO_Debug] call LMO_fn_rptSysChat;
			["LMOTaskOutcomeR", ["Cache was destroyed before uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			[1,_tasks] call LMO_fn_taskState;
			[LMO_Cache_Win_Alert,0,false] call LMO_fn_rewards;
			[_this select 1] call CBA_fnc_removePerFrameHandler;	
		};

		//Win if cache is defended
		if (LMO_cTimer == 0 && alive _cache) exitWith {
			[_cache,_tasks] call LMO_fn_fultonExit;
			["Cache has been defended, initializing fultonExit. Exiting cacheFulton PFH.",LMO_Debug] call LMO_fn_rptSysChat;
			[_this select 1] call CBA_fnc_removePerFrameHandler;
		};
	},
	1,
	[_cache,_tasks]
] call CBA_fnc_addPerFrameHandler;