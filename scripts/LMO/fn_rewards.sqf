/*
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to assign combat readiness and intelligence.
 *	
 *	Arguments
 *		0: Amount to change <NUMBER>
 *		1: Add (True) or Subtract (False) <BOOL>
 *		2: Resource <NUMBER>
 *			0 = Combat Readiness
 *			1 = Intelligence
 *	
 *	Example:
 *		[LMO_Cache_Lose_Alert,true,0] call LMO_fn_rewards;
 *		[20,false,0] call LMO_fn_rewards;
 *	
 *	Return: combat_readiness
 */

params ["_value","_bool","_num"];

private _mType = missionNamespace getVariable "LMO_MissionType";


switch (_num) do {
	
	//Combat Readiness
	case 0:{
		//Add
		if (_bool == true) then {
			if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select _mType) == true)) then {
				combat_readiness = combat_readiness + LMO_Cache_Lose_Alert;
				diag_log format ["[LMO] [Reward] Alert level increased by %1, new Alert level is %2.", LMO_Cache_Lose_Alert, combat_readiness];
			} else {
				diag_log "[LMO] [Reward] LMO Penalties disabled for this mission, alert level is unchanged.";
			};
		};

		//Subtract
		if (_bool == false) then {
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				combat_readiness = combat_readiness - (_value * LMO_TST_Reward);
				if (combat_readiness < 0) then {combat_readiness = 0};
				diag_log format ["[LMO] [Reward] Alert level reduced by %1 (TST), new Alert level is %2.", (_value * LMO_TST_Reward), combat_readiness];
			} else {
				combat_readiness = combat_readiness - _value;
				if (combat_readiness < 0) then {combat_readiness = 0};
				diag_log format ["[LMO] [Reward] Alert level reduced by %1, new Alert level is %2.", _value, combat_readiness];
			};
		};
	};

	//Intelligence
	case 1:{

		//Add
		if (_bool == true) then {
			if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				resources_intel = resources_intel + (round (_value * LMO_TST_Reward));
				diag_log format ["[LMO] [Reward] Intelligence increased by %1 (TST), new Intelligence is %2", (round (_value * LMO_TST_Reward)), resources_intel];
			} else {
				resources_intel = resources_intel + _value;
				diag_log format ["[LMO] [Reward] Intelligence increased by %1, new Intelligence is %2", _value, resources_intel];
			};
		};

		//Subtract
		if (_bool == false) then {
			if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select _mType) == true)) then {
				resources_intel = resources_intel - _value;
				diag_log format ["[LMO] [Reward] Intelligence decreased by %1, new Intelligence is %2", _value, resources_intel];
			} else {
				diag_log "[LMO] [Reward] LMO Penalties disabled for this mission, intelligence is unchanged.";
			};
		};
	};
};