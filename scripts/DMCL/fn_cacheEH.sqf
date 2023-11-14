//Determines QRF spawn position
["LMO_qrfPos",
	{
		diag_log "[LMO] LMO_qrfPos Start";
		params ["_cache","_sqdSize","_sqdOrbat"];
		//Checks for suitable QRF spawn location
		_qrfFriendlyCount = -1;
		_qrfGrp1Rad = random 360;
		_qrfSpawnDist = LMO_CacheSqdSpawnDist;
		_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp1Rad] call BIS_fnc_relPos;
		_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
		if (_qrfFriendlyCount != 0) then {
			[
				{
					(_this select 0) params ["_qrfFriendlyCount","_qrfSpawnDist","_qrfSpawnPos","_qrfGrp1Rad","_cache","_sqdSize","_sqdOrbat"];
					if (_qrfFriendlyCount != 0) then {
						_qrfSpawnDist = _qrfSpawnDist + 20;
						_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp1Rad] call BIS_fnc_relPos;
						_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
					} else {
						["LMO_qrfSpawn",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad]] call CBA_fnc_serverEvent;
						[_this select 1] call CBA_fnc_removePerFrameHandler;
					};
				},
				0.1,
				[_qrfFriendlyCount,_qrfSpawnDist,_qrfSpawnPos,_qrfGrp1Rad,_cache,_sqdSize,_sqdOrbat]
			] call CBA_fnc_addPerFrameHandler;
		} else {
			["LMO_qrfSpawn",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad]] call CBA_fnc_serverEvent;
			[_this select 1] call CBA_fnc_removePerFrameHandler;
		};
	}
] call CBA_fnc_addEventHandler;

//Spawn Enemies
["LMO_qrfSpawn",
	{
		diag_log "[LMO] qrfSpawnPos found, initializing qrfSpawn.";
		params ["_cache","_sqdSize","_sqdOrbat","_qrfGrp1Rad"];
		_qrfCounter = 0;
		_enyUnits = createGroup east;
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, 
				_qrfSpawnPos,
				[],0,"NONE"
			];
			[_enyUnitsHolder] joinSilent _enyUnits;
			
			_qrfCounter = _qrfCounter + 1;
			
			if (_qrfCounter == _sqdSize) then {
				["LMO_qrfSplit",[_enyUnits,_sqdSize,_qrfGrp1Rad,_cache]] call CBA_fnc_serverEvent;
			};

		} forEach _sqdOrbat;
	}
] call CBA_fnc_addEventHandler;

//Determines QRF spawn position for split group
["LMO_qrfSplit",
	{
		params ["_enyUnits","_sqdSize","_qrfGrp1Rad","_cache"];
		_splitGrp = random 1;
		_sqd2Size = 0;
		_qrfGrp2Rad = 0;
		_qrfRadDiff = 50;
		_qrfFriendlyCount = -1;
		if (_splitGrp > 0.5) then {
			diag_log "[LMO] qrfSplit > 0.5, splitting QRF.";
			_sqd2Size = round (_sqdSize/2);

			_qrfGrp2Rad = (_qrfGrp1Rad + ((random (360 - (_qrfRadDiff * 2))) + _qrfRadDiff)) % 360;

			_qrfSpawnDist = LMO_CacheSqdSpawnDist;
			_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp2Rad] call BIS_fnc_relPos;
			_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
			
			//Select QRF position
			if (_qrfFriendlyCount != 0) then {
				[
					{
						(_this select 0) params ["_qrfFriendlyCount","_qrfGrp2Rad","_qrfGrp1Rad","_qrfSpawnDist","_qrfSpawnPos","_cache","_sqd2Size"];
						if (_qrfFriendlyCount != 0) then {
							_qrfGrp2Rad = (_qrfGrp1Rad + ((random 260) + 50)) % 360;
							_qrfSpawnDist = _qrfSpawnDist + 20;
							_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp2Rad] call BIS_fnc_relPos;
							_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
						} else {
							diag_log "[LMO] LMO_qrfSplit EH done.";
							["LMO_qrfGrp2",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos]] call CBA_fnc_serverEvent;
							[_this select 1] call CBA_fnc_removePerFrameHandler;
						}
					},
					0.1,
					[_qrfFriendlyCount,_qrfGrp2Rad,_qrfGrp1Rad,_qrfSpawnDist,_qrfSpawnPos,_cache,_sqd2Size]
				] call CBA_fnc_addPerFrameHandler;
			} else {
				diag_log "[LMO] LMO_qrfSplit EH done.";
				["LMO_qrfGrp2",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos]] call CBA_fnc_serverEvent;
			};
		} else {
			if (LMO_Debug && (count units _enyUnits > 0)) then {diag_log format ["[LMO] QRF Size: %1, QRF Dir: %2",_sqdSize,round _qrfGrp1Rad]};

			if (LMO_VCOM_On == true) then {
				_enyUnits setVariable ["VCM_NORESCUE",true];
			};

			_enyUnits setSpeedMode "FULL";
			//_enyUnits move getPos _cache;
			[_enyUnits, getPos _cache, 10] call CBA_fnc_taskAttack;

			["LMO_qrfDelete",[_enyUnits,_cache,_enyUnits2]] call CBA_fnc_serverEvent;
		};
	}
] call CBA_fnc_addEventHandler;

//Wait Until QRF spawn position is chosen then split group
["LMO_qrfGrp2",
	{
		params ["_cache","_sqdSize","_sqdOrbat","_qrfGrp1Rad","_sqd2Size","_qrfSpawnPos"];
		_enyUnits2 = createGroup east;
		_sqd2Orbat = [];
		for "_i" from _sqd2Size to _sqdSize do {
			_sqd2Unit = selectRandom units _enyUnits;
			_sqd2Orbat pushBack _sqd2Unit;
			_sqd2Unit setPos _qrfSpawnPos;
		};
		_sqd2Orbat joinSilent _enyUnits2;
		
		if (LMO_VCOM_On == true) then {
			_enyUnits2 setVariable ["VCM_NORESCUE",true];
		};


		_enyUnits2 setSpeedMode "FULL";
		//_enyUnits2 move getPos _cache;
		[_enyUnits2, getPos _cache, 10] call CBA_fnc_taskAttack;


		["LMO_qrfDelete",[_enyUnits,_cache,_enyUnits2]] call CBA_fnc_serverEvent;
		if (LMO_Debug && (count units _enyUnits > 0)) then {diag_log format ["[LMO] QRF Size: %1, QRF1 Dir: %2, QRF2 Dir: %3",_sqdSize,round ((getPos _cache) getDir (selectRandom units _enyUnits)),round ((getPos _cache) getDir (selectRandom units _enyUnits2))]};
	}
] call CBA_fnc_addEventHandler;

//Deletes QRF if OBJ is complete and no players are in range	
["LMO_qrfDelete",
	{
		params ["_enyUnits","_cache","_enyUnits2"];
		
		//enyUnits Grp1
		[
			{
				(_this select 0) params ["_enyUnits","_cache"];
				_enyUnitPlayers = [];
				if ({alive _x} count units _enyUnits > 0) then {
					//_enyUnits move getPos _cache;
					[_enyUnits] call CBA_fnc_clearWaypoints;
					[_enyUnits, getPos _cache, 10] call CBA_fnc_taskAttack;
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
					}forEach units _enyUnits;
				};
				if ((count _enyUnitPlayers == 0) && !alive _cache) exitWith {
					{deleteVehicle _x}forEach units _enyUnits;
					deleteGroup _enyUnits;
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
			},
			20,
			[_enyUnits,_cache]
		] call CBA_fnc_addPerFrameHandler;
		
		//enyUnits Grp2
		if (_splitGrp > 0.5) then {
			[
				{
					(_this select 0) params ["_cache","_enyUnits2"];
					_enyUnitPlayers2 = [];
					if ({alive _x} count units _enyUnits2 > 0) then {
						//_enyUnits2 move getPos _cache;
						[_enyUnits2] call CBA_fnc_clearWaypoints;
						[_enyUnits2, getPos _cache, 10] call CBA_fnc_taskAttack;
						{
							_enyUnitPlayers2 = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
						}forEach units _enyUnits2;
					};
					if ((count _enyUnitPlayers2 == 0) && !alive _cache) exitWith {
						{deleteVehicle _x}forEach units _enyUnits2;
						deleteGroup _enyUnits2;
						[_this select 1] call CBA_fnc_removePerFrameHandler;
					};
				},
				20,
				[_cache,_enyUnits2]
			] call CBA_fnc_addPerFrameHandler;
		};
	}
] call CBA_fnc_addEventHandler;

["LMO_fultonExit",
	{
		params ["_cache","_taskMO","_taskMisMO"];
		["LMOTaskOutcome", ["Cache preparing for uplift", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
		_cAttached = attachedObjects _cache;
		if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
		_cPos = getPosATL _cache;
		_cache hideObjectGlobal true;
		_cache allowDamage false;
		_cache setDamage 0;

		if (LMO_Debug) then {diag_log "[LMO] No players in range, secured cache hidden. Exiting scope with fulton."};

		//Creates uplift Cache, hides original cache, creates Parachute
		_cFly = "C_supplyCrate_F" createVehicle _cPos;
		_cPara = "B_Parachute_02_F" createVehicle _cPos;
		_cPara attachTo [_cFly, [0,0,7]];
		detach _cPara;
		_cPara hideObjectGlobal true;
		_cache enableSimulationGlobal false;

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
		[_cFly,_cBalloon,_cPara,_inflate,_cache] remoteExec ["XEPKEY_fn_inflateBalloon",0,true];

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
						if (LMO_Debug) then {diag_log "[LMO] Cache successfully airlifted. Cache deleted."};
						[1,"_taskMO","_taskMisMO"] call XEPKEY_fn_taskState;
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
						
						if (LMO_Debug) then {
							diag_log format ["[LMO] Closest FOB: %1, fobStorage: %2, fobStorageList: %3",_nearFob,_fobStorage, count _fobStorageObj];
						};

						if (!isNull _fobStorage) then {
							[(100*_cacheBox_Supply),(100*_cacheBox_Ammo),(100*_cacheBox_Fuel), _fobStorage] call KPLIB_fnc_fillStorage;
							["LMOTaskOutcomeG", ["Cache supplies uplifted to base", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];

							if (LMO_Debug) then {
							diag_log format ["[LMO] Rewards: %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates.",_cacheBox_Supply,_cacheBox_Ammo,_cacheBox_Fuel];
							};

							[_this select 1] call CBA_fnc_removePerFrameHandler;
						} else {
							
							=
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
	}
] call CBA_fnc_addEventHandler;