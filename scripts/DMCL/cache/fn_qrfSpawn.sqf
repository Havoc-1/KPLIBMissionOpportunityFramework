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
        [_enyUnits,_sqdSize,_qrfGrp1Rad,_cache] call LMO_fn_qrfSplit;
    };
} forEach _sqdOrbat;
diag_log "[LMO] Spawning enemies for hostage rescue.";