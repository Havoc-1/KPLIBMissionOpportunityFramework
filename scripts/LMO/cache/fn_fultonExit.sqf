/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to fulton airlift cache.
 *
 *	Arguments:
 *		0: Cache <OBJECT>
 *		1: Task Array <ARRAY>
 *			1: Parent Task <STRING>
 *			2: Child Task <STRING>
 *
 *	Examples:
 *		[_cache,_tasks] call LMO_fn_fultonExit;
 *	
 *	Return Value: None
 */

params ["_cache","_tasks"];
["LMOTaskOutcome", ["Cache preparing for uplift", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
private _cAttached = [];
private _cPos = [];
private _cPara = objNull;
private _cFly = objNull;
private _cBalloon = objNull;
private _inflate = 0.08;
private _bRise = 3;
private _cacheRope = objNull;
private _cLight = objNull;
private _flyMax = 1000;

_cAttached = attachedObjects _cache;
if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
_cPos = getPosATL _cache;

//Hides original cache
_cache hideObjectGlobal true;
_cache allowDamage false;
_cache setDamage 0;
_cache enableSimulationGlobal false;

["fultonExit initialized.",LMO_Debug] call LMO_fn_rptSysChat;

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

//Inflates Fulton Balloon
[_cFly,_cBalloon,_cPara,_inflate,_cache] remoteExec ["LMO_fn_inflateBalloon",0,true];

//Uplift cache setVelocity

_cacheRope = ropeCreate [_cPara, [0,0,-2],_cFly, [0,0,0.5], 30];
ropeUnwind [_cBalloon, 20, 100];
_cLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cFly;
_cLight allowDamage false;
_cLight attachTo [_cFly, [0,0,0.6]];
_cacheRope allowDamage false;	

[
	{			
		(_this select 0) params ["_cFly","_cBalloon","_cPara","_cache","_bRise","_cacheRope","_cLight","_flyMax","_tasks"];
		if (alive _cFly) then {
			
			//Fail-safe to reattach cache if detaches from rope
			if ((ropeAttachedTo _cFly) != _cPara) then {
				[_cFly, [0,0,0.5], [0,0,-1]] ropeAttachTo _cacheRope;
			};

			//Changes fulton rise rate based on height
			private _bHeight = (getPosATL _cBalloon) select 2;
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
				["Cache successfully airlifted. Cache deleted.",LMO_Debug] call LMO_fn_rptSysChat;
				[1,_tasks] call LMO_fn_taskState;
				[LMO_Cache_Win_Alert,0,false] call LMO_fn_rewards;

				[
					{!LMO_active},
					{
						missionNamespace setVariable ["LMO_CacheTagged", nil, true];
						["LMO_CacheTagged set to nil.",LMO_Debug] call LMO_fn_rptSysChat;
					},
					[]
				] call CBA_fnc_waitUntilAndExecute;
				

				//get the nearestFOB and deliver cache boxes
				if (GRLIB_all_fobs isEqualTo []) exitWith {
					["LMOTaskOutcomeR", ["Cache lost in transit FOB not found", "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
				[[LMO_Cache_supplyBoxes,LMO_Cache_ammoBoxes,LMO_Cache_fuelBoxes,getPos _cache],3] call LMO_fn_rewards;
				/* private _crate_Supply = 0;
				private _crate_Ammo = 0;
				private _crate_Fuel = 0;
				private _fobStorage = objNull;
				private _fobStorageObj = [];
				private _fobStorageSort = [];

				//Generates values based on TST
				if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
					_crate_Supply = round ((LMO_Cache_supplyBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
					_crate_Ammo = round ((LMO_Cache_ammoBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
					_crate_Fuel = round ((LMO_Cache_fuelBoxes call BIS_fnc_randomInt) * LMO_TST_Reward);
				} else {
					_crate_Supply = LMO_Cache_supplyBoxes call BIS_fnc_randomInt;
					_crate_Ammo = LMO_Cache_ammoBoxes call BIS_fnc_randomInt;
					_crate_Fuel = LMO_Cache_fuelBoxes call BIS_fnc_randomInt;
				};

				//Get nearest fobs
				_nearFob = [getPos _cache] call KPLIB_fnc_getNearestFob;
				_nearFobName = [_nearFob] call KPLIB_fnc_getFobName;
				_nearFobObjects = nearestObjects [_nearFob, ["BUILDING"], GRLIB_fob_range];

				//Filters objects to storage only
				{
					if (typeOf _x == KP_liberation_large_storage_building || typeOf _x == KP_liberation_small_storage_building) then {
						_fobStorageObj pushBack _x;
					};
				}forEach _nearFobObjects;

				//Sorts storage by ascending distance to FOB
				_fobStorageSort = [_fobStorageObj, [], {_x distance _nearFob}, "ASCEND"] call BIS_fnc_sortBy;
				
				diag_log format ["[LMO] [Cache] Closest FOB: FOB %1, Storage Containers: %2",_nearFobName, count _fobStorageSort];
				
				private _cacheRewards = _crate_Supply + _crate_Ammo + _crate_Fuel;
				private _c1 = _crate_Supply;
				private _c2 = _crate_Ammo;
				private _c3 = _crate_Fuel;
				
				["LMOTaskOutcomeG", [format ["Cache supplies uplifted to FOB %1", _nearFobName], "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
				diag_log format ["[LMO] [Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates.",_crate_Supply,_crate_Ammo,_crate_Fuel];
				if (count _fobStorageObj > 0) then {
					[_fobStorageSort,_cacheRewards,_c1,_c2,_c3,_nearFob,_nearFobName] spawn {
						params ["_fobStorageSort","_cacheRewards","_c1","_c2","_c3","_nearFob","_nearFobName"];
						{
							while {_cacheRewards >= 0} do {

								if (_cacheRewards == 0) exitWith {
								diag_log "[LMO] [Reward] All Cache crates assigned, exiting fultonExit PFH.";
								};

								([_x] call KPLIB_fnc_getStoragePositions) params ["_storage_positions", "_unload_distance"];
								_crates_count = count (attachedObjects _x);
								if ((_crates_count >= (count _storage_positions)) && (count _fobStorageSort > 0) && ((_fobStorageSort find _x) != ((count _fobStorageSort) - 1))) exitWith {
									diag_log format ["[LMO] [Reward] %1 at FOB %2 does not have enough space to store crates. Moving to next storage.", typeOf _x, _nearFobName];
								};
								if ((_cacheRewards > 0) && (count _fobStorageSort > 1) && (_crates_count >= (count _storage_positions)) && (((_fobStorageSort find _x) == ((count _fobStorageSort) - 1)))) exitWith {
									diag_log format ["[LMO] [Reward] No storage containers available at FOB to store crates, delivering to FOB %1", _nearFobName];
									_crateArray = [[_c1,0],[_c2,1],[_c3,2]];
									{
										if ((_x select 0) > 0) then {
											for "_i" from 1 to (_x select 0) do { //Amount of box
												_LMOcrate = createVehicle [
													(KPLIB_crates select (_x select 1)), //Type of box
													_nearFob,
													[],
													5,
													"NONE"
												];
												[_LMOcrate, true] call KPLIB_fnc_clearCargo;
												_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
												if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
											};
										};
									}forEach _crateArray;
									diag_log format ["[LMO] [Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates delivered to FOB %4", _c1, _c2, _c3, _nearFobName];
								};

								diag_log format ["[LMO] [Reward] fillStorage attempt on %1 at FOB %2.", typeOf _x, _nearFobName];
								if (_c1 > 0) then {
									[100, 0, 0, _x] call KPLIB_fnc_fillStorage;
									_c1 = _c1 - 1;
									_cacheRewards = _cacheRewards - 1;
									diag_log format ["[LMO] [Reward] fillStorage successful on %1 at FOB %2. (Supply Crate)", typeOf _x,_nearFobName];
								} else {
									if (_c2 > 0) then {
										[0, 100, 0, _x] call KPLIB_fnc_fillStorage;
										_c2 = _c2 - 1;
										_cacheRewards = _cacheRewards - 1;
										diag_log format ["[LMO] [Reward] fillStorage successful on %1 at FOB %2. (Ammo Crate)", typeOf _x,_nearFobName];
									} else {
										if (_c3 > 0) then {
											_c3 = _c3 - 1;
											_cacheRewards = _cacheRewards - 1;
											[0, 0, 100, _x] call KPLIB_fnc_fillStorage;
											diag_log format ["[LMO] [Reward] fillStorage successful on %1 at FOB %2. (Fuel Crate)", typeOf _x,_nearFobName];
										};
									};
								};
								sleep 0.1;
							};
						}forEach _fobStorageSort;
					};
				} else {
					diag_log format ["[LMO] [Reward] No storage containers available at FOB to store crates, delivering to FOB %1", _nearFobName];
					_crateArray = [[_c1,0],[_c2,1],[_c3,2]];
					{
						if ((_x select 0) > 0) then {
							for "_i" from 1 to (_x select 0) do { //Amount of box
								_LMOcrate = createVehicle [
									(KPLIB_crates select (_x select 1)), //Type of box
									_nearFob,
									[],
									5,
									"NONE"
								];
								[_LMOcrate, true] call KPLIB_fnc_clearCargo;
								_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
								if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
							};
						};
					}forEach _crateArray;
					diag_log format ["[LMO] [Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates delivered to FOB %4", _c1, _c2, _c3, _nearFobName];
				}; */
				
				//Remove PFH for while do spawn
				[_this select 1] call CBA_fnc_removePerFrameHandler;
			};
		};
	},
	0.1,
	[_cFly,_cBalloon,_cPara,_cache,_bRise,_cacheRope,_cLight,_flyMax,_tasks]
] call CBA_fnc_addPerFrameHandler;