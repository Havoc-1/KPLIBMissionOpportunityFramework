/*
 * Function to populate array of buildings near enemy units to help choose 
 * a target building 
 * 
 * Return Value: LMO_spawnBldg
 *
 * Example:
 * call XEPKEY_fn_getBuildings
 *
 */

//Initializing Variables
_allBuildings = [];
_allBuildingsFilter = [];
_bCheckExclude = [];

//Grabs array of all buildings nearby enemy units and selects 1 by random
{
	if (!isPlayer _x && side _x == east) then {
		
		_buildingArray = nearestTerrainObjects [_x, LMO_bTypes, LMO_bRadius, false, true];
		_allBuildings append _buildingArray;
	};
}forEach LMO_enyList;

//Filters buildings with garrison positions less than LMO_bSize, minimum MO range for player
{
	_checkBuildingPos = [_x] call BIS_fnc_buildingPositions;		
	if (count _checkBuildingPos < LMO_bSize) then {
	
		_allBuildingsFilter append [_x];

	};
}forEach _allBuildings;

_allBuildings = _allBuildings - _allBuildingsFilter;

{
	//prevent spawning from too close to player 		
	_playerRangeCheck = nearestTerrainObjects [_x, LMO_bTypes, LMO_bPlayerRng, false, true];
	//hint format ["%1", _playerRangeCheck];
	_allBuildings = _allBuildings - _playerRangeCheck;
	
}forEach allPlayers;

{
    _bCheck = _x;
    {
        if (typeOf _bCheck == _x) then {
            _bCheckExclude append [_bCheck];
        };
    }forEach XEPKEY_blacklistBuildings;
}forEach _allBuildings;

if (LMO_Debug == true) then {systemChat format ["LMO: All Buildings: %1, Excluded Buildings: %2, Blacklisted Buildings: %3", count _allBuildings, count _bCheckExclude, count LMO_objBlacklist]};
_allBuildings = _allBuildings - _bCheckExclude - LMO_objBlacklist;
if (LMO_Debug == true) then {systemChat format ["LMO: Suitable LMO Buildings: %1", count _allBuildings]};

if (count _allBuildings < 1) exitWith {
		LMO_active = false;
		if (LMO_Debug == true) then {systemChat "LMO: No Buildings Found, exiting fn_getBuildings.sqf"};
};

//Selects random building from filtered array
LMO_spawnBldg = selectRandom _allBuildings;
LMO_objBlacklist = nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, LMO_objBlacklistRng, false, true];
