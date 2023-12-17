/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to initialize hostage rescue LMO.
 *
 *	Arguments: None
 *
 *	Return Value: None
 *
 *	Example:
 *		[] call LMO_fn_missionHostage;
 */

//Predefining Variables
private _hostageGrp = createGroup civilian;
private _hostage = objNull;


//Create Task
private _tasks = [] call LMO_fn_taskCreate;

//Create Hostage
_hostage = _hostageGrp createUnit [(selectRandom civilians),getPos LMO_spawnBldg,[],0,"NONE"];
_hostageGrp deleteGroupWhenEmpty true;
["Hostage spawned.",LMO_DebugFull] call LMO_fn_rptSysChat;

//Spawn Enemies and auto delete
private _enyUnits = [] call LMO_fn_garSpawner;
[_enyUnits] call LMO_fn_garDelete;

//Mission Outcome Checker
[
	{
		params ["_hostage"];
		!isNull _hostage;
	},
	{
		params ["_hostage","_enyUnits","_tasks","_HRrad"];

		//Move Hostage to interior
		[
			{
				params ["_enyUnits","_hostage"];
				[_enyUnits,_hostage] call LMO_fn_moveHostage;
			},
			[_enyUnits,_hostage],
			2
		] call CBA_fnc_waitAndExecute;

		//Increase escape radius if not in city
		private _HRrad = LMO_objMkrRadRescue;
		private _nearbyBuildings = nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, (LMO_objMkrRadRescue/2), false, true];
		if (count _nearbyBuildings < LMO_bHRrad) then {
			_HRrad = LMO_objMkrRadRescue * LMO_HRradMultiplier;
			[format ["Hostage target building is not near a city, rescue range expanded to %1 meters.",_HRrad],LMO_Debug] call LMO_fn_rptSysChat;
		};

		//Add Bomb vest to hostage
		if (LMO_HRallowBomb) then {
			
			if (random 1 <= LMO_HRbombChance) then {
				["Hostage has bomb vest.",LMO_Debug] call LMO_fn_rptSysChat;
				_hostage setVariable ["LMO_hasBomb", true];
				removeVest _hostage;
				_hostage addVest LMO_HRbombVest;
				[
					{
						params ["_hostage"];
						vest _hostage == LMO_HRbombVest;
					},
					{
						params ["_hostage"];
						//Detonate Vest if removed
						_hostage addEventHandler ["SlotItemChanged",{
							params ["_unit","_name","_slot","_assigned"];
							private _hasBomb = _unit getVariable ["LMO_hasBomb", false];
							if ((_name == LMO_HRbombVest) && (_hasBomb == true) && !_assigned) then {
								[
									{
										params ["_unit"];
										["Bomb vest has detonated.",LMO_Debug] call LMO_fn_rptSysChat;
										private _bomb = LMO_HRbomb createVehicle (getPosATL _unit);
										_unit setVariable ["LMO_hasBomb",nil];
										_bomb setDamage 1;
									},
									[_unit],
									LMO_HRbombDelay
								] call CBA_fnc_waitAndExecute;
							};
						}];

						//Detonate Vest if killed
						_hostage addEventHandler ["Killed",{
							params ["_unit", "_killer", "_instigator", "_useEffects"];
							private _hasBomb = _unit getVariable ["LMO_hasBomb", false];
							if ((!alive _unit) && (_hasBomb == true)) then {
								playSound3D ["a3\sounds_f\weapons\mines\mech_trigger_2.wss", _unit];
								[
									{
										params ["_unit"];
										["Bomb vest has detonated.",LMO_Debug] call LMO_fn_rptSysChat;
										removeVest _unit;
										private _bomb = LMO_HRbomb createVehicle (getPosATL _unit);
										_unit setVariable ["LMO_hasBomb",nil];
										_bomb setDamage 1;
									},
									[_unit],
									LMO_HRbombDelay
								] call CBA_fnc_waitAndExecute;
							};
						}];
					},
					[_hostage]
				] call CBA_fnc_waitUntilandExecute;
				

				//Adds bomb beep SFX if about to detonate
				if (LMO_HRbombBeep) then {
					private _beepTimer = LMO_HRbeepTime;
					[
						{
							params ["_hostage","_beepTimer"];
							(LMO_mTimer <= _beepTimer) || (!alive _hostage);
						},
						{
							params ["_hostage","_beepTimer"];
							if (alive _hostage) then {
								[
									{
										(_this select 0) params ["_hostage","_beepTimer"];
										private _hasBomb = _hostage getVariable ["LMO_hasBomb", false];
										if (alive _hostage && LMO_mTimer <= _beepTimer && _hasBomb == true) then {
											playSound3D ["a3\sounds_f\sfx\beep_target.wss", _hostage];
										} else {
											[_this select 1] call CBA_fnc_removePerFrameHandler;
										};
									},
									1,
									[_hostage,_beepTimer]
								] call CBA_fnc_addPerFrameHandler;
							};
						},
						[_hostage,_beepTimer]
					] call CBA_fnc_waitUntilandExecute;

					//Adds defuse holdAction to hostage
					private _bombCond = "";
					private _bombCond2 = "";
					switch (LMO_HRdefuse) do {
						case 1:{
							_bombCond = "&& (_this getUnitTrait 'engineer')";
							_bombCond2 = "&& (_caller getUnitTrait 'engineer')";
						};
						case 2:{
							_bombCond = "&& (_this getUnitTrait 'explosiveSpecialist')";
							_bombCond2 = "&& (_caller getUnitTrait 'explosiveSpecialist')";
						};
						case 3:{
							_bombCond = "&& (_this getUnitTrait 'engineer') && (_this getUnitTrait 'explosiveSpecialist')";
							_bombCond2 = "&& (_caller getUnitTrait 'engineer') && (_caller getUnitTrait 'explosiveSpecialist')";
						};
						default {
							_bombCond = "";
							_bombCond2 = "";
						};
					};
					[
						_hostage,
						"Disarm Bomb Vest",
						"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
						"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
						format ["(_this distance _target < 3) && (alive _target) && (cursorObject == _target) && ((_target getVariable 'LMO_hasBomb') == true)"+"%1",_bombCond],
						format ["(_caller distance _target < 3) && (alive _target) && ((_target getVariable 'LMO_hasBomb') == true)"+"%1",_bombCond2],
						{
							_caller playMoveNow "Acts_carFixingWheel";
							playSound3D ["a3\sounds_f\characters\stances\rifle_to_launcher.wss", _target];
						},
						{
							private _hasBomb = _target getVariable ["LMO_hasBomb",false];
							if (!_hasBomb) then {
								_caller switchMove "";
								[_target,_actionId] call BIS_fnc_holdActionRemove;
								["Bomb Vest has been removed.",LMO_DebugFull] call LMO_fn_rptSysChat;
							};
						},
						{
							_caller switchMove "";
							_target setVariable ["LMO_hasBomb",false];
							removeVest _target;
							["Bomb Vest has been removed.",LMO_DebugFull] call LMO_fn_rptSysChat;
							
							[_target,_actionId] call BIS_fnc_holdActionRemove;
						},
						{_caller switchMove ""},
						[_bombCond],
						LMO_HRdefuseTime,
						2000,
						true,
						false
					] remoteExec ["BIS_fnc_holdActionAdd", 0, _hostage];
				};
			} else {
				["Hostage does not have bomb vest.",LMO_Debug] call LMO_fn_rptSysChat;
			};
		};
		


		[
			{
				(_this select 0) params ["_hostage","_enyUnits","_tasks","_HRrad"];

				private _missionState = 0;

				if (LMO_active || alive _hostage) then {
					
					//Checks if Player is within range of hostage to halt timer
					private _hPauseRng = 10;		
					private _nearPlayer = (nearestObjects [_hostage, ["CAManBase","LandVehicle"], _hPauseRng]) select {isPlayer _x};
					private _nearEny = (nearestObjects [_hostage, ["CAManBase","LandVehicle"], _hPauseRng]) select {!isPlayer _x} select {side _x == GRLIB_side_enemy};

					//Adjust markers and timer
					if ((count _nearPlayer > 0) && (count _nearEny == 0)) then {
						[0,"ColorGrey",LMO_spawnBldg,_HRrad,false,"Solid"] call LMO_fn_mTimerAdjust;
					} else {
						[1,"ColorBlue",LMO_MkrPos,LMO_objMkrRad,false,"FDiagonal"] call LMO_fn_mTimerAdjust;
					};

					//Updates LMO Marker Time on map
					LMO_MkrName setMarkerText format [" %1 [%2]",LMO_MkrText, LMO_mTimerStr];

					//Fail LMO if timer expires
					if (LMO_mTimer == 0) then {
						
						//Kills Hostage
						if (alive _hostage) then {
							_hostage setdamage 1;
							["[Timer] Hostage timer expired, killing hostage.",LMO_Debug] call LMO_fn_rptSysChat;
						} else {
							["Hostage was killed.",LMO_Debug] call LMO_fn_rptSysChat;
						};

						_missionState = 2;
						["[Timer] Timer has expired.",LMO_Debug] call LMO_fn_rptSysChat;

						//Allows all enemy units to move
						if (count units _enyUnits > 0) then {
							{_x enableAI "PATH"} forEach units _enyUnits;
						};
						
						//Decrease Civilian reputation
						[LMO_HR_Lose_CivRep,2,false] call LMO_fn_rewards;
					};

					//----Win Lose Conditions----//
					
					//Hostage Rescue Lose Conditions
					if ((!(alive _hostage) || LMO_mTimer == 0) && _missionState == 0) then {
						["LMOTaskOutcomeR", ["Hostage was killed", "\A3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];

						//Kills Hostage
						if (alive _hostage) then {
							_hostage setdamage 1;
							["[Timer] Hostage timer expired, killing hostage.",LMO_Debug] call LMO_fn_rptSysChat;
						} else {
							["Hostage was killed.",LMO_Debug] call LMO_fn_rptSysChat;
						};

						//Fails Mission
						_missionState = 2;

						//Allows all enemy units to move
						if (count units _enyUnits > 0) then {
							{_x enableAI "PATH"} forEach units _enyUnits;
						};
						
						//Decrease Civilian reputation
						[LMO_HR_Lose_CivRep,2,false] call LMO_fn_rewards;
					};

					//Hostage Rescue Win Conditions
					if (((_hostage distance2D position LMO_spawnBldg > _HRrad) && alive _hostage && LMO_mTimer > 0) && _missionState == 0) then {
						
						private _hasBomb = _hostage getVariable ["LMO_hasBomb", false];
						if (_hasBomb) then {
							_hostage setVariable ["LMO_hasBomb", true];
						};

						["LMOTaskOutcomeG", ["Hostage secured", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						
						_missionState = 1;

						["Hostage has been rescued.",LMO_Debug] call LMO_fn_rptSysChat;

						//Increase Civilian reputation and intelligence
						[LMO_HR_Win_Intel,1,true] call LMO_fn_rewards;
						[LMO_HR_Win_CivRep,2,true] call LMO_fn_rewards;

						//Deletes units for mission
						deleteVehicle _hostage;
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
			[_hostage,_enyUnits,_tasks,_HRrad]
		] call CBA_fnc_addPerFrameHandler;
	},
	[_hostage,_enyUnits,_tasks,_HRrad]
] call CBA_fnc_waitUntilandExecute;


