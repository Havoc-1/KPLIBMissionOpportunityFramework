/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Fulton system to airlift cache
 *
 *	Arguments:
 *	0: Cache Object <OBJECT>
 *
 *	Examples:
 *	[_cache] call XEPKEY_fn_cacheFulton;
 *	
 *	Return Value: _missionState
 */

params ["_cache"];
[_cache] spawn {
	params ["_cache"];
	_cNear = [];
	_cNearPlayer = [];
	if (LMO_Debug == true) then {systemChat format ["LMO: Delete loop started for Cache at %1.", getPos _cache]};
	
	while {true} do {

		//Checks whether concious players and enemies are nearby cache
		_cNear = (nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_enemy};
		_cNearPlayer = ((nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CacheDefDist]) select {isPlayer _x}) select {!(_x getVariable ["ACE_isUnconscious", false])};
		if ((count _cNear > 0) && (count _cNearPlayer == 0)) exitWith {
			_cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
			if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
			deleteVehicle _cache;
			systemChat format ["LMO: Cache was secured by the enemy."];
			["LMOTaskOutcome", ["Cache was secured by the enemy", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
			[2] call XEPKEY_fn_taskState;
		};

		//Fail if cache is destroyed before uplift
		if (!alive _cache) exitWith {
				systemChat format ["LMO: Cache was destroyed before uplift."];
				["LMOTaskOutcome", ["Cache was destroyed before uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
				[1] call XEPKEY_fn_taskState;
		};

		//Win if cache is defended
		if (LMO_cTimer == 0 && alive _cache) exitWith {
			["LMOTaskOutcome", ["Cache preparing for uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_cAttached = attachedObjects _cache;
			if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
			_cPos = getPosATL _cache;
			_cache hideObjectGlobal true;
			_cache allowDamage false;
			_cache setDamage 0;
			
			if (LMO_Debug == true) then {systemChat "LMO: No players in range, secured cache hidden. Exiting scope with fulton."};
			
			_cFly = "C_supplyCrate_F" createVehicle _cPos;
			_cBalloon = createSimpleObject ["a3\structures_f_mark\items\sport\balloon_01_air_f.p3d", _cPos];
			_cBalloon attachTo [_cFly, [0,0,5]];
			detach _cBalloon;

			_cPara = "B_Parachute_02_F" createVehicle _cPos;
			_cPara attachTo [_cFly, [0,0,7]];
			detach _cPara;
			_cPara hideObjectGlobal true;
			_cPara disableCollisionWith _cFly;
			_cPara disableCollisionWith _cBalloon;

			//Inflate Fulton
			[_cFly,_cBalloon,_cPara] spawn {
				params ["_cFly","_cBalloon","_cPara"];
				_cBalloon setObjectScale 1;
				_inflate = 0.03;
				while {getObjectScale _cBalloon <= 20 || (getPosATL _cBalloon) select 2 <= 20} do {
					_bHeight = (getPosATL _cBalloon) select 2;
					if (getObjectScale _cBalloon == 10) then {_inflate = 0};
					if (getObjectScale _cBalloon >= 4 && getObjectScale _cBalloon < 7) then {_inflate = 0.03};
					if (getObjectScale _cBalloon >= 7) then {_inflate = 0.01};
					_cBalloon setObjectScale ((getObjectScale _cBalloon) + _inflate);
					sleep .01;
				};
			};

			[_cFly,_cBalloon,_cPara,_cache] spawn {
				params ["_cFly","_cBalloon","_cPara","_cache"];
				_bRise = 3;
				_cacheRope = ropeCreate [_cPara, [0,0,-2],_cFly, [0,0,0.5], 30];
				ropeUnwind [_cBalloon, 20, 100];
				_cLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cFly;
				_cLight allowDamage false;
				_cLight attachTo [_cFly, [0,0,0.6]];
				_flyMax = 1000;
				while {alive _cFly} do {
					_bHeight = (getPosATL _cBalloon) select 2;
					_cBalloon setPos getPos _cPara;
					if (_bHeight >= _flyMax*0.025 && _bHeight < _flyMax*0.03) then {_bRise = 1};
					if (_bHeight >= _flyMax*0.03 && _bHeight < _flyMax*0.035) then {_bRise = 8};
					if (_bHeight >= _flyMax*0.035 && _bHeight < _flyMax*0.95) then {_bRise = 26};
					_cPara setVelocity [0,0,_bRise];
					[_cPara, 0, 0] call BIS_fnc_setPitchBank;

					if (_bHeight >= _flyMax) exitWith {
					ropeDestroy _cacheRope;
					deleteVehicle _cFly;
					deleteVehicle _cBalloon;
					deleteVehicle _cPara;
					deleteVehicle _cLight;
					["LMOTaskOutcome", ["Cache uplifted successfully", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
					deleteVehicle _cache;
					if (LMO_Debug == true) then {systemChat "LMO: Cache successfully airlifted. Cache deleted."};
					[1] call XEPKEY_fn_taskState;
					missionNamespace setVariable ["LMO_CacheTagged", nil];
					};
					sleep 0.01;
				};
			};				
		};
		sleep 1;
	};
};