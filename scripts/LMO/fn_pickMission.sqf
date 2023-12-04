/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Main body of LMO, function to create mission sets and tasks. Evalutes the outcome state and assigns rewards to KP Resources.
 *
 *	Arguments:
 *		0: Mission Array - Variable that contains all of the enabled missions for the session.
 *
 *	Examples:
 *		[_missions] call LMO_fn_pickMission;
 *	
 *	Return Value: LMO_active
 */

//Variable init
params ["_missions"];

_missionState = 0;
_hvtRunner = 0;
_enyUnits = createGroup east;
_hvtRunnerGrp = createGroup east;
_hostageGrp = createGroup civilian;
_hostage = objNull;
_hvt = objNull;
_playerUnitHostages = [];
_enyUnitsInside = [];
_enyUnitPlayers = [];
_enyUnitHostages = [];
_HRrad = LMO_objMkrRadRescue;
_cache = objNull;
_missionType = 0;
_missionTypeName = "";
_sqdOrbat = [];
_sqdSize = 0;
LMO_cTimer = (LMO_CacheTimer)*60;

//Randomizes LMO Mission Type
if (LMO_Debug && LMO_mType != 0) then {
	_missionType = LMO_mType;
} else {
	_missionType = selectRandom _missions; 
};

missionNamespace setVariable ["LMO_MissionType",_missionType,true];

switch (_missionType) do {
	case 1:{_missionTypeName = "Hostage Rescue"};
	case 2:{_missionTypeName = "Capture or Kill HVT"};
	case 3:{_missionTypeName = "Destroy or Secure Cache"};
};

[format ["Mission assigned: %1 (%2)", _missionTypeName,_missionType],LMO_Debug] call LMO_fn_rptSysChat;

//Creates Parent Task
[GRLIB_side_friendly, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "LMO_Mkr"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
["_taskMO","Box"] call BIS_fnc_taskSetType;


//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		[] call LMO_fn_taskCreate;

		["Task Made",LMO_DebugFull] call LMO_fn_rptSysChat;

		//Checks whether hostage is in city
		_nearbyBuildings = nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, (LMO_objMkrRadRescue/2), false, true];
		//Increase escape radius if not in city
		if (count _nearbyBuildings < LMO_bHRrad) then {
			_HRrad = LMO_objMkrRadRescue * LMO_HRradMultiplier;
			[format ["Hostage target building is not near a city, rescue range expanded to %1 meters.",_HRrad],LMO_Debug] call LMO_fn_rptSysChat;
		};
		
		//Empties Variables
		_enyUnitHostages = [];
		_playerUnitHostages = [];
		_enyUnits = createGroup east;
		_hostageGrp = createGroup civilian;
		_hostage = objNull;
		_hTaker = objNull;
										
		//Spawn Hostages
		_hostageGrp createUnit [
			(selectRandom civilians),
			getPos LMO_spawnBldg,
			[],
			0,
			"NONE"
		];
		
		["Hostage spawned.",LMO_DebugFull] call LMO_fn_rptSysChat;

		_hostage = selectRandom units _hostageGrp;
		
		//Spawns Enemies
		_sqdOrbat append LMO_Orbat;
		_sqdSize = LMO_sqdSize call BIS_fnc_randomInt;

		if (_sqdSize != count _sqdOrbat) then {
			
			if (_sqdSize < count _sqdOrbat) then {
				_sqdOrbat resize _sqdSize;
			};

			while {_sqdSize > count _sqdOrbat} do {
					_sqdAdd = selectRandom LMO_Orbat;
					_sqdOrbat append [_sqdAdd];
			};
		};

		["Spawning enemies.",LMO_DebugFull] call LMO_fn_rptSysChat;

		_eCount = 0;
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x,
				getPos LMO_spawnBldg,
				[],
				0,
				"NONE"
			];
			[_enyUnitsHolder] joinSilent _enyUnits;
			_eCount = _eCount + 1;
		} forEach _sqdOrbat;

		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;
		
		[
			{
				params ["_eCount","_sqdSize"];
				_eCount == _sqdSize;
			},
			{
				params ["_eCount","_sqdSize","_enyUnits","_hostage"];

				[format ["%1 Enemies spawned.", count units _enyUnits],LMO_Debug] call LMO_fn_rptSysChat;

				[_enyUnits] call LMO_fn_removeThrowables;

				//Prevents random glitch that shoots AI into the air
				{
					if (((getPosATL _x) select 2) > 30) then {
						private _safePosUnit = (units _enyUnits) select {(getPosATL _x) select 2 <= 30};
						if (count _safePosUnit > 0) then {
							_x setVelocity [0,0,0];
							_x setPosATL getPosATL (selectRandom units _enyUnits);
						};
					};
				}forEach units _enyUnits;

				{
					_noMove = random 1;

					_x disableAI "RADIOPROTOCOL";

					if (_noMove <= 0.3) then {
						_x disableAI "PATH";
					};
				}forEach units _enyUnits;

				//VCOM will stop the AI squad from responding to calls for backup.
				if (LMO_VCOM_On == true) then {
					_enyUnits setVariable ["VCM_NORESCUE",true];
					_enyUnits setVariable ["VCM_DisableForm",true];
				};
				
				{
					[_x, LMO_garOutfit] call LMO_fn_enyOutfit;
				}forEach units _enyUnits;
				["Garrison Outfits completed.",LMO_DebugFull] call LMO_fn_rptSysChat;
				
				//Spawns Hostage
				[
					{
						params ["_enyUnits","_hostage"];
						[_enyUnits,_hostage] call LMO_fn_spawnHostage;
					},
					[_enyUnits,_hostage],
					1
				] call CBA_fnc_waitAndExecute;
			},
			[_eCount,_sqdSize,_enyUnits,_hostage]
		] call CBA_fnc_waitUntilandExecute;
	};
	
	//Eliminate HVT
	case 2:{
		[] call LMO_fn_taskCreate;

		["Task Made",LMO_DebugFull] call LMO_fn_rptSysChat;

		_enyUnits = createGroup east;
		
		//Spawns Enemies
		_sqdOrbat append LMO_Orbat;
		_sqdSize = LMO_sqdSize call BIS_fnc_randomInt;

		if (_sqdSize != count _sqdOrbat) then {
			
			if (_sqdSize < count _sqdOrbat) then {
				_sqdOrbat resize _sqdSize;
			};

			while {_sqdSize > count _sqdOrbat} do {
					_sqdAdd = selectRandom LMO_Orbat;
					_sqdOrbat append [_sqdAdd];
			};
		};
		
		["Spawning enemies.",LMO_Debug] call LMO_fn_rptSysChat;
		
		_eCount = 0;
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x,
				getPos LMO_spawnBldg,
				[],
				0,
				"NONE"
			];
			[_enyUnitsHolder] joinSilent _enyUnits;
			_eCount = _eCount + 1;
		} forEach _sqdOrbat;

		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;

		[_enyUnits] call LMO_fn_removeThrowables;

		//Prevents random glitch that shoots AI into the air
		{
			if (((getPosATL _x) select 2) > 30) then {
				_safePosUnit = (units _enyUnits) select {(getPosATL _x) select 2 <= 30};
				if (count _safePosUnit > 0) then {
					_x setVelocity [0,0,0];
					_x setPosATL getPosATL (selectRandom units _enyUnits);
				};
			};
		}forEach units _enyUnits;

		{
			_noMove = random 1;
			_x disableAI "RADIOPROTOCOL";
			if (_noMove <= 0.3) then {_x enableAI "PATH"};
		}forEach units _enyUnits;
		
		//VCOM will stop the AI squad from responding to calls for backup.
		if (LMO_VCOM_On == true) then {
			_enyUnits setVariable ["VCM_NORESCUE",true];
			_enyUnits setVariable ["VCM_DisableForm",true];
		};

		{
			[_x, LMO_garOutfit] call LMO_fn_enyOutfit;
		}forEach units _enyUnits;

		["Garrison Outfits completed.",LMO_DebugFull] call LMO_fn_rptSysChat;

		_enyUnitsInside = (units _enyUnits) select {insideBuilding _x == 1 && {(getPosATL _x) select 2 > 3}};
		
		if (count _enyUnitsInside >= 1) then {
			_hvt = selectRandom _enyUnitsInside;
		} else {
			_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
			if (count _enyUnitsInside > 0) then {
				_hvt = selectRandom _enyUnitsInside;
			} else {
				_hvt = selectRandom units _enyUnits;
			};
		};
		
		["HVT assigned.",LMO_DebugFull] call LMO_fn_rptSysChat;

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
	};
	
	//Locate Cache
	case 3:{
		
		[] call LMO_fn_taskCreate;

		_cSpawnPos = getPosATL LMO_spawnBldg findEmptyPosition [0, 40, LMO_CacheModel];
		_cache = objNull;
		
		//Spawn Cache
		if (count _cSpawnPos > 0) then {
			_cache = createVehicle [LMO_CacheModel, _cSpawnPos, [], 0, "CAN_COLLIDE"];
			[format ["Cache created at %1", getPos _cache],LMO_Debug] call LMO_fn_rptSysChat;
		} else {
			_cache = createVehicle [getPos LMO_spawnBldg, LMO_CacheModel, [], 0, "CAN_COLLIDE"];
			[format ["No suitable cache spot found. Creating cache in target building at %1", getPos _cache],LMO_Debug] call LMO_fn_rptSysChat;
		};

		//Debug marker for cache location
		if (LMO_Debug_Mkr) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position _cache];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
			["Debug Marker created",LMO_DebugFull] call LMO_fn_rptSysChat;
		};
		
		//Empty contents of Cache
		if (LMO_CacheEmpty == true) then {
			clearItemCargoGlobal _cache;
			clearWeaponCargoGlobal _cache;
			clearMagazineCargoGlobal _cache;
			["Cache cargo emptied.",LMO_DebugFull] call LMO_fn_rptSysChat;
		};
		
		//Add explosives to cache
		if (LMO_CacheItems == true) then {
			{
				_cache addItemCargoGlobal [(_x select 0), (_x select 1)];
			} forEach LMO_CacheItemArray;
			["Cache items added.",LMO_DebugFull] call LMO_fn_rptSysChat;
		};
		_cache setVariable ["LMO_CacheSecure", false, true];
		
		//Adds hold action to cache to secure
		[
			_cache,
			"Secure Cache",
			"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
			"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unloaddevice_ca.paa",
			"(_this distance _target < 3) && (alive _target) && (cursorObject == _target) && ((_target getVariable 'LMO_CacheSecure') != true)",
			"(_caller distance _target < 3) && (alive _target) && ((_target getVariable 'LMO_CacheSecure') != true)",
			{
				_caller playMoveNow "Acts_carFixingWheel";
				playSound3D ["a3\sounds_f\characters\stances\rifle_to_launcher.wss", _target];
			},
			{
				if (_target getVariable ["LMO_CacheSecure",true]) then {
					_caller switchMove "";
					[_target,_actionId] call BIS_fnc_holdActionRemove;
					["Cache secured, cancelling action and deleting holdAction.",LMO_DebugFull] call LMO_fn_rptSysChat;
				};
			},
			{
				_caller switchMove "";
				_target setVariable ["LMO_CacheSecure", true, true];
				_cStrobe = "PortableHelipadLight_01_red_F" createVehicle getPos _target;
				_cStrobe attachTo [_target, [0,0.2,-0.7]];
				playSound3D ["a3\sounds_f\vehicles\soft\suv_01\suv_01_door.wss", _target];
				[
					{
						params ["_target"];
						playSound3D ["a3\sounds_f\sfx\beep_target.wss", _target];
					},
					[_target],
					0.5
				] call CBA_fnc_waitAndExecute;

				[format ["CacheSecure: %1", _target getVariable "LMO_CacheSecure"],LMO_DebugFull] call LMO_fn_rptSysChat;
				
				[_target,_actionId] call BIS_fnc_holdActionRemove;
			},
			{_caller switchMove ""},
			[_cache],
			5,
			2000,
			true,
			false
		] remoteExec ["BIS_fnc_holdActionAdd", 0, _cache];

		["Cache Hold action created.",LMO_DebugFull] call LMO_fn_rptSysChat;

		_cache addEventHandler ["Explosion", {
			params ["_vehicle", "_damage"];
			if (_damage > 1) then {
				_cAttached = attachedObjects _vehicle select {typeOf _x == "PortableHelipadLight_01_red_F"};
				if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
				[format ["Cache destroyed, CacheSecure variable: %1", _vehicle getVariable "LMO_CacheSecure"],LMO_Debug] call LMO_fn_rptSysChat;
				
				_vehicle setDamage 1;
				
			};
			[format ["Cache Damaged: %1", _damage],LMO_Debug] call LMO_fn_rptSysChat;
		}];		
	};
};

//Mission Outcome Checker
[
	{
		(_this select 0) params ["_missionType","_hostageGrp","_hvt","_hvtRunner","_HRrad","_cache","_hostage","_enyUnits","_taskMO","_taskMisMO","_missionState"];
		if (LMO_active) then {	
			//Hostage Pause Timer Radius
			_hPauseRng = 10;

			//Hostage Rescue Parameters
			if (_missionType == 1) then {
				//Checks if Player is within range of hostage to halt timer
								
				_playerUnitHostages = (nearestObjects [_hostage, ["CAManBase","LandVehicle"], _hPauseRng]) select {isPlayer _x};
				_enyUnitHostages = (nearestObjects [_hostage, ["CAManBase","LandVehicle"], _hPauseRng]) select {!isPlayer _x} select {side _x == GRLIB_side_enemy};

				if ((count _playerUnitHostages > 0) && (count _enyUnitHostages == 0)) then {

					[0,"ColorGrey",LMO_spawnBldg,_HRrad,false,"Solid"] call LMO_fn_mTimerAdjust;
				} else {

					[1,"ColorBlue",LMO_MkrPos,LMO_objMkrRad,false,"FDiagonal"] call LMO_fn_mTimerAdjust;
				};
				
			} else {
				if (_missionType == 2) then {
					
					//Checks if Player is within range of HVT to halt timer
					_playerUnitsHVT = (nearestObjects [_hvt, ["CAManBase","LandVehicle"], _hPauseRng]) select {isPlayer _x};
					
					if (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false]) then {
						if (count _playerUnitsHVT > 0) then {
							[0,"ColorGrey",LMO_spawnBldg,LMO_HVTescRng,false,"Solid"] call LMO_fn_mTimerAdjust;
						} else {
							[1,"ColorGrey",position _hvt,_hPauseRng,true,"Solid"] call LMO_fn_mTimerAdjust;
						};
					} else {
							[1,"ColorOrange",LMO_MkrPos,LMO_objMkrRad,true,"FDiagonal"] call LMO_fn_mTimerAdjust;
					};
					
				} else {
					
					//Checks if cache is secured to halt timer
					if (_missionType == 3 && (_cache getVariable ["LMO_CacheSecure", true])) then {

						LMO_MkrName setMarkerColor "ColorGrey";
						LMO_Mkr setMarkerColor "ColorGrey";
						LMO_Mkr setMarkerPos position _cache;
						LMO_MkrName setMarkerPos position _cache;
						LMO_Mkr setMarkerSize [LMO_CacheDefDist,LMO_CacheDefDist];
						LMO_Mkr setMarkerBrush "Solid";
						_cNearTimer = ((nearestObjects [_cache, ["CAManBase", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_enemy}) select {!(_x getVariable ["ACE_isUnconscious", false])};
						if (LMO_cTimer > 0 && (count _cNearTimer == 0)) then {
							LMO_cTimer = LMO_cTimer - 1;
							LMO_mTimerStr = [LMO_cTimer, "MM:SS"] call BIS_fnc_secondsToString;
						};

					} else {

						LMO_mTimer = LMO_mTimer - 1;
						LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
					};
				};
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
			if (_missionType == 1 && (!alive _hostage || LMO_mTimer == 0)) then {
				["LMOTaskOutcomeR", ["Hostage was killed", "\A3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			
				_missionState = 2;
				
				{_x setdamage 1} forEach units _hostageGrp;
				{_x enableAI "PATH"} forEach units _enyUnits;
				
				if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select 1) == true)) then {
					//Deduct Civilian reputation as defined in kp_liberation_config.sqf
					[LMO_HR_Lose_CivRep, true] call F_cr_changeCR;
					[format ["[Reward] CivRep deducted by %1, new CivRep is %2", LMO_HR_Lose_CivRep, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
				} else {
					["LMO Penalties disabled for this mission, CivRep is unchanged.",LMO_Debug] call LMO_fn_rptSysChat;
				};
				
				if (alive _hostage) then {
					_hostage setdamage 1;
					["[Timer] Hostage timer expired, killing hostage.",LMO_Debug] call LMO_fn_rptSysChat;
				} else {
					["Hostage was killed.",LMO_Debug] call LMO_fn_rptSysChat;
				};

				["Starting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
				[
					{
						(_this select 0) params ["_enyUnits","_hostageGrp"];
						_enyUnitPlayers = [];
						if ({alive _x} count units _enyUnits > 0) then {
							
							{
								_enyUnitPlayers = (nearestObjects [_x, ["CAManBase","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
							}forEach units _enyUnits;
							
							if (count _enyUnitPlayers == 0) exitWith {
								{
									deleteVehicle _x;
								}forEach units _enyUnits;
								deleteGroup _enyUnits;
								deleteGroup _hostageGrp;
								[_this select 1] call CBA_fnc_removePerFrameHandler;
								["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
							};
						} else {
							[_this select 1] call CBA_fnc_removePerFrameHandler;
							["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
						};
					},
					5,
					[_enyUnits, _hostageGrp]
				] call CBA_fnc_addPerFrameHandler;
			};

			//Hostage Rescue Win Conditions
			if (_missionType == 1 && (_hostage distance2D position LMO_spawnBldg > _HRrad) && alive _hostage && LMO_mTimer > 0) then {
				
				["LMOTaskOutcomeG", ["Hostage secured", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
				
				_missionState = 1;

				["Hostage has been rescued.",LMO_Debug] call LMO_fn_rptSysChat;

				//Increase Civilian reputation and intelligence
				[LMO_HR_Win_Intel,true,1] call LMO_fn_rewards;
				if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
					_finalReward = round (LMO_HR_Win_CivRep * LMO_TST_Reward);
					[_finalReward] call F_cr_changeCR;
					[format ["[Reward] CivRep increased by %1 (TST), new CivRep is %2", _finalReward, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
				} else {
					[LMO_HR_Win_CivRep] call F_cr_changeCR;
					[format ["[Reward] CivRep increased by %1, new CivRep is %2", LMO_HR_Win_CivRep, KP_liberation_civ_rep],LMO_Debug] call LMO_fn_rptSysChat;
				};

				{deleteVehicle _x}forEach units _enyUnits;
				{deleteVehicle _x}forEach units _hostageGrp;
				deleteVehicle _hostage;
				deleteGroup _enyUnits;
				deleteGroup _hostageGrp;
			};

			//Eliminate HVT Lose Conditions	
			if (_missionType == 2) then {
				
				_hvtEscChase = (_hvt nearEntities [["CAManBase","LandVehicle"],LMO_HVTchaseRng]) select {side _x == GRLIB_side_friendly};
				
				//if HVT is alive, mission timer expired, or not handcuffed and exited escape zone
				if (alive _hvt && (LMO_mTimer == 0 || (!(_hvt getVariable ["ace_captives_isHandcuffed", false]) && ((_hvt distance2D position LMO_spawnBldg > LMO_HVTescRng) && (count _hvtEscChase == 0))))) then {
				
					["LMOTaskOutcomeR", ["HVT has escaped", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					_missionState = 2;
					
					["HVT has escaped.",LMO_Debug] call LMO_fn_rptSysChat;

					//Lose Intel if HVT escapes
					[LMO_HVT_Lose_Intel,false,1] call LMO_fn_rewards;
					
					if (_hvtRunner < 0.5 || LMO_HVTrunnerOnly == true) then {
						deleteGroup _hvtRunnerGrp;
						_hvt setVariable ["LMO_AngDeg",nil];
					};
					
					deleteVehicle _hvt;
					
					["Starting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
					[
						{
							(_this select 0) params ["_enyUnits"];
							_enyUnitPlayers = [];
							if ({alive _x} count units _enyUnits > 0) then {
								
								{
									_enyUnitPlayers = (nearestObjects [_x, ["CAManBase","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
								}forEach units _enyUnits;
								
								if (count _enyUnitPlayers == 0) exitWith {
									{
										deleteVehicle _x;
									}forEach units _enyUnits;
									deleteGroup _enyUnits;
									deleteGroup _hostageGrp;
									[_this select 1] call CBA_fnc_removePerFrameHandler;
									["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
								};
							} else {
								[_this select 1] call CBA_fnc_removePerFrameHandler;
								["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
							};
						},
						5,
						[_enyUnits]
					] call CBA_fnc_addPerFrameHandler;
				};
			};
			
			//Eliminiate HVT Win Conditions
			if (_missionType == 2) then {
				
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
								[LMO_HVT_Win_CapAlert,false,0] call LMO_fn_rewards;
								[LMO_HVT_Win_intelUnarmed,true,1] call LMO_fn_rewards;
							} else { //hasweapon, alive
								[LMO_HVT_Win_CapAlert,false,0] call LMO_fn_rewards;
								[LMO_HVT_Win_intelArmed,true,1] call LMO_fn_rewards;
							};

							["LMOTaskOutcomeG", ["HVT has been captured", "\z\ace\addons\captives\ui\handcuff_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							deleteVehicle _hvt;
							["HVT has been captured.",LMO_Debug] call LMO_fn_rptSysChat;
						};
						case false: {
							[LMO_HVT_Win_KillAlert,false,0] call LMO_fn_rewards;
							["LMOTaskOutcomeG", ["HVT has been neutralized", "\A3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							["HVT has been neutralized.",LMO_Debug] call LMO_fn_rptSysChat;
						};
					};

					_missionState = 1;
					
					["Starting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
					[
						{
							(_this select 0) params ["_enyUnits"];
							_enyUnitPlayers = [];
							if ({alive _x} count units _enyUnits > 0) then {
								
								{
									_enyUnitPlayers = (nearestObjects [_x, ["CAManBase","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
								}forEach units _enyUnits;
								
								if (count _enyUnitPlayers == 0) exitWith {
									{
										deleteVehicle _x;
									}forEach units _enyUnits;
									deleteGroup _enyUnits;
									deleteGroup _hostageGrp;
									[_this select 1] call CBA_fnc_removePerFrameHandler;
									["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
								};
							} else {
								[_this select 1] call CBA_fnc_removePerFrameHandler;
								["Exiting delete units PFH.",LMO_DebugFull] call LMO_fn_rptSysChat;
							};
						},
						5,
						[_enyUnits]
					] call CBA_fnc_addPerFrameHandler;
				};
			};
			//
			//Cache Win Conditions
			if (_missionType == 3 && LMO_mTimer > 0) then {

				_cSecured = missionNamespace getVariable ["LMO_CacheTagged",false];

				//If cache destroyed and NOT secured
				if ((!alive _cache) && (_cSecured == false)) then {
					_missionState = 1;
					["Cache was destroyed and not secured.",LMO_Debug] call LMO_fn_rptSysChat;
					["LMOTaskOutcomeG", ["Cache has been destroyed", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					[LMO_Cache_Win_Alert,false,0] call LMO_fn_rewards;
				};
				
				//If Secured Cache
				if ((alive _cache) && (_cache getVariable ["LMO_CacheSecure", true] && (_cSecured == false))) then {
					["LMOTaskOutcome", ["Cache has been located", "a3\ui_f\data\gui\rsccommon\rscbuttonsearch\search_start_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					
					//Marks cache as tagged in missionNameSpace to prevent loop executions
					missionNamespace setVariable ["LMO_CacheTagged",true,true];
					[format ["missionnameSpace _cSecured: %1. qrfCache and cacheFulton initializing.",missionNamespace getVariable "LMO_CacheTagged"],LMO_Debug] call LMO_fn_rptSysChat;
				
					//Defend cache
					[
						{
							["LMOTaskOutcomeR", ["Enemy forces are attempting to retake cache", "\a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						},
						[],
						11
					] call CBA_fnc_waitAndExecute;
					[
						{
							params ["_cache","_taskMO","_taskMisMO"];
							//[_cache] call LMO_fn_qrfCache;
							[getpos _cache, LMO_qrfOutfit, 1, LMO_qrfSqdMultiply, LMO_qrfSplit, LMO_qrfPlayerRng, LMO_qrfSqdSpawnDist] call LMO_fn_qrfSpawner;
							[_cache,"_taskMO","_taskMisMO"] call LMO_fn_cacheFulton;
						},
						[_cache,"_taskMO","_taskMisMO"],
						1
					] call CBA_fnc_waitAndExecute;
				};
			};
			
			//Cache Lose Conditions
			if (_missionType == 3 && LMO_mTimer == 0 && (_missionState == 0)) then {
				//If Timer expires
				if (alive _cache && !(_cache getVariable ["LMO_CacheSecure", true])) then {
					_missionState = 2;
					[
						{
							!LMO_active
						},
						{
							missionNamespace setVariable ["LMO_CacheTagged", nil, true];
							["LMO_CacheTagged set to nil.",LMO_Debug] call LMO_fn_rptSysChat;
						},
						[]
					] call CBA_fnc_waitUntilAndExecute;

					[LMO_Cache_Lose_Alert,true,0] call LMO_fn_rewards;

					["LMOTaskOutcomeR", ["Cache has been moved by the enemy", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					_cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
					if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
					deleteVehicle _cache;
					["Cache deleted.",LMO_Debug] call LMO_fn_rptSysChat;
				};
			};
			
			//Ends Mission
			if (_missionState != 0) exitWith {
				[_missionState,"_taskMO","_taskMisMO"] call LMO_fn_taskState;
				[_this select 1] call CBA_fnc_removePerFrameHandler;
				["Mission Finished, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
			};
		} else {
			[_this select 1] call CBA_fnc_removePerFrameHandler;
			["LMO_active is false, exiting pickMission PFH.",LMO_Debug] call LMO_fn_rptSysChat;
		};
	},
	1,
	[_missionType,_hostageGrp,_hvt,_hvtRunner,_HRrad,_cache,_hostage,_enyUnits,"_taskMO","_taskMisMO",_missionState]
] call CBA_fnc_addPerFrameHandler;