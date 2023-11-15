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
				//["LMO_qrfSpawn",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad]] call CBA_fnc_serverEvent;
				[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad] call LMO_fn_qrfSpawn;
				[_this select 1] call CBA_fnc_removePerFrameHandler;
			};
		},
		0.1,
		[_qrfFriendlyCount,_qrfSpawnDist,_qrfSpawnPos,_qrfGrp1Rad,_cache,_sqdSize,_sqdOrbat]
	] call CBA_fnc_addPerFrameHandler;
} else {
	//["LMO_qrfSpawn",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad]] call CBA_fnc_serverEvent;
	[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad] call LMO_fn_qrfSpawn;
	[_this select 1] call CBA_fnc_removePerFrameHandler;
};