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
