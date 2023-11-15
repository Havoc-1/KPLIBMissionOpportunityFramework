/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	QRF Spawner for securing cache
 *
 *	Arguments:
 *		0: Cache Object <OBJECT>
 *
 *	Examples:
 *		[_cache] call LMO_fn_qrfCache;
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
				//["LMO_qrfPos", [_cache,_sqdSize,_sqdOrbat]] call CBA_fnc_serverEvent;
				[_cache,_sqdSize,_sqdOrbat] call LMO_fn_qrfPos;
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