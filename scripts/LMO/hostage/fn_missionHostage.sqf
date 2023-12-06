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
						_missionState = 2;
						["[Timer] Timer has expired.",LMO_Debug] call LMO_fn_rptSysChat;
					};

					//----Win Lose Conditions----//
					
					//Hostage Rescue Lose Conditions
					if ((!alive _hostage || LMO_mTimer == 0) && _missionState == 0) then {
						["LMOTaskOutcomeR", ["Hostage was killed", "\A3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];

						//Fails Mission
						_missionState = 2;

						//Allows all enemy units to move
						if (count units _enyUnits > 0) then {
							{_x enableAI "PATH"} forEach units _enyUnits;
						};
						
						//Decrease Civilian reputation
						[LMO_HR_Lose_CivRep,2,false] call LMO_fn_rewards;
						
						//Kills Hostage
						if (alive _hostage) then {
							_hostage setdamage 1;
							["[Timer] Hostage timer expired, killing hostage.",LMO_Debug] call LMO_fn_rptSysChat;
						} else {
							["Hostage was killed.",LMO_Debug] call LMO_fn_rptSysChat;
						};
					};

					//Hostage Rescue Win Conditions
					if (((_hostage distance2D position LMO_spawnBldg > _HRrad) && alive _hostage && LMO_mTimer > 0) && _missionState == 0) then {
						
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


