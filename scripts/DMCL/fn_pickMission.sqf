//Variable init
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
_cSecured = false;
_missionType = 0;
_sqdOrbat = [];
_sqdSize = 0;

//Randomizes LMO Mission Type
if (LMO_Debug == true && LMO_mType != 0) then {
	_missionType = LMO_mType;
} else {
	_missionType = [1,3] call BIS_fnc_randomInt;
};

//Hostage Pause Timer Radius
_hPauseRng = 10;

//Model used for Cache OBJ
_cModel = "Box_FIA_Wps_F";


[GRLIB_side_friendly, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "LMO_Mkr"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
["_taskMO","Box"] call BIS_fnc_taskSetType;


//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		
		//Creates Task
		[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Rescuing the hostage will greatly increase civilian reputation while failing the rescue will decrease civilian reputation.<br/><br/>Locate and extract the hostage.", LMO_MkrName,LMO_MkrText], "LMO: Hostage Rescue", "Meet"], objNull, 1, 3, false] call BIS_fnc_taskCreate;																						
		["_taskMisMO","meet"] call BIS_fnc_taskSetType;
		["LMOTask", ["Hostage Rescue", "\A3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];

		LMO_MkrName setMarkerColor "ColorBlue";
		LMO_Mkr setMarkerColor "ColorBlue";
		
		if (LMO_Debug == true) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position LMO_spawnBldg];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
		};
		
		//Checks whether hostage is in city
		_nearbyBuildings = nearestTerrainObjects [LMO_spawnBldg, LMO_bTypes, (LMO_objMkrRadRescue/2), false, true];
		//Increase escape radius if not in city
		if (count _nearbyBuildings < 10) then {_HRrad = LMO_objMkrRadRescue * 1.5};
		
		//Empties Variables
		_enyUnitHostages = [];
		_playerUnitHostages = [];
		_enyUnits = createGroup east;
		_hostageGrp = createGroup civilian;
		_hostage = objNull;
		_hTaker = objNull;
										
		//Spawn Hostages
		_hostageGrp createUnit [
			(selectRandom civilians), //classname 
			getPos LMO_spawnBldg,
			[],
			0,
			"NONE"
		];
		
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
		
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos LMO_spawnBldg,
				[],
				0,
				"NONE"
			];
			
			[_enyUnitsHolder] joinSilent _enyUnits;

		} forEach _sqdOrbat;
		
		//[(units _enyUnits), getPos LMO_spawnBldg, 30, 1, true] call zen_ai_fnc_garrison;
		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;

		call XEPKEY_fn_removeThrowables;

		//Prevents random glitch that shoots AI into the air
		{
			if (((getPosATL _x) select 2) > 10) then {
				_safePosUnit = (units _enyUnits) select {(getPosATL _x) select 2 < 5};
				if (count _safePosUnit > 0) then {
					_x setVelocity [0,0,0];
					_x setPosATL getPosATL (selectRandom _safePosUnit);
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
		
		//Spawns Hostage
		[_enyUnits,_hostageGrp] call XEPKEY_fn_spawnHostage;
	};
	
	//Eliminate HVT
	case 2:{
		
		[GRLIB_side_friendly, ["_taskMisMO", "_taskMO"], [format ["A high value target was reported to be within the vicinity nearby <marker name =%1>%2</marker>. Capturing HVT will provide intelligence and slightly reduce enemy readiness while killing the HVT will provide no intelligence while greatly reducing enemy readiness.<br/><br/>Locate and extract kill the high value target.", LMO_MkrName,LMO_MkrText], "LMO: Capture or Kill HVT", "Kill"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMisMO","Kill"] call BIS_fnc_taskSetType;
		["LMOTask", ["Kill or Capture HVT", "\A3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		LMO_MkrName setMarkerColor "ColorOrange";
		LMO_Mkr setMarkerColor "ColorOrange";
		
		if (LMO_Debug == true) then {
			LMO_MkrDebug = createMarker ["LMO_MkrDebug", position LMO_spawnBldg];
			LMO_MkrDebug setMarkerShape "ICON";
			LMO_MkrDebug setMarkerSize [1,1];
			LMO_MkrDebug setMarkerType "mil_dot";
		};
		
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
		
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos LMO_spawnBldg,
				[],0,"NONE"
			];

			[_enyUnitsHolder] joinSilent _enyUnits;
		} forEach _sqdOrbat;
		
		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;

		call XEPKEY_fn_removeThrowables;

		//Prevents random glitch that shoots AI into the air
		{
			if (((getPosATL _x) select 2) > 10) then {
				_safePosUnit = (units _enyUnits) select {(getPosATL _x) select 2 < 5};
				if (count _safePosUnit > 0) then {
					_x setVelocity [0,0,0];
					_x setPosATL getPosATL (selectRandom _safePosUnit);
				};
			};
		}forEach units _enyUnits;

		{
			_noMove = random 1;
			
			_x disableAI "RADIOPROTOCOL";

			if (_noMove <= 0.3) then {
				_x enableAI "PATH";
			};

		}forEach units _enyUnits;
		
		//VCOM will stop the AI squad from responding to calls for backup.
		if (LMO_VCOM_On == true) then {
			_enyUnits setVariable ["VCM_NORESCUE",true];
			_enyUnits setVariable ["VCM_DisableForm",true];
		};

		_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
		_enyUnitsInside = _enyUnitsInside select {(getPosATL _x) select 2 > 3};
		
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
		
		//HVT Custom Outfit
		call XEPKEY_fn_hvtOutfit;
		
		//Unequips NVGs if day
		if ((daytime <= 20) || (daytime >= 6)) then {_hvt unassignItem hmd _hvt};
		
		//Runner HVT Chance
		if (LMO_allowRunnerHVT == true || LMO_RunnerOnlyHVT == true) then {

			_hvtRunner = random 1;

			if (_hvtRunner < 0.5 || LMO_RunnerOnlyHVT == true) then {
			
				//HVT's group has a chance to start moving
				{
					_doMove = random 1;
					if (_doMove <= 0.3) then {
					_x enableAI "PATH";
					};
				}forEach units group _hvt;

				_hvtRunnerGrp = createGroup east;
				
				//Schedued Environment
				[_hvt, _hvtRunnerGrp] spawn {
					params ["_hvt","_hvtRunnerGrp"];
					[_hvt] joinSilent _hvtRunnerGrp;
					
					if (LMO_VCOM_On == true) then {
						_hvtRunnerGrp setVariable ["VCM_NOFLANK",true];
					};

					_hvtDir = getDir _hvt;
					_targetDir = 0;
					_targetsList = [];
					_targetGetDir = 0;
					_targetsInRange = [];
					//_angDeg = 0;
					
					removeAllWeapons _hvt;
					
					[_hvt] spawn {
						params ["_hvt"];
						_hvt setBehaviour "CARELESS";
						sleep 2;
					};
					
					//HVT stays put until alerted
					waitUntil {sleep 1; _hvt call BIS_fnc_enemyDetected};
					_hvt enableAI "PATH";
					_hvt setVariable ["LMO_AngDeg",nil];

					
					//Checks whether armed west > east near HVT to surrender
					[_hvt] spawn {
						params ["_hvt"];
						while {_hvt getVariable ["ace_captives_isSurrendering", true]} do {
							
							_surInRngWest = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_friendly}) select {!(currentWeapon _x == "")};
							_surInRngEast = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_enemy}) select {!(currentWeapon _x == "")};
							if (count _surInRngWest > count _surInRngEast && (_hvt call BIS_fnc_enemyDetected)) exitWith {
								[_hvt, true] call ace_captives_fnc_setSurrendered;
								if (LMO_HVTDebug == true) then {systemChat "LMO: HVT surrendered, exiting scope"};
							};
							sleep 1;
						};
					};
					
					//HVT escape from zone
					while {alive _hvt} do {
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
									systemChat format ["LMO: No AngDeg Found. Random AngDeg: %1.",_angDeg];
								};
							} else {
								_angDeg = _hvt getVariable "LMO_AngDeg";

								_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;
								group _hvt move _movePos;
								if (LMO_HVTDebug == true) then {
									systemChat format ["LMO: AngDeg Found: %1.",_angDeg];
								};
							};
						} else {	
							_angDeg = ((_targetDir/count _targetsInRange) + 180) % 360;
							_hvt setVariable ["LMO_AngDeg",_angDeg];
							if (LMO_HVTDebug == true) then {
								systemChat format ["LMO: Armed enemy units in range, AngDeg made: %1",_angDeg];
							};
							_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;
							group _hvt move _movePos;
						};

						if (LMO_HVTDebug == true) then {
							systemChat format ["LMO: HVT Running from %1 armed enemies. Run Dir: %2. Move Pos: %3.",count _targetsList,round (_hvt getVariable "LMO_AngDeg"),_movePos];
						};
					
						if (_hvt getVariable ["ace_captives_isSurrendering", false]) exitWith {
							if (LMO_HVTDebug == true) then {systemChat "LMO: HVT surrendered, exiting scope."};
						};
						sleep 40;
					};
				};
			};
		};
	};
	
	//Locate Cache
	case 3:{
		
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
			if (LMO_Debug == true) then {systemChat format ["LMO: Cache created at %1", getPos _cache]};
		} else {
			_cache = createVehicle [getPos LMO_spawnBldg, _cModel, [], 0, "CAN_COLLIDE"];
			if (LMO_Debug == true) then {systemChat format ["LMO: No suitable cache spot found. Creating cache in target building at %1", getPos _cache]};
		};

		//Empty contents of Cache
		if (LMO_CacheEmpty == true) then {
			clearItemCargoGlobal _cache;
			clearWeaponCargoGlobal _cache;
			clearMagazineCargoGlobal _cache;
			if (LMO_Debug == true) then {systemChat "LMO: Cache cargo emptied."};
		};
		
		//Add explosives to cache
		if (LMO_CacheItems == true) then {
			{
				_cache addItemCargoGlobal [(_x select 0), (_x select 1)];
			} forEach LMO_CacheItemArray;
			if (LMO_Debug == true) then {systemChat "LMO: Cache items added."};
		};
		_cache setVariable ["LMO_CacheSecure", false, true];
		
		//Debug marker for cache location
		if (LMO_Debug == true) then {
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
			"(_this distance _target < 3) && (alive _target)",
			"(_caller distance _target < 3) && (alive _target)",
			{
				_caller playMoveNow "Acts_carFixingWheel";
				playSound3D ["a3\sounds_f\characters\stances\rifle_to_launcher.wss", _target];
			},
			{
				if (_target getVariable ["LMO_CacheSecure",true]) then {
					_caller switchMove "";
					[_target,_actionId] call BIS_fnc_holdActionRemove;
					if (LMO_Debug == true) then {systemChat "LMO: Cache secured, cancelling action and deleting holdAction."};
				};
			},
			{
				_caller switchMove "";
				
				_target setVariable ["LMO_CacheSecure", true, true];
				_cStrobe = "PortableHelipadLight_01_red_F" createVehicle getPos _target;
				_cStrobe attachTo [_target, [0,0.2,-0.7]];
				[_target] spawn {
					params ["_target"];
					playSound3D ["a3\sounds_f\vehicles\soft\suv_01\suv_01_door.wss", _target];
					sleep 0.5;
					playSound3D ["a3\sounds_f\sfx\beep_target.wss", _target];
				};
				if (LMO_Debug == true) then {
					systemChat format ["LMO: CacheSecure: %1", _target getVariable "LMO_CacheSecure"];
				};
				
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
				if (LMO_Debug == true) then {
					systemChat format ["LMO: Cache destroyed, CacheSecure variable: %1", _vehicle getVariable "LMO_CacheSecure"];
				};
				_vehicle setDamage 1;
				
			};
			if (LMO_Debug == true) then {systemChat format ["LMO: Cache Damaged: %1", _damage]};
		}];		
	};
};

while {LMO_active == true} do {
	
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

				[0,"ColorGrey",position _cache,LMO_FultonRng,true,"Solid"] call XEPKEY_fn_mTimerAdjust;
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
		["LMOTaskOutcome", ["Hostage was killed", "\A3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
	
		_missionState = 2;
		
		{_x setdamage 1} forEach units _hostageGrp;
		{_x enableAI "PATH"} forEach units _enyUnits;
		
		if (LMO_Penalties == true) then {
		//Deduct Civilian reputation as defined in kp_liberation_config.sqf
		KP_liberation_civ_rep = KP_liberation_civ_rep - KP_liberation_cr_kill_penalty;
		};

		_enyUnitPlayers = [];
		if (alive _hostage) then {_hostage setdamage 1};
		[_enyUnits, _hostageGrp] spawn {
			params ["_enyUnits","_hostageGrp"];
			_enyUnitPlayers = [];
			while {{alive _x} count units _enyUnits > 0} do {
				{
					_enyUnitPlayers = (nearestObjects [_x, ["Man","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
				}forEach units _enyUnits;
				
				if (count _enyUnitPlayers == 0) exitWith {
					{
						deleteVehicle _x;
					}forEach units _enyUnits;
				deleteGroup _enyUnits;
				deleteGroup _hostageGrp;
				};
				sleep 5;
			};
		};
	};

	//Hostage Rescue Win Conditions
	if (_missionType == 1 && (_hostage distance2D position LMO_spawnBldg > _HRrad) && alive _hostage && LMO_mTimer > 0) then {
		
		["LMOTaskOutcome", ["Hostage secured", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		_missionState = 1;

		//Increase Civilian reputation and intelligence 
		KP_liberation_civ_rep = KP_liberation_civ_rep + LMO_HR_Win_CivRep;
		resources_intel = resources_intel + LMO_HR_Win_Intel;

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
		
		_hvtEscChase = (_hvt nearEntities [["Man","LandVehicle"],LMO_hvtChaseRng]) select {side _x == GRLIB_side_friendly};
		
		//if HVT is alive, mission timer expired, or not handcuffed and exited escape zone
		if (alive _hvt && (LMO_mTimer == 0 || (!(_hvt getVariable ["ace_captives_isHandcuffed", false]) && ((_hvt distance2D position LMO_spawnBldg > LMO_HVTescRng) && (count _hvtEscChase == 0))))) then {
		
			["LMOTaskOutcome", ["HVT has escaped", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_missionState = 2;
			
			if (_hvtRunner < 0.5 || LMO_RunnerOnlyHVT == true) then {
				deleteGroup _hvtRunnerGrp;
				_hvt setVariable ["LMO_AngDeg",nil];
			};
			
			deleteVehicle _hvt;
					
			[_enyUnits] spawn {
				params ["_enyUnits"];
				_enyUnitPlayers = [];
				while {{alive _x} count units _enyUnits > 0} do {
					
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
					}forEach units _enyUnits;
					
					if (count _enyUnitPlayers == 0) exitWith {
						{deleteVehicle _x}forEach units _enyUnits;
						deleteGroup _enyUnits;
					};
					sleep 5;
				};
			};
		};
	};
	
	//Eliminiate HVT Win Conditions
	if (_missionType == 2) then {
		
		//if HVT is alive, Mission Timer not expired, HVT has exited escape zone, is surrendered or handcuffed
		//OR
		//if HVT is dead, mission timer not expired
		if ((alive _hvt && LMO_mTimer > 0 && (_hvt distance2D position LMO_spawnBldg > LMO_bRadius * 0.8) && (_hvt getVariable ["ace_captives_isHandcuffed", false])) || (!alive _hvt && (LMO_mTimer > 0))) then {
			
			if (_hvtRunner < 0.5 || LMO_RunnerOnlyHVT == true) then {
				deleteGroup _hvtRunnerGrp;
				_hvt setVariable ["LMO_AngDeg",nil];
			};

			switch (alive _hvt) do {
				case true: {
					//noweapon, alive
					if (primaryWeapon _hvt == "") then {
						resources_intel = resources_intel + LMO_HVT_Win_intelUnarmed;
						combat_readiness = combat_readiness - LMO_HVT_Win_CapAlert;
					} else { //hasweapon, alive
						resources_intel = resources_intel + LMO_HVT_Win_intelArmed;
						combat_readiness = combat_readiness - LMO_HVT_Win_CapAlert;
					};
					["LMOTaskOutcome", ["HVT has been captured", "\z\ace\addons\captives\ui\handcuff_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					deleteVehicle _hvt;
				};
				case false: {
					if (!(primaryWeapon _hvt == "")) then {combat_readiness = combat_readiness - LMO_HVT_Win_KillAlert};
					["LMOTaskOutcome", ["HVT has been neutralized", "\A3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
				};

			};
			
			_missionState = 1;
			
			[_enyUnits] spawn {
				params ["_enyUnits"];
				_enyUnitPlayers = [];
				while {{alive _x} count units _enyUnits > 0} do {
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man","LandVehicle"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
					}forEach units _enyUnits;
					
					if (count _enyUnitPlayers == 0) exitWith {
						{deleteVehicle _x}forEach units _enyUnits;
						deleteGroup _enyUnits;
					};
					sleep 5;
				};
			};
		};
	};
	
	//Cache Win Conditions
	if (_missionType == 3 && LMO_mTimer > 0) then {
		
		//If cache destroyed and NOT secured
		if (!alive _cache && _cSecured != true) then {
			_missionState = 1;
			["LMOTaskOutcome", ["Cache has been destroyed", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		};
		
		//If Secured Cache
		if (alive _cache && (_cache getVariable ["LMO_CacheSecure", true]) && _cSecured != true) then {
			["LMOTaskOutcome", ["Cache has been located", "a3\ui_f\data\gui\rsccommon\rscbuttonsearch\search_start_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			
			//Marks cache as tagged in missionNameSpace to prevent loop executions
			_cSecured = missionNamespace getVariable "LMO_CacheTagged";
			if (isNil "_cSecured") then {
				_cSecured = true;
				missionNamespace setVariable ["LMO_CacheTagged", _cSecured];
				if (LMO_Debug == true) then {systemChat format ["LMO: missionnameSpace _cSecured: %1",missionNamespace getVariable "LMO_CacheTagged"]};
			};
			sleep 1;
			
			//Checks if players are no longer nearby cache, then exitsWith fulton script
			[_cache] call XEPKEY_fn_cacheFulton;
		};
	};
	
	//Cache Lose Conditions
	if (_missionType == 3 && LMO_mTimer == 0) then {
		//If Timer expires
		if (alive _cache && !(_cache getVariable ["LMO_CacheSecure", true])) then {
			_missionState = 2;
			["LMOTaskOutcome", ["Cache has been lost", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_cAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
			if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
			deleteVehicle _cache;
			if (LMO_Debug == true) then {systemChat "LMO: Cache deleted."};
		};
	};
	
	//Ends Mission
	if (_missionState != 0) exitWith {[_missionState] call XEPKEY_fn_taskState};

sleep 1;
};