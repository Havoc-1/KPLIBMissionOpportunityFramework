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
		_cNearPlayer = ((nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_friendly}) select {!(_x getVariable ["ACE_isUnconscious", false])};
		if ((count _cNear > 0) && (count _cNearPlayer == 0)) exitWith {
			sleep 5;
			_cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
			if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
			deleteVehicle _cache;
			systemChat format ["LMO: Cache was secured by the enemy."];
			["LMOTaskOutcomeR", ["Cache was retaken by the enemy", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
			[2] call XEPKEY_fn_taskState;
		};

		//Fail if cache is destroyed before uplift
		if (!alive _cache) exitWith {
			systemChat format ["LMO: Cache was destroyed before uplift."];
			["LMOTaskOutcomeR", ["Cache was destroyed before uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			[1] call XEPKEY_fn_taskState;
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				combat_readiness = combat_readiness - (LMO_Cache_Win_Rdy * LMO_TST_Reward);
			} else {
				combat_readiness = combat_readiness - LMO_Cache_Win_Rdy;
			};
		};

		//Win if cache is defended
		if (LMO_cTimer == 0 && alive _cache) exitWith {
			["LMOTaskOutcome", ["Cache preparing for uplift", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_cAttached = attachedObjects _cache;
			if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
			_cPos = getPosATL _cache;
			_cache hideObjectGlobal true;
			_cache allowDamage false;
			_cache setDamage 0;
			
			if (LMO_Debug == true) then {systemChat "LMO: No players in range, secured cache hidden. Exiting scope with fulton."};
			
			_cFly = "C_supplyCrate_F" createVehicle _cPos;
			_cPara = "B_Parachute_02_F" createVehicle _cPos;
			_cPara attachTo [_cFly, [0,0,7]];
			detach _cPara;
			_cPara hideObjectGlobal true;

			_cBalloon = createSimpleObject ["a3\structures_f_mark\items\sport\balloon_01_air_f.p3d", _cPos];
			_cBalloon attachTo [_cPara, [0,0,-2]];
			//detach _cBalloon;
			
			_cPara disableCollisionWith _cFly;
			_cPara disableCollisionWith _cBalloon;

			//Inflate Fulton
			[_cFly,_cBalloon,_cPara] spawn {
				params ["_cFly","_cBalloon","_cPara"];
				_cBalloon setObjectScale 1;
				_inflate = 0.08;
				while {getObjectScale _cBalloon <= 20 || (getPosATL _cBalloon) select 2 <= 20} do {
					_bHeight = (getPosATL _cBalloon) select 2;
					if (getObjectScale _cBalloon == 20) then {_inflate = 0};
					if (getObjectScale _cBalloon >= 4 && getObjectScale _cBalloon < 7) then {_inflate = 0.15};
					if (getObjectScale _cBalloon >= 15) then {_inflate = 0.03};
					_cBalloon setObjectScale ((getObjectScale _cBalloon) + _inflate);
					sleep 0.1;
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
					if (_bHeight >= _flyMax*0.025 && _bHeight < _flyMax*0.03) then {_bRise = 1};
					if (_bHeight >= _flyMax*0.03 && _bHeight < _flyMax*0.035) then {_bRise = 6};
					if (_bHeight >= _flyMax*0.035 && _bHeight < _flyMax*0.95) then {_bRise = 20};
					_cPara setVelocity [0,0,_bRise];
					[_cPara, 0, 0] call BIS_fnc_setPitchBank;

					if (_bHeight >= _flyMax) exitWith {
						ropeDestroy _cacheRope;
						deleteVehicle _cFly;
						deleteVehicle _cBalloon;
						deleteVehicle _cPara;
						deleteVehicle _cLight;
						deleteVehicle _cache;
						if (LMO_Debug == true) then {systemChat "LMO: Cache successfully airlifted. Cache deleted."};
						[1] call XEPKEY_fn_taskState;
						if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
							combat_readiness = combat_readiness - (LMO_Cache_Win_Rdy * LMO_TST_Reward);
						} else {
							combat_readiness = combat_readiness - LMO_Cache_Win_Rdy;
						};
						missionNamespace setVariable ["LMO_CacheTagged", nil];

						//get the nearestFOB
						if (GRLIB_all_fobs isEqualTo []) exitWith {["LMOTaskOutcomeR", ["Cache lost in transit FOB not found", "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];};
						
						_cacheBox_Supply = 0;
						_cacheBox_Ammo = 0;
						_cacheBox_Fuel = 0;
						_foundStorage = objNull;

						if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
							_cacheBox_Supply = round ((LMO_Cache_supplyBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
							_cacheBox_Ammo = round ((LMO_Cache_ammoBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
							_cacheBox_Fuel = round ((LMO_Cache_fuelBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
						} else {
							_cacheBox_Supply = LMO_Cache_supplyBoxes call BIS_fnc_randomInt;
							_cacheBox_Ammo = LMO_Cache_ammoBoxes call BIS_fnc_randomInt;
							_cacheBox_Fuel = LMO_Cache_fuelBoxes call BIS_fnc_randomInt;
						};

						_closeSupplyDump = [getPos _cache] call KPLIB_fnc_getNearestFob; 
						_foundStorage = nearestObject [_closeSupplyDump, KP_liberation_large_storage_building];
						
						if (LMO_Debug == true) then {
							systemChat format ["LMO: Closest FOB: %1, foundStorage: %2",_closeSupplyDump,_foundStorage];
						};

						if (!isNull _foundStorage) then {
							[(100*_cacheBox_Supply),(100*_cacheBox_Ammo),(100*_cacheBox_Fuel), _foundStorage] call KPLIB_fnc_fillStorage;
							["LMOTaskOutcomeG", ["Cache supplies uplifted to base", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
						};
						
						if (isNull _foundStorage) then {
							
							XEPKEY_cacheReward = [];
							private _LMOcrate = objNull;
							
							["LMOTaskOutcomeG", ["Cache supplies uplifted to base", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
			
							//Supply
							for "_i" from 1 to _cacheBox_Supply do { //Amount of box
								_LMOcrate = createVehicle [
									(KPLIB_crates select 0), //Type of box
									_closeSupplyDump,
									[],
									5,
									"NONE"
								];
								[_LMOcrate, true] call KPLIB_fnc_clearCargo;
								_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
								if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
								XEPKEY_cacheReward pushBack _LMOcrate;
							};

							//Ammo
							for "_i" from 1 to _cacheBox_Ammo do { //Amount of box
								_LMOcrate = createVehicle [
									(KPLIB_crates select 1), //Type of box
									_closeSupplyDump,
									[],
									5,
									"NONE"
								];
								[_LMOcrate, true] call KPLIB_fnc_clearCargo;
								_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
								if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
								XEPKEY_cacheReward pushBack _LMOcrate;
							};

							//Fuel
							for "_i" from 1 to _cacheBox_Fuel do { //Amount of box
								_LMOcrate = createVehicle [
									(KPLIB_crates select 2), //Type of box
									_closeSupplyDump,
									[],
									5,
									"NONE"
								];
								[_LMOcrate, true] call KPLIB_fnc_clearCargo;
								_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
								if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
								XEPKEY_cacheReward pushBack _LMOcrate;
							};
						};
					};
					sleep 0.1;
				};
			};				
		};
		sleep 1;
	};
};