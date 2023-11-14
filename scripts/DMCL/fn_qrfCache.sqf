/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	QRF Spawner for securing cache
 *
 *	Arguments:
 *		0: Cache Object <OBJECT>
 *
 *	Examples:
 *		[_cache] call XEPKEY_fn_qrfCache;
 *	
 *	Return Value: None
 */

params ["_cache"];

diag_log "[LMO] qrfCache start.";

_sqdSize = 0;
_sqdOrbat = [];
_sqdOrbat append LMO_Orbat;
_sqdMultiply = LMO_CacheSqdMultiply*(count ((nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CachePlayerRng]) select {side _x == GRLIB_side_friendly}));

//Generates squad multiplier
if (LMO_CacheSqdMultiplier == true) then {
	_sqdSize = round ((LMO_sqdSize call BIS_fnc_randomInt)+_sqdMultiply);
} else {
	_sqdSize = LMO_sqdSize call BIS_fnc_randomInt;
};

//Scales squad size
if (_sqdSize != count _sqdOrbat) then {
	[
		{
			(_this select 0) params ["_sqdSize","_sqdOrbat","_cache"];
			if (_sqdSize == count _sqdOrbat) exitWith {
				diag_log "[LMO] sqdSize == sqdOrbat in qrfCache. Calling qrfPos and removing PFH.";
				["LMO_qrfPos", [_cache,_sqdSize,_sqdOrbat]] call CBA_fnc_serverEvent;
				[_this select 1] call CBA_fnc_removePerFrameHandler;
			};
			if (_sqdSize < count _sqdOrbat) then {
				_sqdOrbat resize _sqdSize;
			};
			if (_sqdSize > count _sqdOrbat) then {
				_sqdAdd = selectRandom LMO_Orbat;
				_sqdOrbat pushBack _sqdAdd;
			};
		},
		0.1,
		[_sqdSize,_sqdOrbat, _cache]
	] call CBA_fnc_addPerFrameHandler;
};

/* //Determines QRF spawn position
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
				["LMO_qrfSpawn", _id] call CBA_fnc_removeEventHandler;
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
				["LMO_qrfSplit", _id] call CBA_fnc_removeEventHandler;
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
			["LMO_qrfSplit", _id] call CBA_fnc_removeEventHandler;
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
		["LMO_qrfGrp2", _id] call CBA_fnc_removeEventHandler;
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
		["LMO_qrfDelete", _id] call CBA_fnc_removeEventHandler;
	}
] call CBA_fnc_addEventHandler; */
