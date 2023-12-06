/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to initialize capture or kill HVT LMO.
 *
 *	Arguments: None
 *
 *	Return Value: None
 *
 *	Example:
 *		[] call LMO_fn_missionHVT;
 */

//Predefining Variables
private _hvt = objNull;

//Create Task
private _tasks = [] call LMO_fn_taskCreate;

//Spawn Enemies and auto delete
private _enyUnits = [] call LMO_fn_garSpawner;
[_enyUnits] call LMO_fn_garDelete;

[
	{
		params ["_hvt","_enyUnits","_tasks"];
		//Assigns HVT
		private _enyInt = (units _enyUnits) select {insideBuilding _x == 1 && {(getPosATL _x) select 2 > 3}};
		if (count _enyInt > 0) then {
			_hvt = selectRandom _enyInt;
			["Elevated interior units found, HVT assigned.",LMO_DebugFull] call LMO_fn_rptSysChat;
		} else {
			_enyInt = ((units _enyUnits) select {insideBuilding _x == 1});
			if (count _enyInt > 0) then {
				_hvt = selectRandom _enyInt;
				["Interior units found, HVT assigned.",LMO_DebugFull] call LMO_fn_rptSysChat;
			} else {
				_hvt = selectRandom units _enyUnits;
				["No interior units found, HVT assigned.",LMO_DebugFull] call LMO_fn_rptSysChat;
			};
		};

		//HVT Custom Outfit
		[
			{
				params ["_hvt"];
				[_hvt, LMO_hvtOutfit] call LMO_fn_enyOutfit;
				["HVT Outfit completed.",LMO_DebugFull] call LMO_fn_rptSysChat;
			},
			[_hvt],
			1
		] call CBA_fnc_waitAndExecute;

		//Runner HVT Chance
		if (LMO_HVTallowRunner == true || LMO_HVTrunnerOnly == true) then {
			[] call LMO_fn_hvtRunner;
		};
		
		//Mission Outcome Checker
		[format ["HVT: %1, Pos: %2.", _hvt, position _hvt],LMO_DebugFull] call LMO_fn_rptSysChat;
		[
			{
				(_this select 0) params ["_hvt","_enyUnits","_tasks"];
				private _missionState = 0;
				if (LMO_active) then {

					//Checks if Player is within range of HVT to halt timer
					private _nearPlayers = (nearestObjects [_hvt, ["CAManBase","LandVehicle"], LMO_HVTholdRng]) select {isPlayer _x};
					if (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false]) then {
						if (count _nearPlayers > 0) then {
							[0,"ColorGrey",LMO_spawnBldg,LMO_HVTescRng,false,"Solid"] call LMO_fn_mTimerAdjust;
						} else {
							[1,"ColorGrey",position _hvt,LMO_HVTholdRng,true,"Solid"] call LMO_fn_mTimerAdjust;
						};
					} else {
							[1,"ColorOrange",LMO_MkrPos,LMO_objMkrRad,true,"FDiagonal"] call LMO_fn_mTimerAdjust;
					};

					//Updates LMO Marker Time on map
					LMO_MkrName setMarkerText format [" %1 [%2]",LMO_MkrText, LMO_mTimerStr];
					
					//Fail LMO if timer expires
					if (LMO_mTimer == 0) then {
						_missionState = 2;
						["[Timer] Timer has expired.",LMO_Debug] call LMO_fn_rptSysChat;
					};
					
					//----Win Lose Conditions----//

					//Eliminate HVT Lose Conditions	
					if (_missionState == 0) then {
						
						private _hvtEscChase = (_hvt nearEntities [["CAManBase","LandVehicle"],LMO_HVTchaseRng]) select {side _x == GRLIB_side_friendly};
						
						//if HVT is alive, mission timer expired, or not handcuffed and exited escape zone
						if (alive _hvt && (LMO_mTimer == 0 || (!(_hvt getVariable ["ace_captives_isHandcuffed", false]) && ((_hvt distance2D position LMO_spawnBldg > LMO_HVTescRng) && (count _hvtEscChase == 0))))) then {
						
							["LMOTaskOutcomeR", ["HVT has escaped", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							_missionState = 2;
							
							["HVT has escaped.",LMO_Debug] call LMO_fn_rptSysChat;

							//Lose Intel if HVT escapes
							[LMO_HVT_Lose_Intel,1,false] call LMO_fn_rewards;

							_hvt setVariable ["LMO_AngDeg",nil];
							deleteVehicle _hvt;
						};
					};
					
					//Eliminiate HVT Win Conditions
					if (_missionState == 0) then {
						
						//if HVT is alive, Mission Timer not expired, HVT has exited escape zone, is surrendered or handcuffed
						//OR
						//if HVT is dead, mission timer not expired
						if ((alive _hvt && LMO_mTimer > 0 && (_hvt distance2D position LMO_spawnBldg > LMO_bRadius * 0.8) && (_hvt getVariable ["ace_captives_isHandcuffed", false])) || (!alive _hvt && (LMO_mTimer > 0))) then {
							
							if (_hvtRunner < 0.5 || LMO_HVTrunnerOnly == true) then {
								deleteGroup _hvtRunnerGrp;
								_hvt setVariable ["LMO_AngDeg",nil];
								["Deleteing HVT Runner group, setting LMO_AngDeg to nil.",LMO_DebugFull] call LMO_fn_rptSysChat;
							};

							switch (alive _hvt) do {
								case true: {
									//noweapon, alive
									if (primaryWeapon _hvt == "") then {
										[LMO_HVT_Win_CapAlert,0,false] call LMO_fn_rewards;
										[LMO_HVT_Win_intelUnarmed,1,true] call LMO_fn_rewards;
									} else { //hasweapon, alive
										[LMO_HVT_Win_CapAlert,0,false] call LMO_fn_rewards;
										[LMO_HVT_Win_intelArmed,1,true] call LMO_fn_rewards;
									};

									["LMOTaskOutcomeG", ["HVT has been captured", "\z\ace\addons\captives\ui\handcuff_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
									deleteVehicle _hvt;
									["HVT has been captured.",LMO_Debug] call LMO_fn_rptSysChat;
								};
								case false: {
									[LMO_HVT_Win_KillAlert,0,false] call LMO_fn_rewards;
									["LMOTaskOutcomeG", ["HVT has been neutralized", "\A3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
									["HVT has been neutralized.",LMO_Debug] call LMO_fn_rptSysChat;
								};
							};

							_missionState = 1;
						};
					};

					//Ends Mission
					if (_missionState != 0) exitWith {
						[_missionState,_tasks] call LMO_fn_taskState;
						[_this select 1] call CBA_fnc_removePerFrameHandler;
						["Mission Finished, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
					};

				} else {
					//Removes PFH if mission is over.
					[_this select 1] call CBA_fnc_removePerFrameHandler;
					["LMO_active is false, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
				};
			},
			1,
			[_hvt,_enyUnits,_tasks]
		] call CBA_fnc_addPerFrameHandler;
	},
	[_hvt,_enyUnits,_tasks],
	3
] call CBA_fnc_waitAndExecute;
