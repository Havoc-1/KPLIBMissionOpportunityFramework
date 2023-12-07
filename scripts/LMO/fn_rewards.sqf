/*
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to assign KP rewards.
 *	
 *	Arguments
 *		0: Amount to change <NUMBER>
 *		OR
 *		0: Amount to change <ARRAY> - For SAF rewards only!
 *			0: SAF Amount <ARRAY> - Rewards for supply, ammo, and fuel crates. If indexes are array, random number will be selected in [Min,Max] format.
 *				0: Supply Crates <NUMBER> OR <ARRAY>
 *				1: Ammo Crates <NUMBER> OR <ARRAY>
 *				2: Fuel Crates <NUMBER> OR <ARRAY>
 *			1: Position <ARRAY> - Searches for the nearest FOB at this position.
 *
 *		1: Resource <NUMBER>
 *			0 = Combat Readiness
 *			1 = Intelligence
 *			2 = CivRep
 *			3 = SAF Resources (Add Only)
 *		2: Add (True) or Subtract (False) <BOOL> (Optional)
 *
 *	Example:
 *		[LMO_Cache_Lose_Alert,0,true] call LMO_fn_rewards;
 *		[20,0,false] call LMO_fn_rewards;
 *		[[2,2,2,getPos box1],3] call LMO_fn_rewards;
 *		[[LMO_Cache_supplyBoxes,LMO_Cache_ammoBoxes,LMO_Cache_fuelBoxes,getPos box1],3] call LMO_fn_rewards;
 *	
 *	Return: None
 */

params ["_value","_num",["_bool", true]];

private _mType = missionNamespace getVariable "LMO_MissionType";

switch (_num) do {
	
	//Combat Readiness
	case 0:{
		//Add
		if (_bool == true) then {
			if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select _mType) == true)) then {
				combat_readiness = combat_readiness + LMO_Cache_Lose_Alert;
				[format ["[Reward] Alert level increased by %1, new Alert level is %2.", LMO_Cache_Lose_Alert, combat_readiness],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				["[Reward] LMO Penalties disabled for this mission, alert level is unchanged.",LMO_Debug] call LMO_fn_rptSysChat;
			};
		};

		//Subtract
		if (_bool == false) then {
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				combat_readiness = combat_readiness - (_value * LMO_TST_Reward);
				if (combat_readiness < 0) then {combat_readiness = 0};
				[format ["[Reward] Alert level reduced by %1 (TST), new Alert level is %2.", (_value * LMO_TST_Reward), combat_readiness],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				combat_readiness = combat_readiness - _value;
				if (combat_readiness < 0) then {combat_readiness = 0};
				[format ["[Reward] Alert level reduced by %1, new Alert level is %2.", _value, combat_readiness],LMO_Debug] call LMO_fn_rptSysChat;
			};
		};
	};

	//Intelligence
	case 1:{

		//Add
		if (_bool == true) then {
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				resources_intel = resources_intel + (round (_value * LMO_TST_Reward));
				[format ["[Reward] Intelligence increased by %1 (TST), new Intelligence is %2", (round (_value * LMO_TST_Reward)), resources_intel],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				resources_intel = resources_intel + _value;
				[format ["[Reward] Intelligence increased by %1, new Intelligence is %2", _value, resources_intel],LMO_Debug] call LMO_fn_rptSysChat;
			};
		};

		//Subtract
		if (_bool == false) then {
			if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select _mType) == true)) then {
				resources_intel = resources_intel - _value;
				[format ["[Reward] Intelligence decreased by %1, new Intelligence is %2", _value, resources_intel],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				["[Reward] LMO Penalties disabled for this mission, alert level is unchanged.",LMO_Debug] call LMO_fn_rptSysChat;
			};
		};
	};

	//CivRep
	case 2:{
		
		//Add
		if (_bool == true) then {
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				private _finalReward = round (_value * LMO_TST_Reward);
				[_finalReward] call F_cr_changeCR;
				[format ["[Reward] CivRep increased by %1 (TST), new CivRep is %2", _finalReward, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				[_value] call F_cr_changeCR;
				[format ["[Reward] CivRep increased by %1, new CivRep is %2", _value, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
			};
		};

		//Subtract
		if (_bool == false) then {
			if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select 1) == true)) then {
				//Deduct Civilian reputation as defined in kp_liberation_config.sqf
				[_value, true] call F_cr_changeCR;
				[format ["[Reward] CivRep deducted by %1, new CivRep is %2", _value, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
			} else {
				["[Reward] LMO Penalties disabled for this mission, alert level is unchanged.",LMO_Debug] call LMO_fn_rptSysChat;
			};
		};
	};
	
	//SAF
	case 3: {

		_value params [["_cSupply",0],["_cAmmo",0],["_cFuel",0],["_pos",[0,0,0]]];

		private _fobStorage = objNull;
		private _fobStorageObj = [];
		private _fobStorageSort = [];

		//Generates values based on TST
		if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
			
			if (_cSupply isEqualType []) then {
				_cSupply = round ((_cSupply call BIS_fnc_randomInt) * LMO_TST_Reward);
			} else {
				_cSupply = _cSupply * LMO_TST_Reward;
			};

			if (_cAmmo isEqualType []) then {
				_cAmmo = round ((_cAmmo call BIS_fnc_randomInt) * LMO_TST_Reward);
			} else {
				_cAmmo = _cAmmo * LMO_TST_Reward;
			};

			if (_cFuel isEqualType []) then {
				_cFuel = round ((_cFuel call BIS_fnc_randomInt) * LMO_TST_Reward);
			} else {
				_cFuel = _cFuel * LMO_TST_Reward;
			};
		} else {
			if (_cSupply isEqualType []) then {_cSupply = round (_cSupply call BIS_fnc_randomInt)};
			if (_cAmmo isEqualType []) then {_cAmmo = round (_cAmmo call BIS_fnc_randomInt)};
			if (_cFuel isEqualType []) then {_cFuel = round (_cFuel call BIS_fnc_randomInt)};
		};

		//Get nearest fobs
		private _nearFob = [_pos] call KPLIB_fnc_getNearestFob;
		private _nearFobName = [_nearFob] call KPLIB_fnc_getFobName;
		private _nearFobObjects = nearestObjects [_nearFob, ["BUILDING"], GRLIB_fob_range];

		//Filters objects to storage only
		{
			if (typeOf _x == KP_liberation_large_storage_building || typeOf _x == KP_liberation_small_storage_building) then {
				_fobStorageObj pushBack _x;
			};
		}forEach _nearFobObjects;

		//Sorts storage by ascending distance to FOB
		_fobStorageSort = [_fobStorageObj, [], {_x distance _nearFob}, "ASCEND"] call BIS_fnc_sortBy;
		
		[format ["[Reward] Closest FOB: FOB %1, Storage Containers: %2",_nearFobName, count _fobStorageSort],LMO_DebugFull] call LMO_fn_rptSysChat;
		
		private _cRewards = _cSupply + _cAmmo + _cFuel;
		
		["LMOTaskOutcomeG", [format ["Crates transported to FOB %1", _nearFobName], "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
		[format ["[Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates.",_cSupply,_cAmmo,_cFuel],LMO_Debug] call LMO_fn_rptSysChat;
		if (count _fobStorageObj > 0) then {
			[_fobStorageSort,_cRewards,_cSupply,_cAmmo,_cFuel,_nearFob,_nearFobName] spawn {
				params ["_fobStorageSort","_cRewards","_cSupply","_cAmmo","_cFuel","_nearFob","_nearFobName"];
				{
					while {_cRewards >= 0} do {

						if (_cRewards == 0) exitWith {
						["[Reward] All resource crates assigned.",LMO_DebugFull] call LMO_fn_rptSysChat;
						};

						([_x] call KPLIB_fnc_getStoragePositions) params ["_storage_positions", "_unload_distance"];
						_crates_count = count (attachedObjects _x);
						if ((_crates_count >= (count _storage_positions)) && (count _fobStorageSort > 0) && ((_fobStorageSort find _x) != ((count _fobStorageSort) - 1))) exitWith {
							[format ["[Reward] %1 at FOB %2 does not have enough space to store crates. Moving to next storage.", typeOf _x, _nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
						};
						if ((_cRewards > 0) && (count _fobStorageSort > 1) && (_crates_count >= (count _storage_positions)) && (((_fobStorageSort find _x) == ((count _fobStorageSort) - 1)))) exitWith {
							[format ["[Reward] No storage containers available at FOB to store crates, delivering to FOB %1", _nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
							_crateArray = [[_cSupply,0],[_cAmmo,1],[_cFuel,2]];
							{
								if ((_x select 0) > 0) then {
									for "_i" from 1 to (_x select 0) do { //Amount of box
										private _LMOcrate = createVehicle [
											(KPLIB_crates select (_x select 1)), //Type of box
											_nearFob,
											[],
											5,
											"NONE"
										];
										[_LMOcrate, true] call KPLIB_fnc_clearCargo;
										_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
										if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
									};
								};
							}forEach _crateArray;
							[format ["[Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates delivered to FOB %4", _cSupply, _cAmmo, _cFuel, _nearFobName],LMO_Debug] call LMO_fn_rptSysChat;
						};

						[format ["[Reward] fillStorage attempt on %1 at FOB %2.", typeOf _x, _nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
						if (_cSupply > 0) then {
							[100, 0, 0, _x] call KPLIB_fnc_fillStorage;
							_cSupply = _cSupply - 1;
							_cRewards = _cRewards - 1;
							[format ["[Reward] fillStorage successful on %1 at FOB %2. (Supply Crate)", typeOf _x,_nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
						} else {
							if (_cAmmo > 0) then {
								[0, 100, 0, _x] call KPLIB_fnc_fillStorage;
								_cAmmo = _cAmmo - 1;
								_cRewards = _cRewards - 1;
								[format ["[Reward] fillStorage successful on %1 at FOB %2. (Ammo Crate)", typeOf _x,_nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
							} else {
								if (_cFuel > 0) then {
									_cFuel = _cFuel - 1;
									_cRewards = _cRewards - 1;
									[0, 0, 100, _x] call KPLIB_fnc_fillStorage;
									[format ["[Reward] fillStorage successful on %1 at FOB %2. (Fuel Crate)", typeOf _x,_nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
								};
							};
						};
						sleep 0.1;
					};
				}forEach _fobStorageSort;
			};
		} else {
			[format ["[Reward] No storage containers available at FOB to store crates, delivering to FOB %1", _nearFobName],LMO_DebugFull] call LMO_fn_rptSysChat;
			_crateArray = [[_cSupply,0],[_cAmmo,1],[_cFuel,2]];
			{
				if ((_x select 0) > 0) then {
					for "_i" from 1 to (_x select 0) do { //Amount of box
						_LMOcrate = createVehicle [
							(KPLIB_crates select (_x select 1)), //Type of box
							_nearFob,
							[],
							5,
							"NONE"
						];
						[_LMOcrate, true] call KPLIB_fnc_clearCargo;
						_LMOcrate setVariable ["KP_liberation_crate_value", 100, true];
						if (KP_liberation_ace) then {[_LMOcrate, true, [0, 1.5, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"];};
					};
				};
			}forEach _crateArray;
			[format ["[Reward] %1 Supply Crates, %2 Ammo Crates, %3 Fuel Crates delivered to FOB %4", _cSupply, _cAmmo, _cFuel, _nearFobName],LMO_Debug] call LMO_fn_rptSysChat;
		};
	};
};