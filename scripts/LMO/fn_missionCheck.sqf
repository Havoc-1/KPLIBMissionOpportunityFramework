[
	{
		private _e = [];
		private _eList = [];
		private _missions = [];
		private _mChance = random 100;
		//Run LMO check if at least 1 enemy present and no LMO active
		if ((count (allUnits select {side _x == GRLIB_side_enemy}) > 0) && !LMO_active) then {
			
			//Checks for nearby enemy units near all players
			{
				_e = (_x nearEntities [["CAManBase","LandVehicle"], LMO_enyRng]) select {side _x == GRLIB_side_enemy};
				_eList append _e;
			}forEach (allPlayers select {alive _x});
			
			[format ["Mission Check %1%2, %3 nearby enemy units found.", round _mChance,"%",count _eList],LMO_Debug] call LMO_fn_rptSysChat;
			if (count _eList == 0) exitWith {};
			//Activate LMO if enemy found and mission chance met
			if ((_mChance <= LMO_mChanceSelect) || LMO_Debug) then {
				
				//Adds all enabled missions to mission array
				{
					if (_x == true) then {_missions pushback (_forEachIndex + 1)};
				}forEach LMO_Missions;

				//Exits LMO if no missions are enabled
				if (count _missions == 0) exitWith {
					["No missions are enabled. Setting LMO_active to false.", LMO_Debug] call LMO_fn_rptSysChat;
					LMO_active = false;
				};
				[format ["%1 Missions Enabled.",count _missions], LMO_DebugFull] call LMO_fn_rptSysChat;

				//Finds target building
				[_eList] call LMO_fn_getBuildings;
				if (!LMO_active) exitWith {["No Buildings Found. Setting LMO_active to false.",LMO_Debug] call LMO_fn_rptSysChat};

				//Create Markers and start mission
				[] call LMO_fn_markerFunctions;
				[_missions] call LMO_fn_pickMission;
			};
		};
	},
	LMO_mCheckRNG*60,
	[]
] call CBA_fnc_addPerFrameHandler;