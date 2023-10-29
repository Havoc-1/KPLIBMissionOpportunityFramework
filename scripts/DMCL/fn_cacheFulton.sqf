/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Fulton system to airlift cache
 *
 *	Arguments:
 *	0: Cache Object <OBJECT>
 *
 *	Examples:
 *	[_cache] call XEPKEY_fn_cacheFulton;
 */

params ["_cache"];

_nearbyCache = [];
if (LMO_Debug == true) then {systemChat format ["LMO: Delete loop started for Cache at %1.", getPos _cache]};
while {true} do {
	if (!alive _cache) exitWith {
			systemChat format ["LMO: Cache was destroyed before uplift."];
			["LMOTaskOutcome", ["Cache was destroyed before uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_missionState = 1;
	};
	
	if (alive _cache) then {
		_nearbyCache = (nearestObjects [_cache, ["Man", "LandVehicle"], LMO_FultonRng]) select {isPlayer _x};
	};
	if (count _nearbyCache == 0) exitWith {
		_cacheAttached = attachedObjects _cache;
		if (count _cacheAttached > 0) then {{deleteVehicle _x} forEach _cacheAttached};
		_cachePos = getPosATL _cache;
		_cache hideObjectGlobal true;
		
		if (LMO_Debug == true) then {systemChat "LMO: No players in range, secured cache hidden. Exiting scope with fulton."};
		
		_cacheFly = "C_supplyCrate_F" createVehicle _cachePos;
		_cacheBalloon = createSimpleObject ["a3\structures_f_mark\items\sport\balloon_01_air_f.p3d", _cachePos];
		_cacheBalloon attachTo [_cacheFly, [0,0,5]];
		detach _cacheBalloon;

		_cacheChute = "B_Parachute_02_F" createVehicle _cachePos;
		_cacheChute attachTo [_cacheFly, [0,0,7]];
		detach _cacheChute;
		_cacheChute hideObjectGlobal true;
		_cacheChute disableCollisionWith _cacheFly;
		_cacheChute disableCollisionWith _cacheBalloon;

		//Inflate Fulton
		[_cacheFly,_cacheBalloon,_cacheChute] spawn {
			params ["_cacheFly","_cacheBalloon","_cacheChute"];
			_cacheBalloon setObjectScale 1;
			_inflate = 0.03;
			while {getObjectScale _cacheBalloon <= 20 || (getPosATL _cacheBalloon) select 2 <= 20} do {
				_bHeight = (getPosATL _cacheBalloon) select 2;
				if (getObjectScale _cacheBalloon == 10) then {_inflate = 0};
				if (getObjectScale _cacheBalloon >= 4 && getObjectScale _cacheBalloon < 7) then {_inflate = 0.03};
				if (getObjectScale _cacheBalloon >= 7) then {_inflate = 0.01};
				_cacheBalloon setObjectScale ((getObjectScale _cacheBalloon) + _inflate);
				sleep .01;
			};
		};

		[_cacheFly,_cacheBalloon,_cacheChute,_cache] spawn {
			params ["_cacheFly","_cacheBalloon","_cacheChute","_cache"];
			_bRise = 3;
			_cacheRope = ropeCreate [_cacheChute, [0,0,-2],_cacheFly, [0,0,0.5], 30];
			ropeUnwind [_cacheBalloon, 20, 100];
			_cacheLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cacheFly;
			_cacheLight allowDamage false;
			_cacheLight attachTo [_cacheFly, [0,0,0.6]];
			_flyMax = 1000;
			while {alive _cacheFly} do {
				_bHeight = (getPosATL _cacheBalloon) select 2;
				_cacheBalloon setPos getPos _cacheChute;
				if (_bHeight >= _flyMax*0.025 && _bHeight < _flyMax*0.03) then {_bRise = 1};
				if (_bHeight >= _flyMax*0.03 && _bHeight < _flyMax*0.035) then {_bRise = 12};
				if (_bHeight >= _flyMax*0.035 && _bHeight < _flyMax*0.95) then {_bRise = 30};
				_cacheChute setVelocity [0,0,_bRise];
				[_cacheChute, 0, 0] call BIS_fnc_setPitchBank;

				if (_bHeight >= _flyMax) exitWith {
				ropeDestroy _cacheRope;
				deleteVehicle _cacheFly;
				deleteVehicle _cacheBalloon;
				deleteVehicle _cacheChute;
				deleteVehicle _cacheLight;
				["LMOTaskOutcome", ["Cache uplifted successfully", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
				deleteVehicle _cache;
				if (LMO_Debug == true) then {systemChat "LMO: Cache successfully airlifted. Cache deleted."};
				_missionState = 1;
				missionNamespace setVariable ["LMO_CacheTagged", nil];
				};
				sleep 0.01;
			};
		};				
	};
	sleep 5;
};