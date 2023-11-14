//XEPKEY_fnc_getBuildings
//Function to 
//Params: NONE
//Returns: 
//	spawnBuilding


//Initializing local variables
_allBuildings = [];
_allBuildingsFilter = [];
_bCheckExclude = [];

//Grabs array of all buildings nearby enemy units and selects 1 by random
{
	if (!isPlayer _x && side _x == east) then {
		
		_buildingArray = nearestTerrainObjects [_x, Btypes, Bradius, false, true];
		_allBuildings append _buildingArray;
	};
}forEach enyList;

//Filters buildings with garrison positions less than buildingSize, minimum MO range for player
{
	_checkBuildingPos = [_x] call BIS_fnc_buildingPositions;		
	if (count _checkBuildingPos < buildingSize) then {
	
		_allBuildingsFilter append [_x];

	};
}forEach _allBuildings;

_allBuildings = _allBuildings - _allBuildingsFilter;

{
	//prevent spawning from too close to player 		
	_playerRangeCheck = nearestTerrainObjects [_x, Btypes, BplayerRange, false, true];
	//hint format ["%1", _playerRangeCheck];
	_allBuildings = _allBuildings - _playerRangeCheck;
	
}forEach allPlayers;

{
    _bCheck = _x;
    {
        if (typeOf _bCheck == _x) then {
            _bCheckExclude append [_bCheck];
			//actual groupChat (format ["%1", _bCheckExclude]);
        };
    }forEach XEPKEY_blacklistBuildings;
}forEach _allBuildings;

<<<<<<< Updated upstream
_allBuildings = _allBuildings - _bCheckExclude;
//actual groupChat (format ["%1", _allBuildings]);

if (count _allBuildings < 1) exitWith {
		activeMission = false;
		actual groupChat "No Buildings Found, exiting fn_getBuildings.sqf";
=======
//Excludes all buildings nearby FOBs
if (count GRLIB_all_fobs > 0) then {
	{
		_bCheck = nearestTerrainObjects [_x, LMO_bTypes, LMO_objBlacklistRng, false, true];
		_bCheckExclude pushbackUnique _bCheck;
	}forEach GRLIB_all_fobs;
};

if (LMO_Debug) then {diag_log format ["[LMO] All Buildings: %1, Excluded Buildings: %2, Blacklisted Buildings: %3", count _allBuildings, count _bCheckExclude, count LMO_objBlacklist]};
_allBuildings = _allBuildings - _bCheckExclude - LMO_objBlacklist;
if (LMO_Debug) then {diag_log format ["[LMO] Suitable LMO Buildings: %1", count _allBuildings]};

if (count _allBuildings < 1) exitWith {
		LMO_active = false;
		if (LMO_Debug) then {diag_log "[LMO] No Buildings Found, exiting fn_getBuildings.sqf"};
>>>>>>> Stashed changes
};

//Selects random building from filtered array
spawnBuilding = selectRandom _allBuildings;

