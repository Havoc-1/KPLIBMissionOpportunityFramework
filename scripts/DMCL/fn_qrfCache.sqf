
/* 
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	QRF Spawner for securing cache
 *
 *	Arguments:
 *	0: Cache Object <OBJECT>
 *
 *	Examples:
 *	[_cache] call XEPKEY_fn_qrfCache;
 *	
 *	Return Value: None
 */

params ["_cache"];
_enyUnits = createGroup east;
_enyUnits2 = createGroup east;
_sqdOrbat = [];
_sqd2Orbat = [];
_sqdSize = 0;
_splitGrp = random 1;
_qrfRadDiff = 50;
_qrfGrp1Rad = 0;
_qrfGrp2Rad = 0;

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
	
	if (_sqdSize < count _sqdOrbat) then {
		_sqdOrbat resize _sqdSize;
	};

	while {_sqdSize > count _sqdOrbat} do {
			_sqdAdd = selectRandom LMO_Orbat;
			_sqdOrbat append [_sqdAdd];
	};
};

//Checks for suitable QRF spawn location
_qrfGrp1Rad = random 360;
_qrfSpawnDist = LMO_CacheSqdSpawnDist;
_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp1Rad] call BIS_fnc_relPos;
_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});

//if (LMO_Debug == true) then {systemChat format ["LMO: QRF Size: %1, QRF Pos: %2",_sqdSize,_qrfSpawnPos]};

while {_qrfFriendlyCount != 0} do {
	_qrfSpawnDist = _qrfSpawnDist + 20;
	_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp1Rad] call BIS_fnc_relPos;
	_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
	sleep 0.1;
};

//Spawn Enemies
{
	_enyUnitsHolder = _enyUnits createUnit [
		_x, //classname 
		_qrfSpawnPos,
		[],0,"NONE"
	];

	[_enyUnitsHolder] joinSilent _enyUnits;
	sleep 0.1;
} forEach _sqdOrbat;


if (_splitGrp > 0.5) then {

	_sqd2Size = round (_sqdSize/2);

	//Checks for suitable QRF spawn location
	_qrfGrp2Rad = random 360;
	_qrfSpawnDist = LMO_CacheSqdSpawnDist;
	_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp2Rad] call BIS_fnc_relPos;
	_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});

	_minRad = _qrfGrp1Rad + _qrfRadDiff;
	_maxRad = _qrfGrp1Rad - _qrfRadDiff;
	
	_qrfGrp2Rad = _minRad + (random (_maxRad - _minRad));
	if (_qrfGrp2Rad < 0) then {
		_qrfGrp2Rad = _qrfGrp2Rad + 360;
	} else {
		if (_qrfGrp2Rad >= 360) then {
			_qrfGrp2Rad = _qrfGrp2Rad - 360;
		};
	};

	
	while {_qrfFriendlyCount != 0} do {
		
		_qrfGrp2Rad = random 360;
		_qrfGrp2Rad = _minRad + (random (_maxRad - _minRad));
		if (_qrfGrp2Rad < 0) then {
			_qrfGrp2Rad = _qrfGrp2Rad + 360;
		} else {
			if (_qrfGrp2Rad >= 360) then {
				_qrfGrp2Rad = _qrfGrp2Rad - 360;
			};
		};
		
		_qrfSpawnDist = _qrfSpawnDist + 20;
		_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, _qrfGrp2Rad] call BIS_fnc_relPos;
		_qrfFriendlyCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {side _x == GRLIB_side_friendly});
		sleep 0.1;
	};

	if (LMO_Debug == true) then {systemChat format ["LMO: QRF Size: %1, QRF1 Dir: %2, QRF2 Dir: %3",_sqdSize,round _qrfGrp1Rad,round _qrfGrp2Rad]};

	for "_i" from _sqd2Size to _sqdSize do {
		_sqd2Unit = selectRandom units _enyUnits;
		_sqd2Orbat append [_sqd2Unit];
		_sqd2Unit setPos _qrfSpawnPos;
	};
	_sqd2Orbat joinSilent _enyUnits2;
	
	if (LMO_VCOM_On == true) then {
		_enyUnits2 setVariable ["VCM_NORESCUE",true];
	};
	
	_enyUnits2 setSpeedMode "FULL";
	_enyUnits2 move getPos _cache;
} else {
	if (LMO_Debug == true) then {systemChat format ["LMO: QRF Size: %1, QRF Dir: %2",_sqdSize,round _qrfGrp1Rad]};
};

if (LMO_VCOM_On == true) then {
	_enyUnits setVariable ["VCM_NORESCUE",true];
};

_enyUnits setSpeedMode "FULL";
_enyUnits move getPos _cache;

[_enyUnits,_cache] spawn {
	params ["_enyUnits","_cache"];
	_enyUnitPlayers = [];
	while {{alive _x} count units _enyUnits > 0} do {
		_enyUnits move getPos _cache;
		{
			_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
		}forEach units _enyUnits;
		
		if ((count _enyUnitPlayers == 0) && !alive _cache) exitWith {
			{deleteVehicle _x}forEach units _enyUnits;
			deleteGroup _enyUnits;
		};
		sleep 20;
	};
};

if (_splitGrp > 0.5) then {
	[_enyUnits2,_cache] spawn {
		params ["_enyUnits2","_cache"];
		_enyUnitPlayers2 = [];
		while {{alive _x} count units _enyUnits2 > 0} do {
			_enyUnits2 move getPos _cache;
			{
				_enyUnitPlayers2 = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
			}forEach units _enyUnits2;
			
			if (count _enyUnitPlayers2 == 0 && !alive _cache) exitWith {
				{deleteVehicle _x}forEach units _enyUnits2;
				deleteGroup _enyUnits2;
			};
			sleep 20;
		};
	};
};