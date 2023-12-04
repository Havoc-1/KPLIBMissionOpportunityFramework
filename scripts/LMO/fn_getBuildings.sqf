/*
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function that grabs suitable buildings nearby enemy units to use for LMO target building.
 * 
 *	Return Value: LMO_spawnBldg
 *
 *	Example:
 *		[] call LMO_fn_getBuildings
 */

//Initializing Variables
_allBuildings = [];
_allBuildingsFilter = [];
_bCheckExclude = [];

//Grabs array of all buildings nearby enemy leader units
{
	if ((!isPlayer _x) && (side _x == GRLIB_side_enemy) && (leader group _x == _x) && (alive _x)) then {

		_buildingArray = (nearestTerrainObjects [_x, LMO_bTypes, LMO_bRadius, false, true]) select {count ([_x] call BIS_fnc_buildingPositions) >= LMO_bSize};
		{_allBuildings pushbackUnique _x}forEach _buildingArray;

	};
}forEach LMO_enyList;
[format ["All buildings with sufficient garrison: %1", count _allBuildings],LMO_Debug] call LMO_fn_rptSysChat;

//Prevents LMOs from spawning too close to players
{
	_playerRangeCheck = (nearestTerrainObjects [_x, LMO_bTypes, LMO_bPlayerRng, false, true]) select {count ([_x] call BIS_fnc_buildingPositions) >= LMO_bSize};
	_allBuildings = _allBuildings - _playerRangeCheck;
}forEach allPlayers;

//Excludes blacklisted buildings
{
    _bCheck = _x;
    {
        if (typeOf _bCheck == _x) then {
            _bCheckExclude pushbackUnique _bCheck;
        };
    }forEach LMO_bListBldg;
}forEach _allBuildings;

//Excludes all buildings nearby FOBs
if (count GRLIB_all_fobs > 0) then {
	{
		_bCheck = (nearestTerrainObjects [_x, LMO_bTypes, LMO_objBlacklistRng, false, true]) select {count ([_x] call BIS_fnc_buildingPositions) >= LMO_bSize};
		{
			_bCheckExclude pushbackUnique _x;
		}forEach _bCheck;
	}forEach GRLIB_all_fobs;
};
[format ["All Buildings: %1, Excluded Buildings: %2, Blacklisted Buildings: %3", count _allBuildings, count _bCheckExclude, count LMO_objBlacklist],LMO_Debug] call LMO_fn_rptSysChat;

_allBuildings = _allBuildings - _bCheckExclude - LMO_objBlacklist;
[format ["Suitable LMO Buildings: %1", count _allBuildings],LMO_Debug] call LMO_fn_rptSysChat;

if (count _allBuildings == 0) exitWith {
		LMO_active = false;
		["No Buildings Found, exiting fn_getBuildings.sqf. LMO_active is set to false.",LMO_Debug] call LMO_fn_rptSysChat;
};

//Selects random building from filtered array
LMO_spawnBldg = selectRandom _allBuildings;
LMO_objBlacklist = (nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, LMO_objBlacklistRng, false, true]) select {count ([_x] call BIS_fnc_buildingPositions) >= LMO_bSize};
