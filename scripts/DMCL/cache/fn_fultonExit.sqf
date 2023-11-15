params ["_cache","_taskMO","_taskMisMO"];
["LMOTaskOutcome", ["Cache preparing for uplift", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
_cAttached = attachedObjects _cache;
if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
_cPos = getPosATL _cache;

//Hides original cache
_cache hideObjectGlobal true;
_cache allowDamage false;
_cache setDamage 0;
_cache enableSimulationGlobal false;

diag_log "[LMO] No players in range, secured cache hidden. Exiting scope with fulton.";

//Creates uplift Cache
_cFly = "C_supplyCrate_F" createVehicle _cPos;
clearItemCargoGlobal _cFly;
clearWeaponCargoGlobal _cFly;
clearMagazineCargoGlobal _cFly;

//Creates Parachute
_cPara = "B_Parachute_02_F" createVehicle _cPos;
_cPara attachTo [_cFly, [0,0,7]];
detach _cPara;
_cPara hideObjectGlobal true;

//Creates Fulton Balloon and attaches to invisible Parachute
_cBalloon = createSimpleObject ["a3\structures_f_mark\items\sport\balloon_01_air_f.p3d", _cPos];
_cBalloon attachTo [_cPara, [0,0,-2]];
//detach _cBalloon;
_cPara disableCollisionWith _cFly;
_cPara disableCollisionWith _cBalloon;
_cBalloon setPosATL [(getPosATL _cPara) select 0,(getPosATL _cPara) select 1,((getPosATL _cPara) select 2)-2];
_cBalloon setObjectScale 1;
_inflate = 0.08;

//Inflates Fulton Balloon
[_cFly,_cBalloon,_cPara,_inflate,_cache] remoteExec ["LMO_fn_inflateBalloon",0,true];

//Uplift cache setVelocity
_bRise = 3;
_cacheRope = ropeCreate [_cPara, [0,0,-2],_cFly, [0,0,0.5], 30];
ropeUnwind [_cBalloon, 20, 100];
_cLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cFly;
_cLight allowDamage false;
_cLight attachTo [_cFly, [0,0,0.6]];
_flyMax = 1000;
_cacheRope allowDamage false;	

[
	{			
		(_this select 0) params ["_cFly","_cBalloon","_cPara","_cache","_bRise","_cacheRope","_cLight","_flyMax","_taskMO","_taskMisMO"];
		if (alive _cFly) then {
			
			//Fail-safe to reattach cache if detaches from rope
			if ((ropeAttachedTo _cFly) != _cPara) then {
				[_cFly, [0,0,0.5], [0,0,-1]] ropeAttachTo _cacheRope;
			};

			//Changes fulton rise rate based on height
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
				diag_log "[LMO] Cache successfully airlifted. Cache deleted.";
				[1,"_taskMO","_taskMisMO"] call LMO_fn_taskState;
				if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
					combat_readiness = combat_readiness - (LMO_Cache_Win_Alert * LMO_TST_Reward);
				} else {
					combat_readiness = combat_readiness - LMO_Cache_Win_Alert;
				};
				missionNamespace setVariable ["LMO_CacheTagged", nil, true];

				//get the nearestFOB and deliver cache boxes
				if (GRLIB_all_fobs isEqualTo []) exitWith {
					["LMOTaskOutcomeR", ["Cache lost in transit FOB not found", "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
				
				_cacheBox_Supply = 0;
				_cacheBox_Ammo = 0;
				_cacheBox_Fuel = 0;
				_fobStorage = objNull;
				_fobStorageObj = [];
				_fobStorageSort = [];

				//Generates values based on TST
				if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
					_cacheBox_Supply = round ((LMO_Cache_supplyBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
					_cacheBox_Ammo = round ((LMO_Cache_ammoBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
					_cacheBox_Fuel = round ((LMO_Cache_fuelBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
				} else {
					_cacheBox_Supply = LMO_Cache_supplyBoxes call BIS_fnc_randomInt;
					_cacheBox_Ammo = LMO_Cache_ammoBoxes call BIS_fnc_randomInt;
					_cacheBox_Fuel = LMO_Cache_fuelBoxes call BIS_fnc_randomInt;
				};

				//Get nearest fobs
				_nearFob = [getPos _cache] call KPLIB_fnc_getNearestFob; 
				_nearFobObjects = nearestObjects [_nearFob, ["BUILDING"], GRLIB_fob_range];

				{
					if (typeOf _x == KP_liberation_large_storage_building || typeOf _x == KP_liberation_small_storage_building) then {
						_fobStorageObj pushBack _x;
					};
				}forEach _nearFobObjects;

				_fobStorageSort = [_fobStorageObj, [], {_x distance _nearFob}, "ASCEND"] call BIS_fnc_sortBy;

				if (count _fobStorageSort > 0) then {
					_fobStorage = _fobStorageSort select 0;
				};
				
				diag_log format ["[LMO] Closest FOB: %1, fobStorage: %2, fobStorageList: %3",_nearFob,_fobStorage, count _fobStorageObj];
				

				if (!isNull _fobStorage) then {
					[(100*_cacheBox_Supply),(100*_cacheBox_Ammo),(100*_cacheBox_Fuel), _fobStorage] call KPLIB_fnc_fillStorage;
					["LMOTaskOutcomeG", ["Cache supplies uplifted to base", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];

					diag_log format ["[LMO] Rewards: %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates.",_cacheBox_Supply,_cacheBox_Ammo,_cacheBox_Fuel];
					

					[_this select 1] call CBA_fnc_removePerFrameHandler;
				} else {
					
					private _LMOcrate = objNull;
					
					["LMOTaskOutcomeG", ["Cache supplies uplifted to base", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];

					//Supply
					for "_i" from 1 to _cacheBox_Supply do { //Amount of box
						_LMOcrate = createVehicle [
							(KPLIB_crates select 0), //Type of box
							_nearFob,
							[],
							5,
							"NONE"
						];
						[_LMOcrate, true] call KPLIB_fnc_clearCargo;
						_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
						if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
						
					};

					//Ammo
					for "_i" from 1 to _cacheBox_Ammo do { //Amount of box
						_LMOcrate = createVehicle [
							(KPLIB_crates select 1), //Type of box
							_nearFob,
							[],
							5,
							"NONE"
						];
						[_LMOcrate, true] call KPLIB_fnc_clearCargo;
						_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
						if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
						
					};

					//Fuel
					for "_i" from 1 to _cacheBox_Fuel do { //Amount of box
						_LMOcrate = createVehicle [
							(KPLIB_crates select 2), //Type of box
							_nearFob,
							[],
							5,
							"NONE"
						];
						[_LMOcrate, true] call KPLIB_fnc_clearCargo;
						_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
						if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
						
					};
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
			};
		};
	},
	0.1,
	[_cFly,_cBalloon,_cPara,_cache,_bRise,_cacheRope,_cLight,_flyMax,"_taskMO","_taskMisMO"]
] call CBA_fnc_addPerFrameHandler;