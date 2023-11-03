
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
_sqdOrbat = [];
_sqdSize = 0;

_sqdOrbat append LMO_Orbat;
_sqdMultiply = LMO_CacheSqdMultiply*(count ((nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CachePlayerRng]) select {isPlayer _x}));

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
_qrfSpawnDist = LMO_CacheSqdSpawnDist;
_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, random 360] call BIS_fnc_relPos;
_qrfPlayerCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {isPlayer _x});

if (LMO_Debug == true) then {systemChat format ["LMO: QRF Size: %1, QRF Pos: %2",_sqdSize,_qrfSpawnPos]};

while {_qrfPlayerCount != 0} do {
	_qrfSpawnDist = _qrfSpawnDist + 20;
	_qrfSpawnPos = [getPos _cache, _qrfSpawnDist, random 360] call BIS_fnc_relPos;
	_qrfPlayerCount = count ((nearestObjects [_qrfSpawnPos, ["Man", "LandVehicle"], LMO_CacheSqdMinDist]) select {isPlayer _x});
};

//Spawn Enemies
{
	_enyUnitsHolder = _enyUnits createUnit [
		_x, //classname 
		_qrfSpawnPos,
		[],0,"NONE"
	];

	[_enyUnitsHolder] joinSilent _enyUnits;
} forEach _sqdOrbat;

_enyUnits setSpeedMode "FULL";
_enyUnits move getPos _cache;