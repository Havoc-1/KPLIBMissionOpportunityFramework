/*
* Function to populate enemy list near players
* 
* Return Value: 
* LMO_enyList
* LMO_mChance
*
* Example:
* call LMO_fn_getEnemyList
*
*/


//Variables
LMO_mChance = random 100;
LMO_enyList = [];

//populate enemy list near players 
{
	_enyListSelect = (_x nearEntities [["CAManBase","LandVehicle"], LMO_enyRng]) select {side _x == GRLIB_side_enemy};
	LMO_enyList append _enyListSelect;
}forEach (allPlayers select {alive _x});
[format ["getEnemyList completed. %1 nearby enemy units found.", count LMO_enyList],LMO_Debug] call LMO_fn_rptSysChat;
