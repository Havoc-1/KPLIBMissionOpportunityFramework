/*
 * Function to populate array of buildings near enemy units to help choose 
 * a target building 
 * 
 * Return Value: spawnBuilding
 *
 * Example:
 * call XEPKEY_fn_getBuildings
 *
 */

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

_allBuildings = _allBuildings - _bCheckExclude;
//actual groupChat (format ["%1", _allBuildings]);

if (count _allBuildings < 1) exitWith {
		activeMission = false;
		actual groupChat "No Buildings Found, exiting fn_getBuildings.sqf";
};

//Selects random building from filtered array
spawnBuilding = selectRandom _allBuildings;

