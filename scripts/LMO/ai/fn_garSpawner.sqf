/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to spawn enemy units to occupy LMO objective.
 *
 *	Arguments:
 *		0: Position to spawn <ARRAY> (Optional)
 *		1: Orbat of Units <ARRAY> (Optional) - Array of class names for unit spawn.
 *		2: Garrison <BOOL> (Optional) - Garrison units to nearby building in radius (true), scatter units in radius (false).
 *		3: Radius <NUMBER> (Optional) - Radius to search for garrison position or scatter units.
 *		4: Enemy Count <NUMBER> OR <ARRAY> (Optional) - Number of enemies to spawn on target or array [Min, Max] range.
 *		5: Enemy Outfit <ARRAY> (Optional) - Assigns uniform and equipment to units. Refer to Outfit Params in fn_LMOinit.sqf
 *	
 *	Return Value: Enemy Group <GROUP>
 *
 *	Examples:
 *		_enyUnits = [] call LMO_fn_garSpawner;
 *		_enyUnits = [getPos car1] call LMO_fn_garSpawner;
 *		_enyUnits = [LMO_spawnBldg,LMO_Orbat,true,30,[8,12],LMO_garOutfit] call LMO_fn_garSpawner;
 *
 */

params [["_pos",getPos LMO_spawnBldg],["_sqdOrbat",LMO_Orbat],["_gar",true],["_rad",30],["_sqdNum",LMO_sqdSize],["_outfit",LMO_garOutfit]];

//Spawns Enemies
private _eGrp = createGroup east;
private _sqdSize = 0;

if (_sqdNum isEqualType []) then {
	_sqdSize = _sqdNum call BIS_fnc_randomInt;
} else {
	_sqdSize = _sqdNum;
};

//Resizes Orbat to Squad Size
if (_sqdSize != count _sqdOrbat) then {

	if (_sqdSize < count _sqdOrbat) then {
		_sqdOrbat resize _sqdSize;
	};

	while {_sqdSize > count _sqdOrbat} do {
			_sqdAdd = selectRandom LMO_Orbat;
			_sqdOrbat append [_sqdAdd];
	};
};

//Spawns Enemies
["Spawning enemies.",LMO_DebugFull] call LMO_fn_rptSysChat;
private _eCount = 0;
{
	private _u = _eGrp createUnit [
		_x,
		getPos LMO_spawnBldg,
		[],
		0,
		"NONE"
	];
	[_u] joinSilent _eGrp;
	_eCount = _eCount + 1;
} forEach _sqdOrbat;

//Garrison or scatter Enemies


//Waits until all units have spawned
[
	{
		params ["_eCount","_sqdSize"];
		_eCount == _sqdSize;
	},
	{
		params ["_eCount","_sqdSize","_eGrp","_outfit","_gar","_pos","_rad"];
		[format ["%1 Enemies spawned.", count units _eGrp],LMO_Debug] call LMO_fn_rptSysChat;

		if (_gar == true) then {
			//[getPos LMO_spawnBldg, LMO_bTypes, (units _eGrp), 30, 1, true, true] call ace_ai_fnc_garrison;
			[_pos, LMO_bTypes, (units _eGrp), _rad, 1, true, true] call ace_ai_fnc_garrison;
			//diag_log format ["[LMO] [Garrison] Units Garrisoned. Pos: %1, Units: %2, Rad: %3",_pos,count units _eGrp, _rad];
		} else {
			{
				_x setPos [[_pos, _rad],["water"]] call BIS_fnc_randomPos;
			}forEach units _eGrp;
		};

		_eGrp deleteGroupWhenEmpty true;
		[_eGrp] call LMO_fn_removeThrowables;

		//Prevents random glitch that shoots AI into the air
		{
			if (((getPosATL _x) select 2) > 30) then {
				private _safePosUnit = (units _eGrp) select {(getPosATL _x) select 2 <= 30};
				if (count _safePosUnit > 0) then {
					_x setVelocity [0,0,0];
					_x setPosATL getPosATL (selectRandom units _eGrp);
				};
			};
		}forEach units _eGrp;

		{
			_noMove = random 1;

			_x disableAI "RADIOPROTOCOL";

			if (_noMove <= 0.3) then {
				_x disableAI "PATH";
			};
		}forEach units _eGrp;

		//VCOM will stop the AI squad from responding to calls for backup.
		if (LMO_VCOM_On == true) then {
			_eGrp setVariable ["VCM_NORESCUE",true];
			_eGrp setVariable ["VCM_DisableForm",true];
		};
		
		{
			[_x, _outfit] call LMO_fn_enyOutfit;
		}forEach units _eGrp;
		["Garrison Outfits completed.",LMO_DebugFull] call LMO_fn_rptSysChat;
	},
	[_eCount,_sqdSize,_eGrp,_outfit,_gar,_pos,_rad]
] call CBA_fnc_waitUntilandExecute;

//Return Value
_eGrp;
