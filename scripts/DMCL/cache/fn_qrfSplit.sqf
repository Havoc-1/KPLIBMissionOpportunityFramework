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
					//["LMO_qrfGrp2",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos]] call CBA_fnc_serverEvent;
					[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos] call LMO_fn_qrfGrp2;
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				}
			},
			0.1,
			[_qrfFriendlyCount,_qrfGrp2Rad,_qrfGrp1Rad,_qrfSpawnDist,_qrfSpawnPos,_cache,_sqd2Size]
		] call CBA_fnc_addPerFrameHandler;
	} else {
		diag_log "[LMO] LMO_qrfSplit EH done.";
		//["LMO_qrfGrp2",[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos]] call CBA_fnc_serverEvent;
		[_cache,_sqdSize,_sqdOrbat,_qrfGrp1Rad,_sqd2Size,_qrfSpawnPos] call LMO_fn_qrfGrp2;
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