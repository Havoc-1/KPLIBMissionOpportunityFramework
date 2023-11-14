<<<<<<< Updated upstream
=======
/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Main body of LMO, function to create mission sets and tasks. Evalutes the outcome state and assigns rewards to KP Resources.
 *
 *	Arguments:
 *	None
 *
 *	Examples:
 *		[] call XEPKEY_fn_pickMission;
 *	
 *	Return Value: LMO_active
 */
>>>>>>> Stashed changes

//Variable init
_missionFailed = false;
_missionSuccess = false;
_enyUnits = createGroup east;
_hostages = createGroup civilian;
_hvt = objNull;
_hvtHeadgear = ["H_Bandanna_khk","H_bandanna_gry","H_Bandanna_cbr"];
_hvtGoggles = ["G_Bandanna_beast","G_Balaclava_Skull1","G_Bandanna_aviator","G_Bandanna_blk","G_Bandanna_shades","None"];

_playerUnitHostages = [];
_enyUnitsInside = [];
_enyUnitPlayers = [];
_enyUnitHostages = [];
<<<<<<< Updated upstream

_missionType = [1,2] call BIS_fnc_randomInt;
=======
_HRrad = LMO_objMkrRadRescue;
_cache = objNull;
_missionType = 0;
_sqdOrbat = [];
_sqdSize = 0;
LMO_cTimer = (LMO_CacheTimer)*60;

//Randomizes LMO Mission Type
if (LMO_Debug && LMO_mType != 0) then {
	_missionType = LMO_mType;
} else {
	_missionType = [1,3] call BIS_fnc_randomInt;
};

//Model used for Cache OBJ
_cModel = "Box_FIA_Wps_F";

//Creates Parent Task
[GRLIB_side_friendly, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "LMO_Mkr"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
["_taskMO","Box"] call BIS_fnc_taskSetType;
>>>>>>> Stashed changes

[west, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "objMarker"], objNull, 1, 3, false] call BIS_fnc_taskCreate;

//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		
		//Creates Task
<<<<<<< Updated upstream
		[west, ["_taskMissionMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Locate and extract the hostage.", objMarkerName,objMarkerText], "MO: Hostage Rescue", "REGROUP_MARKER"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
		objMarkerName setMarkerColor "ColorBlue";
		objMarker setMarkerColor "ColorBlue";
=======
		[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Rescuing the hostage will greatly increase civilian reputation while failing the rescue will decrease civilian reputation.<br/><br/>Locate and extract the hostage.", LMO_MkrName,LMO_MkrText], "LMO: Hostage Rescue", "Meet"], objNull, 1, 3, false] call BIS_fnc_taskCreate;																						
		["_taskMisMO","meet"] call BIS_fnc_taskSetType;
		["LMOTask", ["Hostage Rescue", "\A3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];

		if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
				["LMOTaskOutcomeO", ["Hostage Rescue", "\A3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			} else {
				["LMOTask", ["Hostage Rescue", "\A3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			};

		LMO_MkrName setMarkerColor "ColorBlue";
		LMO_Mkr setMarkerColor "ColorBlue";
		
		if (LMO_Debug_Mkr) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position LMO_spawnBldg];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
		};
		
		//Checks whether hostage is in city
		_nearbyBuildings = nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, (LMO_objMkrRadRescue/2), false, true];
		//Increase escape radius if not in city
		if (count _nearbyBuildings < 10) then {_HRrad = LMO_objMkrRadRescue * 1.5};
>>>>>>> Stashed changes
		
		//Empties Variables
		_enyUnitHostages = [];
		_playerUnitHostages = [];
		_enyUnits = createGroup east;
		_hostages = createGroup civilian;
		_hostageTaker = objNull;
										
		//Spawn Hostages
		_hostages createUnit [
			(selectRandom civilians), //classname 
			getPos spawnBuilding,
			[],
			0,
			"NONE"
		];
		
		
		//Spawns Enemies
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos spawnBuilding,
				[],
				0,
				"NONE"
			];
			
			[_enyUnitsHolder] joinSilent _enyUnits;
			
		} forEach XEPKEY_SideOpsORBAT;
		
		
		[getPos spawnBuilding, Btypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;
		
		{
			_noMove = random 1;
			if (_noMove <= 0.3) then {
				_x disableAI "PATH";
			};
		}forEach units _enyUnits;

		//Surrenders hostage and moves to elevated enemies if possible
		_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
		_enyUnitsInside = _enyUnitsInside select {(getPosATL _x) select 2 > 3};
		{
		
			[_x, true] call ace_captives_fnc_setSurrendered;
			[_x, true, objNull] call ACE_captives_fnc_setHandcuffed;
			if (count _enyUnitsInside >= 1) then {
				
				_hostageTaker = selectRandom _enyUnitsInside;
				_hostageTaker disableAI "PATH";
				_hostagePos = getPosASL _hostageTaker;
				_hostagePosOffset = selectRandom [-0.5,0.5];
				_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), _hostagePos select 2];
			
			} else {
				_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
				if (count _enyUnitsInside > 0) then {
					_x setPosASL (getPosASL selectRandom _enyUnitsInside);
				} else {
					_x setPosASL (getPosASL selectRandom units _enyUnits);
				};
			};
			_x setDir random 360;
		}forEach (units _hostages);
	};

	//Eliminate HVT
	case 2:{
		
<<<<<<< Updated upstream
		[west, ["_taskMissionMO", "_taskMO"], [format ["Some guy needs to die at <marker name =%1>%2</marker>. Locate and extract kill the dude.", objMarkerName,objMarkerText], "MO: Eliminate HVT", "REGROUP_MARKER"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
		objMarkerName setMarkerColor "ColorOrange";
		objMarker setMarkerColor "ColorOrange";
=======
		[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["A high value target was reported to be within the vicinity nearby <marker name =%1>%2</marker>. Capturing HVT will provide intelligence and slightly reduce enemy readiness while killing the HVT will provide no intelligence while greatly reducing enemy readiness.<br/><br/>Locate and extract kill the high value target.", LMO_MkrName,LMO_MkrText], "LMO: Capture or Kill HVT", "Kill"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMisMO","Kill"] call BIS_fnc_taskSetType;
		["LMOTask", ["Kill or Capture HVT", "\A3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		diag_log "[LMO] HVT Task Made";

		LMO_MkrName setMarkerColor "ColorOrange";
		LMO_Mkr setMarkerColor "ColorOrange";
		
		if (LMO_Debug_Mkr) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position LMO_spawnBldg];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
		};
		
>>>>>>> Stashed changes
		_enyUnits = createGroup east;
		
		//Spawns Enemies
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos spawnBuilding,
				[],
				0,
				"NONE"
			];
			
			[_enyUnitsHolder] joinSilent _enyUnits;
			
		} forEach XEPKEY_SideOpsORBAT;
		
		[getPos spawnBuilding, Btypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;
		
		_hvt = selectRandom units _enyUnits;
		
		//Eliminiate HVT Parameters
		removeHeadgear _hvt;
		removeGoggles _hvt;
		_hvt addHeadGear selectRandom _hvtHeadgear;
		_hvt addGoggles selectRandom _hvtGoggles;
		
<<<<<<< Updated upstream
=======
		diag_log "[LMO] HVT assigned.";

		//HVT Custom Outfit
		[] call XEPKEY_fn_hvtOutfit;
		
		//Unequips NVGs if day
		if ((daytime <= 20) || (daytime >= 6)) then {_hvt unassignItem hmd _hvt};
		
		//Runner HVT Chance
		if (LMO_HVTallowRunner == true || LMO_HVTrunnerOnly == true) then {

			_hvtRunner = random 1;

			if (_hvtRunner < 0.5 || LMO_HVTrunnerOnly == true) then {
			
			diag_log "[LMO] HVT is a runner.";

				//HVT's group has a chance to start moving
				{
					_doMove = random 1;
					if (_doMove <= 0.3) then {
					_x enableAI "PATH";
					};
				}forEach units group _hvt;

				_hvtRunnerGrp = createGroup east;
				
				//HVT Runner
				[_hvt] joinSilent _hvtRunnerGrp;
				
				if (LMO_VCOM_On == true) then {
					_hvtRunnerGrp setVariable ["VCM_NOFLANK",true];
				};
				
				removeAllWeapons _hvt;

				//WaitUntil HVT is spooked
				[	
					{
						params ["_hvt"];
						_hvt call BIS_fnc_enemyDetected;
					},					
					{
						diag_log "[LMO] HVT is spooked, initializing runner code.";
						params ["_hvt"];
						_hvt enableAI "PATH";
						_hvt setVariable ["LMO_AngDeg",nil];

						
						//Checks whether armed west > east near HVT to surrender
						[
							{
								(_this select 0) params ["_hvt"];
								if (_hvt getVariable ["ace_captives_isSurrendering", true]) then {
									_hvt setBehaviour "CARELESS";
									_surInRngWest = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_friendly}) select {!(currentWeapon _x == "")};
									_surInRngEast = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_enemy}) select {!(currentWeapon _x == "")};
									if (count _surInRngWest > count _surInRngEast && (_hvt call BIS_fnc_enemyDetected)) exitWith {
										[_hvt, true] call ace_captives_fnc_setSurrendered;
										if (LMO_HVTDebug == true) then {diag_log "[LMO] HVT surrendered, exiting scope"};
										[_this select 1] call CBA_fnc_removePerFrameHandler;
									};
								};
							},
							1,
							[_hvt]
						] call CBA_fnc_addPerFrameHandler;
						
						//HVT escape from zone
						[
							{
								(_this select 0) params ["_hvt"];
								if (alive _hvt) then {
									_targetsList = [];
									_movePos = [];
									_targetsInRange = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSearchRng]) select {side _x == GRLIB_side_friendly}) select {!(currentWeapon _x == "")};
									_targetsList append _targetsInRange;
									_hvt setBehaviour "CARELESS";
									_angDeg = nil;
									_targetDir = 0;
									_targetGetDir = 0;

									{
										_targetGetDir = _hvt getDir _x;
										_targetDir = _targetDir + _targetGetDir;
									}forEach _targetsList;

									//HVT Run Direction
									_angDeg = _hvt getVariable "LMO_AngDeg";
									if (count _targetsInRange == 0 || _targetDir == 0) then {
										if (isNil "_angDeg") then {
											_angDeg = random 360;

											_hvt setVariable ["LMO_AngDeg",_angDeg];
											_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;
											group _hvt move _movePos;
											if (LMO_HVTDebug == true) then {
												diag_log format ["[LMO] No AngDeg Found. Random AngDeg: %1.",_angDeg];
											};
										} else {
											_angDeg = _hvt getVariable "LMO_AngDeg";

											_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;
											group _hvt move _movePos;
											if (LMO_HVTDebug == true) then {
												diag_log format ["[LMO] AngDeg Found: %1.",_angDeg];
											};
										};
									} else {	
										_angDeg = ((_targetDir/count _targetsInRange) + 180) % 360;
										_hvt setVariable ["LMO_AngDeg",_angDeg];
										if (LMO_HVTDebug == true) then {
											diag_log format ["[LMO] Armed enemy units in range, AngDeg made: %1",_angDeg];
										};
										_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;
										group _hvt move _movePos;
									};

									if (LMO_HVTDebug == true) then {
										diag_log format ["[LMO] HVT Running from %1 armed enemies. Run Dir: %2. Move Pos: %3.",count _targetsList,round (_hvt getVariable "LMO_AngDeg"),_movePos];
									};
								
									if (_hvt getVariable ["ace_captives_isSurrendering", false]) exitWith {
										if (LMO_HVTDebug == true) then {diag_log "[LMO] HVT surrendered, exiting scope."};
										[_this select 1] call CBA_fnc_removePerFrameHandler;
									};
								} else {
									[_this select 1] call CBA_fnc_removePerFrameHandler;
								};
							},
							40,
							[_hvt]
						] call CBA_fnc_addPerFrameHandler;
					},
					[_hvt]
				] call CBA_fnc_waitUntilAndExecute;
			};
		};
>>>>>>> Stashed changes
	};
	
	//Blow shit up
	case 3:{
						
		[west, ["_taskMissionMO", "_taskMO"], ["Destroy this thing", "MO: Destroy Cache", "objMarker"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
		objMarkerName setMarkerColor "ColorGreen";
		objMarker setMarkerColor "ColorGreen";
		
<<<<<<< Updated upstream
	};
};

while {activeMission == true} do {
	
	//Hostage Rescue Parameters
	if (_missionType == 1) then {
		//Checks if Player is within range of hostage to halt timer
		{
			_playerUnitHostages = (nearestObjects [_x, ["Man"], 10]) select {isPlayer _x};
			_enyUnitHostages = (nearestObjects [_x, ["Man"], 10]) select {!isPlayer _x} select {side _x == east};
		}forEach units _hostages;
		
		if ((count _playerUnitHostages > 0) && (count _enyUnitHostages == 0)) then {
				missionTimer = missionTimer - 0;
				missionTimerStr = [missionTimer, "MM:SS"] call BIS_fnc_secondsToString;
				objMarkerName setMarkerColor "ColorGrey";
				objMarker setMarkerColor "ColorGrey";
				objMarker setMarkerPos getPos spawnBuilding;
				objMarker setMarkerSize [objMarkerRadiusRescue,objMarkerRadiusRescue];
				objMarker setMarkerBrush "Solid";
		} else {
				objMarkerName setMarkerColor "ColorBlue";
				objMarker setMarkerColor "ColorBlue";
				objMarker setMarkerPos objMarkerPos;
				objMarker setMarkerSize [objMarkerRadius,objMarkerRadius];
				objMarker setMarkerBrush "FDiagonal";
				missionTimer = missionTimer - 1;
				missionTimerStr = [missionTimer, "MM:SS"] call BIS_fnc_secondsToString;
		};
		
	} else {
	
		missionTimer = missionTimer - 1;
		missionTimerStr = [missionTimer, "MM:SS"] call BIS_fnc_secondsToString;
	
	};
	
	//hintSilent format ["Time Remaining: %1", missionTimerStr];
	
	objMarkerName setMarkerText format [" %1 [%2]",objMarkerText, missionTimerStr];
	
	if (missionTimer == 0) then {
		_missionFailed = true;
	};
	
	//----Win Lose Conditions----//
	
	//Hostage Rescue Lose Conditions
	if (_missionType == 1 && (({alive _x} count units _hostages == 0) || missionTimer == 0)) then {
	
		_missionFailed = true;
		{
			_x setdamage 1;
		}forEach units _hostages;
		
		{
			_x enableAI "PATH";
		}forEach units _enyUnits;
		
		_enyUnitPlayers = [];
		
		while {{alive _x} count units _enyUnits > 0} do {
			
			{
				_enyUnitPlayers = (nearestObjects [_x, ["Man"], (Bradius * 0.8)]) select {isPlayer _x};
			}forEach units _enyUnits;
			
			if (count _enyUnitPlayers == 0) exitWith {
				{
					deleteVehicle _x;
				}forEach units _enyUnits;
			deleteGroup _enyUnits;
			deleteGroup _hostages;
			};
			sleep 5;
		};	
	};

	//Hostage Rescue Win Conditions
	if (_missionType == 1 && ({_x distance2D position spawnBuilding > objMarkerRadiusRescue} count units _hostages >= 1) && missionTimer > 0) then {
		
		_missionSuccess = true;
		{
			deleteVehicle _x;
		}forEach units _enyUnits;
		{
			deleteVehicle _x;
		}forEach units _hostages;
		deleteGroup _enyUnits;
		deleteGroup _hostages;
		
	};



	//Eliminate HVT Lose Conditions
	if (_missionType == 2 && alive _hvt && (missionTimer == 0)) then {
	
		_missionFailed = true;
		deleteVehicle _hvt;
		
		while {{alive _x} count units _enyUnits > 0} do {
			
			{
				_enyUnitPlayers = (nearestObjects [_x, ["Man"], (Bradius * 0.8)]) select {isPlayer _x};
			}forEach units _enyUnits;
			
			if (count _enyUnitPlayers == 0) exitWith {
				_missionFailed = true;
				{
					deleteVehicle _x;
				}forEach units _enyUnits;
			deleteGroup _enyUnits;
			};
			sleep 5;
		};
	};
	
	//Eliminiate HVT Win Conditions
	if (_missionType == 2 && !alive _hvt && (missionTimer > 0)) then {
	
		_missionSuccess = true;
		
		//scheduled environment
		[_enyUnits] spawn {
			params ["_enyUnits"];
			_enyUnits = _this select 0;
			_enyUnitPlayers = [];
			while {{alive _x} count units _enyUnits > 0} do {
			
			{
				_enyUnitPlayers = (nearestObjects [_x, ["Man"], (Bradius * 0.8)]) select {isPlayer _x};
			}forEach units _enyUnits;
			
			//hint format ["%1", units _enyUnits];
			if (count _enyUnitPlayers == 0) exitWith {
				{
					deleteVehicle _x;
				}forEach units _enyUnits;
				deleteGroup _enyUnits;
			};
			sleep 5;
			};
		};
	};
	
	
	if (_missionFailed == true) exitWith {
	
		["_taskMO", "FAILED"] call BIS_fnc_taskSetState;
		deleteMarker objMarker;
		deleteMarker objMarkerName;
		//deleteMarker _objMarkerName2;
		activeMission = false;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMissionMO"] call BIS_fnc_deleteTask;
					
	};
	
	if (_missionSuccess == true) exitWith {
	
		["_taskMO", "SUCCEEDED"] call BIS_fnc_taskSetState;
		deleteMarker objMarker;
		deleteMarker objMarkerName;
		//deleteMarker _objMarkerName2;
		activeMission = false;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMissionMO"] call BIS_fnc_deleteTask;
					
	};
	
sleep 1;
};
=======
		[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["Reconnaissance has identified enemy forces moving a supply cache around <marker name =%1>%2</marker>. The supply cache appears to be a stack of wooden boxes covered with a net. Secured supples will be air lifted to the nearest FOB while destroying the cache will reduce enemy readiness.<br/><br/>Locate and destroy or secure the supply cache.", LMO_MkrName,LMO_MkrText], "LMO: Destroy or Secure Cache", "Box"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMisMO","Destroy"] call BIS_fnc_taskSetType;
		["LMOTask", ["Destroy or Secure Cache", "a3\missions_f_oldman\data\img\holdactions\holdaction_box_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		LMO_MkrName setMarkerColor "ColorGreen";
		LMO_Mkr setMarkerColor "ColorGreen";

		_cSpawnPos = getPosATL LMO_spawnBldg findEmptyPosition [0, 40, _cModel];
		_cache = objNull;
		
		//Spawn Cache
		if (count _cSpawnPos > 0) then {
			_cache = createVehicle [_cModel, _cSpawnPos, [], 0, "CAN_COLLIDE"];
			if (LMO_Debug) then {diag_log format ["[LMO] Cache created at %1", getPos _cache]};
		} else {
			_cache = createVehicle [getPos LMO_spawnBldg, _cModel, [], 0, "CAN_COLLIDE"];
			if (LMO_Debug) then {diag_log format ["[LMO] No suitable cache spot found. Creating cache in target building at %1", getPos _cache]};
		};

		//Empty contents of Cache
		if (LMO_CacheEmpty == true) then {
			clearItemCargoGlobal _cache;
			clearWeaponCargoGlobal _cache;
			clearMagazineCargoGlobal _cache;
			if (LMO_Debug) then {diag_log "[LMO] Cache cargo emptied."};
		};
		
		//Add explosives to cache
		if (LMO_CacheItems == true) then {
			{
				_cache addItemCargoGlobal [(_x select 0), (_x select 1)];
			} forEach LMO_CacheItemArray;
			if (LMO_Debug) then {diag_log "[LMO] Cache items added."};
		};
		_cache setVariable ["LMO_CacheSecure", false, true];
		
		//Debug marker for cache location
		if (LMO_Debug_Mkr) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position _cache];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
		};
		
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
					if (LMO_Debug) then {diag_log "[LMO] Cache secured, cancelling action and deleting holdAction."};
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
				if (LMO_Debug) then {
					diag_log format ["[LMO] CacheSecure: %1", _target getVariable "LMO_CacheSecure"];
				};
				[_target,_actionId] call BIS_fnc_holdActionRemove;
			},
			{_caller switchMove ""},
			[_cache],
			5,
			2000,
			true,
			false
		] remoteExec ["BIS_fnc_holdActionAdd", 0, _cache];
		
		_cache addEventHandler ["Explosion", {
			params ["_vehicle", "_damage"];
			if (_damage > 1) then {
				_cAttached = attachedObjects _vehicle select {typeOf _x == "PortableHelipadLight_01_red_F"};
				if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
				if (LMO_Debug) then {
					diag_log format ["[LMO] Cache destroyed, CacheSecure variable: %1", _vehicle getVariable "LMO_CacheSecure"];
				};
				_vehicle setDamage 1;
				
			};
			if (LMO_Debug) then {diag_log format ["[LMO] Cache Damaged: %1", _damage]};
		}];		
	};
};

//Mission Outcome Checker
[
	{
		(_this select 0) params ["_missionType","_hostageGrp","_hvt","_hvtRunner","_HRrad","_cache","_hostage","_enyUnits","_taskMO","_taskMisMO","_missionState"];
		if (LMO_active == true) then {	
			//Hostage Pause Timer Radius
			_hPauseRng = 10;

			//Hostage Rescue Parameters
			if (_missionType == 1) then {
				//Checks if Player is within range of hostage to halt timer
				{
					_playerUnitHostages = (nearestObjects [_x, ["Man","LandVehicle"], _hPauseRng]) select {isPlayer _x};
					_enyUnitHostages = (nearestObjects [_x, ["Man","LandVehicle"], _hPauseRng]) select {!isPlayer _x} select {side _x == GRLIB_side_enemy};
				}forEach units _hostageGrp;
				
				if ((count _playerUnitHostages > 0) && (count _enyUnitHostages == 0)) then {

					[0,"ColorGrey",LMO_spawnBldg,_HRrad,false,"Solid"] call XEPKEY_fn_mTimerAdjust;
				} else {

					[1,"ColorBlue",LMO_MkrPos,LMO_objMkrRad,false,"FDiagonal"] call XEPKEY_fn_mTimerAdjust;
				};
				
			} else {
				if (_missionType == 2) then {
					
					//Checks if Player is within range of HVT to halt timer
					_playerUnitsHVT = (nearestObjects [_hvt, ["Man","LandVehicle"], _hPauseRng]) select {isPlayer _x};
					
					if ((count _playerUnitsHVT > 0) && (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false])) then {

							[0,"ColorGrey",position _hvt,_hPauseRng,true,"Solid"] call XEPKEY_fn_mTimerAdjust;
					} else {

							[1,"ColorOrange",LMO_MkrPos,LMO_objMkrRad,true,"FDiagonal"] call XEPKEY_fn_mTimerAdjust;
					};
					
				} else {
					
					//Checks if cache is secured to halt timer
					if (_missionType == 3 && (_cache getVariable ["LMO_CacheSecure", true])) then {

						//[0,"ColorGrey",position _cache,LMO_FultonRng,true,"Solid"] call XEPKEY_fn_mTimerAdjust;
						LMO_MkrName setMarkerColor "ColorGrey";
						LMO_Mkr setMarkerColor "ColorGrey";
						LMO_Mkr setMarkerPos position _cache;
						LMO_MkrName setMarkerPos position _cache;
						LMO_Mkr setMarkerSize [LMO_CacheDefDist,LMO_CacheDefDist];
						LMO_Mkr setMarkerBrush "Solid";
						_cNearTimer = ((nearestObjects [_cache, ["Man", "LandVehicle"], LMO_CacheDefDist]) select {side _x == GRLIB_side_enemy}) select {!(_x getVariable ["ACE_isUnconscious", false])};
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
				};
				
				if (alive _hostage) then {_hostage setdamage 1};

				[
					{
						(_this select 0) params ["_enyUnits","_hostageGrp"];
						_enyUnitPlayers = [];
						if ({alive _x} count units _enyUnits > 0) then {
							
							{
								_enyUnitPlayers = (nearestObjects [_x, ["Man","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
							}forEach units _enyUnits;
							
							if (count _enyUnitPlayers == 0) exitWith {
								{
									deleteVehicle _x;
								}forEach units _enyUnits;
								deleteGroup _enyUnits;
								deleteGroup _hostageGrp;
								[_this select 1] call CBA_fnc_removePerFrameHandler;
							};
						} else {
							[_this select 1] call CBA_fnc_removePerFrameHandler;
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

				diag_log "[LMO] Hostage has been rescued.";

				//Increase Civilian reputation and intelligence
				if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {

					_finalReward = round (LMO_HR_Win_CivRep * LMO_TST_Reward);
					[_finalReward] call F_cr_changeCR;
					KP_liberation_civ_rep = KP_liberation_civ_rep + (round (LMO_HR_Win_CivRep * LMO_TST_Reward));
					resources_intel = resources_intel + (round (LMO_HR_Win_Intel * LMO_TST_Reward));
				} else {

					KP_liberation_civ_rep = KP_liberation_civ_rep + LMO_HR_Win_CivRep;
					[LMO_HR_Win_CivRep] call F_cr_changeCR;
					resources_intel = resources_intel + LMO_HR_Win_Intel;
				};

				{
					deleteVehicle _x;
				}forEach units _enyUnits;
				{
					deleteVehicle _x;
				}forEach units _hostageGrp;
				deleteVehicle _hostage;
				deleteGroup _enyUnits;
				deleteGroup _hostageGrp;
				
			};



			//Eliminate HVT Lose Conditions	
			if (_missionType == 2) then {
				
				_hvtEscChase = (_hvt nearEntities [["Man","LandVehicle"],LMO_HVTchaseRng]) select {side _x == GRLIB_side_friendly};
				
				//if HVT is alive, mission timer expired, or not handcuffed and exited escape zone
				if (alive _hvt && (LMO_mTimer == 0 || (!(_hvt getVariable ["ace_captives_isHandcuffed", false]) && ((_hvt distance2D position LMO_spawnBldg > LMO_HVTescRng) && (count _hvtEscChase == 0))))) then {
				
					["LMOTaskOutcomeR", ["HVT has escaped", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					_missionState = 2;
					
					diag_log "[LMO] HVT has escaped.";

					//Lose Intel if HVT escapes
					if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select 2) == true)) then {
						resources_intel = resources_intel - LMO_HVT_Lose_Intel;
						if (resources_intel < 0) then {resources_intel = 0};
					};

					if (_hvtRunner < 0.5 || LMO_HVTrunnerOnly == true) then {
						deleteGroup _hvtRunnerGrp;
						_hvt setVariable ["LMO_AngDeg",nil];
					};
					
					deleteVehicle _hvt;

					[
						{
							(_this select 0) params ["_enyUnits"];
							_enyUnitPlayers = [];
							if ({alive _x} count units _enyUnits > 0) then {
								{
									_enyUnitPlayers = (nearestObjects [_x, ["Man","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
								}forEach units _enyUnits;
							} else {
								{deleteVehicle _x}forEach units _enyUnits;
								deleteGroup _enyUnits;
								[_this select 1] call CBA_fnc_removePerFrameHandler;
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
					};

					switch (alive _hvt) do {
						case true: {
							//noweapon, alive
							if (primaryWeapon _hvt == "") then {
								if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
									resources_intel = resources_intel + (round (LMO_HVT_Win_intelUnarmed * LMO_TST_Reward));
									combat_readiness = combat_readiness - (round (LMO_HVT_Win_CapAlert * LMO_TST_Reward));
								} else {
									resources_intel = resources_intel + LMO_HVT_Win_intelUnarmed;
									combat_readiness = combat_readiness - LMO_HVT_Win_CapAlert;
								};
							} else { //hasweapon, alive
								if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
									resources_intel = resources_intel + (round (LMO_HVT_Win_intelArmed * LMO_TST_Reward));
									combat_readiness = combat_readiness - (round (LMO_HVT_Win_CapAlert * LMO_TST_Reward));
								} else {
									resources_intel = resources_intel + LMO_HVT_Win_intelArmed;
									combat_readiness = combat_readiness - LMO_HVT_Win_CapAlert;
								};
							};

							["LMOTaskOutcomeG", ["HVT has been captured", "\z\ace\addons\captives\ui\handcuff_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							deleteVehicle _hvt;
							diag_log "[LMO] HVT has been captured.";
						};
						case false: {
							if (!(primaryWeapon _hvt == "")) then {
								if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
									combat_readiness = combat_readiness - (round (LMO_HVT_Win_KillAlert * LMO_TST_Reward));
								} else {
									combat_readiness = combat_readiness - LMO_HVT_Win_KillAlert;
								};
							};
							["LMOTaskOutcomeG", ["HVT has been neutralized", "\A3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
							diag_log "[LMO] HVT has been neutralized.";
						};
					};

					_missionState = 1;
					

					[
						{
							(_this select 0) params ["_enyUnits"];
							_enyUnitPlayers = [];
							if ({alive _x} count units _enyUnits > 0) then {
								{
									_enyUnitPlayers = (nearestObjects [_x, ["Man","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
								}forEach units _enyUnits;
							} else {
								{deleteVehicle _x}forEach units _enyUnits;
								deleteGroup _enyUnits;
								[_this select 1] call CBA_fnc_removePerFrameHandler;
							};
						},
						5,
						[_enyUnits]
					] call CBA_fnc_addPerFrameHandler;
				};
			};
			
			//Cache Win Conditions
			if (_missionType == 3 && LMO_mTimer > 0) then {
				
				//If cache destroyed and NOT secured
				if ((!alive _cache) && ((_cSecured != true))) then {
					_missionState = 1;
					diag_log "[LMO] Cache was destroyed.";
					["LMOTaskOutcomeG", ["Cache has been destroyed", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					if (LMO_TST == true && LMO_TimeSenRNG <= LMO_TSTchance) then {
						combat_readiness = combat_readiness - (LMO_Cache_Win_Alert * LMO_TST_Reward);
					} else {
						combat_readiness = combat_readiness - LMO_Cache_Win_Alert;
					};
				};
				
				_cSecured = missionNamespace getVariable ["LMO_CacheTagged",false];
				//diag_log format ["[LMO] cSecured missionNamespace: %1", _cSecured];

				//if (!_cSecured) then {diag_log "[LMO] cSecured is false"};

				//If Secured Cache
				if ((alive _cache) && (_cache getVariable ["LMO_CacheSecure", true] && (!_cSecured))) then {
					["LMOTaskOutcome", ["Cache has been located", "a3\ui_f\data\gui\rsccommon\rscbuttonsearch\search_start_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					
					//Marks cache as tagged in missionNameSpace to prevent loop executions
					//_cSecured = missionNamespace getVariable "LMO_CacheTagged";
					//if (isNil "_cSecured" || !(_cSecured)) then {
						missionNamespace setVariable ["LMO_CacheTagged", true];
						if (LMO_Debug) then {diag_log format ["[LMO] missionnameSpace _cSecured: %1. qrfCache and cacheFulton initializing.",missionNamespace getVariable "LMO_CacheTagged"]};
					
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
								[_cache] call XEPKEY_fn_qrfCache;
								[_cache,"_taskMO","_taskMisMO"] call XEPKEY_fn_cacheFulton;
							},
							[_cache,"_taskMO","_taskMisMO"],
							1
						] call CBA_fnc_waitAndExecute;
					//};
				};
			};
			
			//Cache Lose Conditions
			if (_missionType == 3 && LMO_mTimer == 0) then {
				//If Timer expires
				if (alive _cache && !(_cache getVariable ["LMO_CacheSecure", true])) then {
					_missionState = 2;
					missionNamespace setVariable ["LMO_CacheTagged", nil];
					if (((LMO_Penalties select 0) == true) && ((LMO_Penalties select 1) == true)) then {
						combat_readiness = combat_readiness + LMO_Cache_Lose_Alert;
					};

					["LMOTaskOutcomeR", ["Cache has been moved by the enemy", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					_cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
					if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
					deleteVehicle _cache;
					if (LMO_Debug) then {diag_log "[LMO] Cache deleted."};
				};
			};
			
			//Ends Mission
			if (_missionState != 0) exitWith {
				[_missionState,"_taskMO","_taskMisMO"] call XEPKEY_fn_taskState;
				[_this select 1] call CBA_fnc_removePerFrameHandler;
				diag_log "[LMO] Mission Finished, exiting PFH."
			};
		} else {
			[_this select 1] call CBA_fnc_removePerFrameHandler;
		};
	},
	1,
	[_missionType,_hostageGrp,_hvt,_hvtRunner,_HRrad,_cache,_hostage,_enyUnits,"_taskMO","_taskMisMO",_missionState]
] call CBA_fnc_addPerFrameHandler;
>>>>>>> Stashed changes
