/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to initialize destroy cache LMO.
 *
 *	Arguments: None
 *
 *	Return Value: None
 *
 *	Example:
 *		[] call LMO_fn_missionCache;
 */

//Predefining Variables
private _cache = objNull;
private _cSpawnPos = getPosATL LMO_spawnBldg findEmptyPosition [0, 40, LMO_CacheModel];
LMO_cTimer = (LMO_CacheTimer)*60;

//Creates Task
private _tasks = [] call LMO_fn_taskCreate;

//Spawn Cache
if (count _cSpawnPos > 0) then {
	_cache = createVehicle [LMO_CacheModel, _cSpawnPos, [], 0, "CAN_COLLIDE"];
	[format ["Cache created at %1", position _cache],LMO_Debug] call LMO_fn_rptSysChat;
} else {
	_cache = createVehicle [getPos LMO_spawnBldg, LMO_CacheModel, [], 0, "CAN_COLLIDE"];
	[format ["No suitable cache spot found. Creating cache in target building at %1", position _cache],LMO_Debug] call LMO_fn_rptSysChat;
};

//Debug marker for cache location
if (LMO_Debug_Mkr) then {
	LMO_MkrDebug = createMarker ["LMO_MkrDebug", position _cache];
	LMO_MkrDebug setMarkerShape "ICON";
	LMO_MkrDebug setMarkerSize [1,1];
	LMO_MkrDebug setMarkerType "mil_dot";
	["Debug Marker created",LMO_DebugFull] call LMO_fn_rptSysChat;
};

//Empty contents of Cache
if (LMO_CacheEmpty == true) then {
	clearItemCargoGlobal _cache;
	clearWeaponCargoGlobal _cache;
	clearMagazineCargoGlobal _cache;
	["Cache cargo emptied.",LMO_DebugFull] call LMO_fn_rptSysChat;
};

//Add explosives to cache
if (LMO_CacheItems == true) then {
	{
		_cache addItemCargoGlobal [(_x select 0), (_x select 1)];
	} forEach LMO_CacheItemArray;
	["Cache items added.",LMO_DebugFull] call LMO_fn_rptSysChat;
};
_cache setVariable ["LMO_CacheSecure", false, true];

//Adds hold action to cache to secure
[
	_cache,
	"Secure Cache",
	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
	"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
	"(_this distance _target < 3) && (alive _target) && (cursorObject == _target) && ((_target getVariable 'LMO_CacheSecure') != true)",
	"(_caller distance _target < 3) && (alive _target) && ((_target getVariable 'LMO_CacheSecure') != true)",
	{
		_caller playMoveNow "Acts_carFixingWheel";
		playSound3D ["a3\sounds_f\characters\stances\rifle_to_launcher.wss", _target];
	},
	{
		if (_target getVariable ["LMO_CacheSecure",true]) then {
			_caller switchMove "";
			[_target,_actionId] call BIS_fnc_holdActionRemove;
			["Cache secured, cancelling action and deleting holdAction.",LMO_DebugFull] call LMO_fn_rptSysChat;
		};
	},
	{
		_caller switchMove "";
		_target setVariable ["LMO_CacheSecure", true, true];
		_cStrobe = "PortableHelipadLight_01_red_F" createVehicle getPos _target;
		_cStrobe attachTo [_target, [0,0.2,-0.7]];
		playSound3D ["a3\sounds_f\vehicles\soft\suv_01\suv_01_door.wss", _target];
		[
			{
				params ["_target"];
				playSound3D ["a3\sounds_f\sfx\beep_target.wss", _target];
			},
			[_target],
			0.5
		] call CBA_fnc_waitAndExecute;

		[format ["CacheSecure: %1", _target getVariable "LMO_CacheSecure"],LMO_DebugFull] call LMO_fn_rptSysChat;
		
		[_target,_actionId] call BIS_fnc_holdActionRemove;
	},
	{_caller switchMove ""},
	[_cache],
	5,
	2000,
	true,
	false
] remoteExec ["BIS_fnc_holdActionAdd", 0, _cache];
["Cache Hold action created.",LMO_DebugFull] call LMO_fn_rptSysChat;

//Destroy Cache if explosion EH
_cache addEventHandler ["Explosion", {
	params ["_vehicle", "_damage"];
	if (_damage > 1) then {
		private _cAttached = attachedObjects _vehicle select {typeOf _x == "PortableHelipadLight_01_red_F"};
		if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
		[format ["Cache destroyed, CacheSecure variable: %1", _vehicle getVariable "LMO_CacheSecure"],LMO_Debug] call LMO_fn_rptSysChat;
		_vehicle setDamage 1;
	};
	[format ["Cache Damaged: %1", _damage],LMO_Debug] call LMO_fn_rptSysChat;
}];

//Mission Outcome Checker
[
	{
		_args params ["_cache","_tasks"];
		private _missionState = 0;
		
		if (LMO_active) then {
			//Checks if cache is secured to halt timer
			if (_cache getVariable ["LMO_CacheSecure", true]) then {
				LMO_MkrName setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerPos position _cache;
				LMO_MkrName setMarkerPos position _cache;
				LMO_Mkr setMarkerSize [LMO_CacheDefDist,LMO_CacheDefDist];
				LMO_Mkr setMarkerBrush "Solid";
				private _cNearTimer = ((nearestObjects [_cache, ["CAManBase", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_enemy}) select {!(_x getVariable ["ACE_isUnconscious", false])};
				if (LMO_cTimer > 0 && (count _cNearTimer == 0)) then {
					LMO_cTimer = LMO_cTimer - 1;
					LMO_mTimerStr = [LMO_cTimer, "MM:SS"] call BIS_fnc_secondsToString;
				};
			} else {
				LMO_mTimer = LMO_mTimer - 1;
				LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
			};

			//Updates LMO Marker Time on map
			LMO_MkrName setMarkerText format [" %1 [%2]",LMO_MkrText, LMO_mTimerStr];
			
			//Fail LMO if timer expires
			if (LMO_mTimer == 0) then {
				_missionState = 2;
				["[Timer] Timer has expired.",LMO_Debug] call LMO_fn_rptSysChat;
			};

			//----Win Lose Conditions----//
			if (_missionState == 0) then {

				//Cache Win Conditions
				if (LMO_mTimer > 0) then {

					private _cSecured = missionNamespace getVariable ["LMO_CacheTagged",false];

					//If cache destroyed and NOT secured
					if ((!alive _cache) && (_cSecured == false)) then {
						_missionState = 1;
						["Cache was destroyed and not secured.",LMO_Debug] call LMO_fn_rptSysChat;
						["LMOTaskOutcomeG", ["Cache has been destroyed", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						[LMO_Cache_Win_Alert,0,false] call LMO_fn_rewards;
					};
					
					//If Secured Cache
					if ((alive _cache) && (_cache getVariable ["LMO_CacheSecure", true] && (_cSecured == false))) then {
						["LMOTaskOutcome", ["Cache has been located", "a3\ui_f\data\gui\rsccommon\rscbuttonsearch\search_start_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						
						//Marks cache as tagged in missionNameSpace to prevent loop executions
						missionNamespace setVariable ["LMO_CacheTagged",true,true];
						[format ["missionnameSpace _cSecured: %1. qrfCache and cacheFulton initializing.",missionNamespace getVariable "LMO_CacheTagged"],LMO_Debug] call LMO_fn_rptSysChat;
					
						//Defend cache
						[
							{
								["LMOTaskOutcomeR", ["Enemy forces are attempting to retake cache", "\a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							},
							[],
							11
						] call CBA_fnc_waitAndExecute;
						[
							{
								params ["_cache","_tasks"];
								[getpos _cache, LMO_qrfOutfit, 1, LMO_qrfSqdMultiply, LMO_qrfSplit, LMO_qrfPlayerRng, LMO_qrfSqdSpawnDist] call LMO_fn_qrfSpawner;
								[_cache,_tasks] call LMO_fn_cacheFulton;
							},
							[_cache,_tasks],
							1
						] call CBA_fnc_waitAndExecute;
					};
				};
				
				//Cache Lose Conditions
				if (LMO_mTimer == 0) then {
					//If Timer expires
					if (alive _cache && !(_cache getVariable ["LMO_CacheSecure", true])) then {
						_missionState = 2;
						[
							{!LMO_active},
							{
								missionNamespace setVariable ["LMO_CacheTagged", nil, true];
								["LMO_CacheTagged set to nil.",LMO_Debug] call LMO_fn_rptSysChat;
							},
							[]
						] call CBA_fnc_waitUntilAndExecute;

						[LMO_Cache_Lose_Alert,0,true] call LMO_fn_rewards;

						["LMOTaskOutcomeR", ["Cache has been moved by the enemy", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						private _cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
						if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
						deleteVehicle _cache;
						["Cache deleted.",LMO_Debug] call LMO_fn_rptSysChat;
					};
				};
			};
			
			//Ends Mission
			if (_missionState != 0) exitWith {
				[_missionState,_tasks] call LMO_fn_taskState;
				[_this select 1] call CBA_fnc_removePerFrameHandler;
				["Mission Finished, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
			};

		} else {
			//Removes PFH if mission is over.
			[_this select 1] call CBA_fnc_removePerFrameHandler;
			["LMO_active is false, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
		};

	},
	1,
	[_cache,_tasks]
] call CBA_fnc_addPerFrameHandler;