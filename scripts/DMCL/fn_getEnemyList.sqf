/*
 * Function to populate enemy list near players
 * 
 * Return Value: 
 * enyList
 * missionChance
 *
 * Example:
 * call XEPKEY_fn_getEnemyList
 *
 */

//Variables
_enyRange = 2500;
missionChance = random 100;
enyList = nil;
enyList = [];

	//populate enemy list near players 
	{
		_enyListSelect = (_x nearEntities [["Man","LandVehicle"],_enyRange]) select {side _x == east};
		enyList append _enyListSelect;
	}forEach allPlayers;

