//Variable init

/* - Mission States
0 = Default/In Progress
1 = Success
2 = Failed
3 = Cancelled */
_missionState = 0;

//Randomizes LMO Mission Type
_missionType = [1,3] call BIS_fnc_randomInt;

//Hostage Pause Timer Range
_hostagePauseRng = 10;

//Model used for Cache OBJ
_cacheModel = "Box_FIA_Wps_F";

//HVT Headgear and Goggles
_hvtHeadgear = [
	"H_Bandanna_khk",
	"H_Bandanna_khk_hs",
	"H_bandanna_gry",
	"H_Bandanna_cbr",
	"H_Bandanna_blu",
	"H_Bandanna_mcamo",
	"H_Bandanna_sgg",
	"H_Bandanna_sand",
	"H_Bandanna_camo",
	"H_Watchcap_blk",
	"H_Watchcap_cbr",
	"H_Watchcap_camo",
	"H_Watchcap_khk",
	"H_Watchcap_sgg",
	"H_Beret_blk"
];
_hvtGoggles = [
	"G_Balaclava_Skull1",
	"G_Balaclava_Tropentarn",
	"G_Balaclava_lowprofile",
	"G_Bandanna_beast",
	"G_Bandanna_aviator",
	"G_Bandanna_blk",
	"G_Bandanna_shades",
	"G_Bandanna_Skull1",
	"G_Bandanna_Skull2",
	"G_Bandanna_Syndikat1",
	"G_Bandanna_Syndikat2",
	"G_Bandanna_sport",
	"G_Aviator",
	"G_AirPurifyingRespirator_02_black_F",
	"G_AirPurifyingRespirator_02_olive_F",
	"G_AirPurifyingRespirator_02_sand_F",
	"None"
];

//Predefining Variables
_hvtRunner = 0;
_hvtNoRifle = 0;
_enyUnits = createGroup east;
_hvtRunnerGrp = createGroup east;
_hostageGrp = createGroup civilian;
_hostage = objNull;
_hvt = objNull;
_playerUnitHostages = [];
_enyUnitsInside = [];
_enyUnitPlayers = [];
_enyUnitHostages = [];
_hostageRescueRad = LMO_objMkrRadRescue;
_cache = objNull;
_cacheSecured = false;


[west, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "LMO_Mkr"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
["_taskMO","Box"] call BIS_fnc_taskSetType;


//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		
		//Creates Task
		[west, ["_taskMisMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Locate and extract the hostage.", LMO_MkrName,LMO_MkrText], "LMO: Hostage Rescue", "Meet"], objNull, 1, 3, false] call BIS_fnc_taskCreate;																						
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
		if (count _nearbyBuildings < 10) then {_hostageRescueRad = LMO_objMkrRadRescue * 1.5};
		
		//Empties Variables
		_enyUnitHostages = [];
		_playerUnitHostages = [];
		_enyUnits = createGroup east;
		_hostageGrp = createGroup civilian;
		_hostage = objNull;
		_hostageTaker = objNull;
										
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
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos LMO_spawnBldg,
				[],
				0,
				"NONE"
			];
			
			[_enyUnitsHolder] joinSilent _enyUnits;
			
		} forEach XEPKEY_SideOpsORBAT;
		
		//[(units _enyUnits), getPos LMO_spawnBldg, 30, 1, true] call zen_ai_fnc_garrison;
		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;
		
		{
			_noMove = random 1;

			_x disableAI "RADIOPROTOCOL";

			if (_noMove <= 0.3) then {
				_x disableAI "PATH";
			};
		}forEach units _enyUnits;

		//VCOM will stop the AI squad from responding to calls for backup.
		//if (LMO_VCOM_On == true) then {
			_enyUnits setVariable ["VCM_NORESCUE",true];
			_enyUnits setVariable ["VCM_DisableForm",true];
		//};
		

		//Surrenders hostage and moves to elevated enemies if possible
		_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1}) select {(getPosATL _x) select 2 > 3};
		{
		
			//[_x, true] call ace_captives_fnc_setSurrendered;
			[_x, true, objNull] call ACE_captives_fnc_setHandcuffed;
			_hostagePosOffset = selectRandom [-0.5,0.5];

			_hostageDisOffset = random 2;
			
			if (_hostageDisOffset < 0.5) then {
				_hostageDisOffset = 0.5;
			};

			if (count _enyUnitsInside >= 1) then {
				
				_hostageTaker = selectRandom _enyUnitsInside;
				_hostageTaker disableAI "PATH";
				
				_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
				//_hostagePos = getPosASL _hostageTaker;
				_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
				_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
			
			} else {
				_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
				if (count _enyUnitsInside > 0) then {
					
					_hostageTaker = selectRandom _enyUnitsInside;
					_hostageTaker disableAI "PATH";
					_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
					//_hostagePos = getPosASL _hostageTaker;
					_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
					_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
				
				} else {
					
					_hostageTaker = selectRandom units _enyUnits;
					_hostageTaker disableAI "PATH";
					_hostageRelDir = _hostageTaker getDir LMO_spawnBldg;
					//_hostagePos = getPosASL _hostageTaker;
					_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
					_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
					
				};
			};
			_x setDir random 360;
		}forEach (units _hostageGrp);
	};
	
	//Eliminate HVT
	case 2:{
		
		[west, ["_taskMisMO", "_taskMO"], [format ["A high value target was reported to be within the vicinity nearby <marker name =%1>%2</marker>. Locate and extract kill the high value target.", LMO_MkrName,LMO_MkrText], "LMO: Capture or Kill HVT", "Kill"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
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
		{
			_enyUnitsHolder = _enyUnits createUnit [
				_x, //classname 
				getPos LMO_spawnBldg,
				[],
				0,
				"NONE"
			];
			
			[_enyUnitsHolder] joinSilent _enyUnits;
			
		} forEach XEPKEY_SideOpsORBAT;
		
		//[(units _enyUnits), getPos LMO_spawnBldg, 30, 1, true] call zen_ai_fnc_garrison;
		[getPos LMO_spawnBldg, LMO_bTypes, (units _enyUnits), 30, 1, true, true] call ace_ai_fnc_garrison;
		{
			_noMove = random 1;
			
			_x disableAI "RADIOPROTOCOL";

			if (_noMove <= 0.3) then {
				_x enableAI "PATH";
			};

		}forEach units _enyUnits;

		//if (LMO_VCOM_On == true) then {
			//VCOM will stop the AI squad from responding to calls for backup.
			_enyUnits setVariable ["VCM_NORESCUE",true];
			_enyUnits setVariable ["VCM_DisableForm",true];
		//};

		
		
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
		
		//Eliminiate HVT Parameters
		removeHeadgear _hvt;
		removeGoggles _hvt;
		_hvt addHeadGear selectRandom _hvtHeadgear;
		_hvt addGoggles selectRandom _hvtGoggles;
		if ((daytime <= 20) || (daytime >= 6)) then {_hvt unassignItem hmd _hvt};
		
		//Runner HVT Chance
		_hvtRunner = random 1;
		_hvtNoRifle = random 1;
		
		if (_hvtNoRifle < 0.5) then {
			removeAllPrimaryWeaponItems _hvt;
		};

		if (_hvtRunner < 0.5) then {
		
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
				_hvt = _this select 0;
				_hvtRunnerGrp = _this select 1;
				[_hvt] joinSilent _hvtRunnerGrp;
				
				_hvtDir = getDir _hvt;
				_targetDir = 0;
				_targetsList = [];
				_targetGetDir = 0;
				_targetsInRange = [];
				_angularDegrees = 0;
				
				removeAllWeapons _hvt;
				
				_hvt setBehaviour "CARELESS";
				
				//HVT stays put until alerted
				waitUntil {sleep 5; _hvt call BIS_fnc_enemyDetected};
				_hvt enableAI "PATH";
				

				
				//Checks whether armed west > east near HVT to surrender
				[_hvt] spawn {
					params ["_hvt"];
					_hvt = _this select 0;
					while {_hvt getVariable ["ace_captives_isSurrendering", true]} do {
						
						_surInRngWest = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == west}) select {!(currentWeapon _x == "")};
						_surInRngEast = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == east}) select {!(currentWeapon _x == "")};
						if (count _surInRngWest > count _surInRngEast && _hvt call BIS_fnc_enemyDetected) exitWith {
							[_hvt, true] call ace_captives_fnc_setSurrendered;
							if (LMO_HVTDebug == true) then {systemChat "LMO: HVT surrendered, exiting scope"};
						};
						//systemChat format ["LMO: SurrenderInRangeWest: %1",_surInRngWest];
						//systemChat format ["LMO: SurrenderInRangeEast: %1",_surInRngEast];
						sleep 1;
					};
				};
				
				//HVT escape from zone
				while {true} do {
					_targetsList = [];
					_movePos = [];
					_targetsInRange = ((_hvt nearEntities [["Man","LandVehicle"],LMO_HVTrunSearchRng]) select {side _x == west}) select {!(currentWeapon _x == "")};
					_targetsList append _targetsInRange;
					
					{
						_targetGetDir = _hvt getDir _x;
						//systemChat format ["LMO: %1", _targetGetDir];
						_targetDir = _targetDir + _targetGetDir;
					}forEach _targetsList;

					if (count _targetsInRange == 0 || _targetDir == 0) then {
						_movePos = [getPos _hvt, LMO_HVTrunDist, random 360] call BIS_fnc_relPos;
					} else {	
						_angularDegrees = ((_targetDir/count _targetsInRange) + 180) % 360;
						_movePos = [getPos _hvt, LMO_HVTrunDist, _angularDegrees] call BIS_fnc_relPos;
					};
					
					group _hvt move _movePos;
					

					if (LMO_HVTDebug == true) then {
						systemChat format ["LMO: HVT TargetsList Run: %1",_targetsList];
						systemChat format ["LMO: Direction to Run: %1",_angularDegrees];
						systemChat format ["LMO: MovePos: %1",_movePos];
					};
				
					if (_hvt getVariable ["ace_captives_isSurrendering", false]) exitWith {
						if (LMO_HVTDebug == true) then {systemChat "LMO: Main Scope HVT surrender check complete, exiting script"};
					};
					sleep 40;
				};
			};
		};
	};
	
	//Locate Cache
	case 3:{
		
		[west, ["_taskMisMO", "_taskMO"], [format ["Reconnaissance has identified enemy forces moving a supply cache around <marker name =%1>%2</marker>. The supply cache appears to be a stack of wooden boxes covered with a net. Secured supples will be air lifted to the nearest FOB while destroying the cache will reduce enemy readiness.<br/><br/>Locate and destroy or secure the supply cache.", LMO_MkrName,LMO_MkrText], "LMO: Destroy or Secure Cache", "Box"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMisMO","Destroy"] call BIS_fnc_taskSetType;
		["LMOTask", ["Destroy or Secure Cache", "a3\missions_f_oldman\data\img\holdactions\holdaction_box_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		LMO_MkrName setMarkerColor "ColorGreen";
		LMO_Mkr setMarkerColor "ColorGreen";

		_cacheSpawnPos = getPosATL LMO_spawnBldg findEmptyPosition [0, 40, _cacheModel];
		_cache = objNull;
		
		//Spawn Cache
		if (count _cacheSpawnPos > 0) then {
			_cache = createVehicle [_cacheModel, _cacheSpawnPos, [], 0, "CAN_COLLIDE"];
			if (LMO_Debug == true) then {systemChat format ["LMO: Cache created at %1", getPos _cache]};
		} else {
			_cache = createVehicle [getPos LMO_spawnBldg, _cacheModel, [], 0, "CAN_COLLIDE"];
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
				_cacheStrobe = "PortableHelipadLight_01_red_F" createVehicle getPos _target;
				_cacheStrobe attachTo [_target, [0,0.2,-0.7]];
				[_target] spawn {
					params ["_target"];
					_target = _this select 0;
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
				_cacheAttached = attachedObjects _vehicle select {typeOf _x == "PortableHelipadLight_01_red_F"};
				if (count _cacheAttached > 0) then {{deleteVehicle _x} forEach _cacheAttached};
				if (LMO_Debug == true) then {
					systemChat "LMO: Cache destroyed.";
					systemChat format ["LMO: CacheSecure variable: %1", _vehicle getVariable "LMO_CacheSecure"];
				};
				_vehicle setDamage 1;
				
			};
			if (LMO_Debug == true) then {systemChat format ["LMO: Cache Damaged: %1", _damage]};
		}];
		
		//_smoke = "test_EmptyObjectForSmoke" createVehicle (getPos _cache);
		
	};
};

while {LMO_active == true} do {
	
	//Hostage Rescue Parameters
	if (_missionType == 1) then {
		//Checks if Player is within range of hostage to halt timer
		{
			_playerUnitHostages = (nearestObjects [_x, ["Man","LandVehicle"], _hostagePauseRng]) select {isPlayer _x};
			_enyUnitHostages = (nearestObjects [_x, ["Man","LandVehicle"], _hostagePauseRng]) select {!isPlayer _x} select {side _x == east};
		}forEach units _hostageGrp;
		
		if ((count _playerUnitHostages > 0) && (count _enyUnitHostages == 0)) then {
				LMO_mTimer = LMO_mTimer - 0;
				LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
				LMO_MkrName setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerPos getPos LMO_spawnBldg;
				LMO_Mkr setMarkerSize [_hostageRescueRad,_hostageRescueRad];
				LMO_Mkr setMarkerBrush "Solid";
		} else {
				LMO_MkrName setMarkerColor "ColorBlue";
				LMO_Mkr setMarkerColor "ColorBlue";
				LMO_Mkr setMarkerPos LMO_MkrPos;
				LMO_Mkr setMarkerSize [LMO_objMkrRad,LMO_objMkrRad];
				LMO_Mkr setMarkerBrush "FDiagonal";
				LMO_mTimer = LMO_mTimer - 1;
				LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
		};
		
	} else {
		if (_missionType == 2) then {
			
			//Checks if Player is within range of HVT to halt timer
			_playerUnitsHVT = (nearestObjects [_hvt, ["Man","LandVehicle"], _hostagePauseRng]) select {isPlayer _x};
			
			if ((count _playerUnitsHVT > 0) && (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false])) then {
					LMO_mTimer = LMO_mTimer - 0;
					LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
					LMO_MkrName setMarkerColor "ColorGrey";
					LMO_Mkr setMarkerColor "ColorGrey";
					LMO_Mkr setMarkerPos getPos _hvt;
					LMO_MkrName setMarkerPos position _hvt;
					LMO_Mkr setMarkerSize [_hostagePauseRng,_hostagePauseRng];
					LMO_Mkr setMarkerBrush "Solid";
			} else {
					LMO_MkrName setMarkerColor "ColorOrange";
					LMO_Mkr setMarkerColor "ColorOrange";
					LMO_Mkr setMarkerPos LMO_MkrPos;
					LMO_MkrName setMarkerPos LMO_MkrPos;
					LMO_Mkr setMarkerSize [LMO_objMkrRad,LMO_objMkrRad];
					LMO_Mkr setMarkerBrush "FDiagonal";
					LMO_mTimer = LMO_mTimer - 1;
					LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
			};
			
		} else {
			
			//Checks if cache is secured to halt timer
			if (_missionType == 3 && (_cache getVariable ["LMO_CacheSecure", true])) then {
			
				LMO_mTimer = LMO_mTimer - 0;
				LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
				LMO_MkrName setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerColor "ColorGrey";
				LMO_Mkr setMarkerPos position _cache;
				LMO_MkrName setMarkerPos position _cache;
				LMO_Mkr setMarkerSize [LMO_FultonRng,LMO_FultonRng];
				LMO_Mkr setMarkerBrush "Solid";
			
			} else {
				LMO_mTimer = LMO_mTimer - 1;
				LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
			};
		};
	};
	
	LMO_MkrName setMarkerText format [" %1 [%2]",LMO_MkrText, LMO_mTimerStr];
	
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
			_enyUnits = _this select 0;
			_hostageGrp = _this select 1;
			_enyUnitPlayers = [];
			while {{alive _x} count units _enyUnits > 0} do {
				
				{
					_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
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
	if (_missionType == 1 && (_hostage distance2D position LMO_spawnBldg > _hostageRescueRad) && alive _hostage && LMO_mTimer > 0) then {
		
		["LMOTaskOutcome", ["Hostage secured", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		
		_missionState = 1;

		//Increase Civilian reputation and intelligence 
		KP_liberation_civ_rep = KP_liberation_civ_rep + XEPKEY_LMO_HR_REWARD_CIVREP;
		resources_intel = resources_intel + XEPKEY_LMO_HR_REWARD_INTEL;

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
		
		//if HVT is alive, mission timer expired, or not handcuffed and exited escape zone
		if (alive _hvt && (LMO_mTimer == 0 || (_hvt getVariable ["ace_captives_isHandcuffed", true] && (_hvt distance2D position LMO_spawnBldg > LMO_HVTescRng)))) then {
		
			["LMOTaskOutcome", ["HVT has escaped", "\A3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_missionState = 2;
			
			if (_hvtRunner < 0.5) then {deleteGroup _hvtRunnerGrp};
			
			deleteVehicle _hvt;
					
			[_enyUnits] spawn {
				params ["_enyUnits"];
				_enyUnits = _this select 0;
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
		if ((alive _hvt && LMO_mTimer > 0 && (_hvt distance2D position LMO_spawnBldg > LMO_bRadius * 0.8) && (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false])) || (!alive _hvt && (LMO_mTimer > 0))) then {
			
			if (_hvtRunner < 0.5) then {
				deleteGroup _hvtRunnerGrp;
			};

			switch (alive _hvt) do {
				case true: {
					//noweapon, alive
					if (primaryWeapon _hvt == "") then {
						resources_intel = resources_intel + 25;
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_HIGH;
					} else { //hasweapon, alive
						resources_intel = resources_intel + 40;
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_HIGH;
					};
					["LMOTaskOutcome", ["HVT has been captured", "\z\ace\addons\captives\ui\handcuff_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					deleteVehicle _hvt;
				};
				case false: {
					if (!(primaryWeapon _hvt == "")) then {
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_LOW;
					} else {
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_LOW;
					};
					["LMOTaskOutcome", ["HVT has been neutralized", "\A3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
				};

			};
			
			_missionState = 1;
			
			[_enyUnits] spawn {
				params ["_enyUnits"];
				_enyUnits = _this select 0;
				_enyUnitPlayers = [];
				while {{alive _x} count units _enyUnits > 0} do {
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
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
	};
	
	//Cache Win Conditions
	if (_missionType == 3 && LMO_mTimer > 0) then {
		
		//If cache destroyed and NOT secured
		if (!alive _cache && _cacheSecured != true) then {
			_missionState = 1;
			["LMOTaskOutcome", ["Cache has been destroyed", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		};
		
		//If Secured Cache
		if (alive _cache && (_cache getVariable ["LMO_CacheSecure", true]) && _cacheSecured != true) then {
			["LMOTaskOutcome", ["Cache has been located", "a3\ui_f\data\gui\rsccommon\rscbuttonsearch\search_start_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			
			//Marks cache as tagged in missionNameSpace to prevent loop executions
			_cacheSecured = missionNamespace getVariable "LMO_CacheTagged";
			if (isNil "_cacheSecured") then {
				_cacheSecured = true;
				missionNamespace setVariable ["LMO_CacheTagged", _cacheSecured];
				if (LMO_Debug == true) then {systemChat format ["LMO: missionnameSpace _cacheSecured: %1",missionNamespace getVariable "LMO_CacheTagged"]};
			};
			sleep 1;
			
			//Checks if players are no longer nearby cache, then exitsWith fulton script
			_nearbyCache = [];
			if (LMO_Debug == true) then {systemChat format ["LMO: Delete loop started for Cache at %1.", getPos _cache]};
			while {true} do {
				if (!alive _cache) exitWith {
						systemChat format ["LMO: Cache was destroyed before uplift."];
						["LMOTaskOutcome", ["Cache was destroyed before uplift", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
						_missionState = 1;
				};
				
				if (alive _cache) then {
					_nearbyCache = (nearestObjects [_cache, ["Man", "LandVehicle"], LMO_FultonRng]) select {isPlayer _x};
				};
				if (count _nearbyCache == 0) exitWith {
					_cacheAttached = attachedObjects _cache;
					if (count _cacheAttached > 0) then {{deleteVehicle _x} forEach _cacheAttached};
					_cachePos = getPosATL _cache;
					_cache hideObjectGlobal true;
					
					if (LMO_Debug == true) then {systemChat "LMO: No players in range, secured cache deleted. Exiting scope with fulton."};
					
					_cacheFly = "C_supplyCrate_F" createVehicle _cachePos;
					_cacheBalloon = "Land_Balloon_01_air_F" createVehicle _cachePos;
					_cacheBalloon allowDamage false;
					_cacheBalloon attachTo [_cacheFly, [0,0,25]];
					_cacheBalloon setObjectScale 10;
					//_cacheChute = "B_Parachute_02_F" createVehicle _cachePos;
					//_cacheChute attachTo [_cacheFly, [0,0,30]];
					//_cacheChute hideObjectGlobal true;
					//_cacheRope = ropeCreate [_cacheChute, [0,0,-5],28, nil, nil, nil, 10];
					_cacheLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cacheFly;
					_cacheLight allowDamage false;
					_cacheLight attachTo [_cacheFly, [0,0,0.6]];
					_flyRate = 1.2;
					_flyMax = 1000;
					
					while {(getPosATL _cacheFly) select 2 < _flyMax} do {
						_cacheHeight = (getPosATL _cacheFly) select 2;
						if (_cacheHeight >= _flyMax*0.025 && _cacheHeight < _flyMax*0.03) then {_flyRate = 0.3};
						if (_cacheHeight >= _flyMax*0.03 && _cacheHeight < _flyMax*0.035) then {_flyRate = 4};
						if (_cacheHeight >= _flyMax*0.035 && _cacheHeight < _flyMax*0.95) then {_flyRate = 10};
						if (_cacheHeight >= _flyMax*0.9) then {_flyRate = 2};
						_cacheFly setPosATL [getPosATL _cacheFly select 0, getPosATL _cacheFly select 1, (getPosATL _cacheFly select 2)+_flyRate];
						sleep 0.1;
						if ((getPosATL _cacheFly) select 2 >= _flyMax) exitWith {
							//ropeDestroy _cacheRope;
							deleteVehicle _cacheFly;
							deleteVehicle _cacheBalloon;
							//deleteVehicle _cacheChute;
							deleteVehicle _cacheLight;
							["LMOTaskOutcome", ["Cache uplifted successfully", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
							if (LMO_Debug == true) then {systemChat "LMO: Cache successfully airlifted."};
							deleteVehicle _cache;
							_missionState = 1;
							missionNamespace setVariable ["LMO_CacheTagged", nil];
							
						};
					};
					
				};
				sleep 5;
			};
		};
	};
	
	//Cache Lose Conditions
	if (_missionType == 3 && LMO_mTimer == 0) then {
		//If Timer expires
		if (alive _cache && !(_cache getVariable ["LMO_CacheSecure", true])) then {
			_missionState = 2;
			["LMOTaskOutcome", ["Cache has been lost", "a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
			_cacheAttached = attachedObjects _cache select {typeOf _x == "PortableHelipadLight_01_red_F"};
			if (count _cacheAttached > 0) then {{deleteVehicle _x} forEach _cacheAttached};
			deleteVehicle _cache;
			if (LMO_Debug == true) then {systemChat "LMO: Cache deleted."};
		};
	};
	
	if (_missionState == 2) exitWith {
	
		["_taskMO", "FAILED", false] call BIS_fnc_taskSetState;
		deleteMarker LMO_Mkr;
		deleteMarker LMO_MkrName;
		if (LMO_Debug == true) then {deleteMarker LMO_MkrDebug};
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMisMO"] call BIS_fnc_deleteTask;
		LMO_active = false;
	};
	
	if (_missionState == 1) exitWith {
	
		["_taskMO", "SUCCEEDED", false] call BIS_fnc_taskSetState;
		deleteMarker LMO_Mkr;
		deleteMarker LMO_MkrName;
		if (LMO_Debug == true) then {deleteMarker LMO_MkrDebug};
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMisMO"] call BIS_fnc_deleteTask;
		LMO_active = false;
	};
sleep 1;
};