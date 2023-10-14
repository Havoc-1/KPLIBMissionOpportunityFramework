//Variable init

_enyUnits = createGroup east;
_hvtRunnerGrp = createGroup east;
_hostages = createGroup civilian;
_hvt = objNull;
_hvtHeadgear = ["H_Bandanna_khk","H_bandanna_gry","H_Bandanna_cbr"];
_hvtGoggles = ["G_Bandanna_beast","G_Balaclava_Skull1","G_Bandanna_aviator","G_Bandanna_blk","G_Bandanna_shades","None"];
_hvtRunner = 0;

//Default/Nil: 0, Success: 1, Failed: 2, Cancelled: 3
_missionState = 0;

_playerUnitHostages = [];
_enyUnitsInside = [];
_enyUnitPlayers = [];
_enyUnitHostages = [];

_missionType = [1,2] call BIS_fnc_randomInt;

[west, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "objMarker"], objNull, 1, 3, false] call BIS_fnc_taskCreate;

//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		
		//Creates Task
		[west, ["_taskMissionMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Locate and extract the hostage.", objMarkerName,objMarkerText], "MO: Hostage Rescue", "Meet"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMO","Box"] call BIS_fnc_taskSetType;
		["_taskMissionMO","Meet"] call BIS_fnc_taskSetType;
		objMarkerName setMarkerColor "ColorBlue";
		objMarker setMarkerColor "ColorBlue";
		
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
			_hostagePosOffset = selectRandom [-0.5,0.5];
			_hostageDisOffset = random 2;
			
			if (_hostageDisOffset < 0.5) then {
				_hostageDisOffset = 0.5;
			};
			
			if (count _enyUnitsInside >= 1) then {
				
				_hostageTaker = selectRandom _enyUnitsInside;
				_hostageTaker disableAI "PATH";
				_hostageRelDir = _hostageTaker getDir spawnBuilding;
				//_hostagePos = getPosASL _hostageTaker;
				_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
				_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
			
			} else {
				_enyUnitsInside = ((units _enyUnits) select {insideBuilding _x == 1});
				if (count _enyUnitsInside > 0) then {
					
					_hostageTaker = selectRandom _enyUnitsInside;
					_hostageTaker disableAI "PATH";
					_hostageRelDir = _hostageTaker getDir spawnBuilding;
					//_hostagePos = getPosASL _hostageTaker;
					_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
					_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
				
				} else {
					
					_hostageTaker = selectRandom units _enyUnits;
					_hostageTaker disableAI "PATH";
					_hostageRelDir = _hostageTaker getDir spawnBuilding;
					//_hostagePos = getPosASL _hostageTaker;
					_hostagePos = [getPos _hostageTaker, _hostageDisOffset, _hostageRelDir] call BIS_fnc_relPos;
					_x setPosASL [((_hostagePos select 0) + _hostagePosOffset), ((_hostagePos select 1) + _hostagePosOffset), (getPosASL _hostageTaker) select 2];
					
				};
			};
			_x setDir random 360;
		}forEach (units _hostages);
	};
	
	//Eliminate HVT
	case 2:{
		
		[west, ["_taskMissionMO", "_taskMO"], [format ["Some guy needs to die at <marker name =%1>%2</marker>. Locate and extract kill the dude.", objMarkerName,objMarkerText], "MO: Eliminate HVT", "Kill"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMO","Box"] call BIS_fnc_taskSetType;
		["_taskMissionMO","Kill"] call BIS_fnc_taskSetType;
		objMarkerName setMarkerColor "ColorOrange";
		objMarker setMarkerColor "ColorOrange";
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
		
		{
			_noMove = random 1;
			if (_noMove <= 0.3) then {
				_x disableAI "PATH";
			};
		}forEach units _enyUnits;
		
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
		
		//Runner HVT Chance
		_hvtRunner = random 1;
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
				_runSearchRange = 200;
				_runSurrenderRange = 5;
				_angularDegrees = 0;
				
				removeAllWeapons _hvt;
				
				_hvt setBehaviour "CARELESS";
				
				//HVT stays put until alerted
				waitUntil {sleep 5; _hvt call BIS_fnc_enemyDetected};
				_hvt enableAI "PATH";
				

				
				//Checks whether armed west > east near HVT to surrender
				[_hvt,_runSurrenderRange] spawn {
					params ["_hvt","_runSurrenderRange"];
						_hvt = _this select 0;
						_runSurrenderRange = _this select 1;
					while {_hvt getVariable ["ace_captives_isSurrendering", true]} do {
						
						_surrenderInRangeWest = ((_hvt nearEntities [["Man","LandVehicle"],_runSurrenderRange]) select {side _x == west}) select {!(currentWeapon _x == "")};
						_surrenderInRangeEast = ((_hvt nearEntities [["Man","LandVehicle"],_runSurrenderRange]) select {side _x == east}) select {!(currentWeapon _x == "")};
						if (count _surrenderInRangeWest > count _surrenderInRangeEast && _hvt call BIS_fnc_enemyDetected) exitWith {
							[_hvt, true] call ace_captives_fnc_setSurrendered;
							//systemChat "Man surrendered, exiting scope";
						};
						//systemChat format ["SurrenderInRangeWest: %1",_surrenderInRangeWest];
						//systemChat format ["SurrenderInRangeEast: %1",_surrenderInRangeEast];
						sleep 1;
					};
				};
				
				//HVT escape from zone
				while {true} do {
					_targetsList = [];
					_movePos = [];
					_targetsInRange = ((_hvt nearEntities [["Man","LandVehicle"],_runSearchRange]) select {side _x == west}) select {!(currentWeapon _x == "")};
					_targetsList append _targetsInRange;
					
					{
						_targetGetDir = _hvt getDir _x;
						//systemChat format ["%1", _targetGetDir];
						_targetDir = _targetDir + _targetGetDir;
					}forEach _targetsList;

					if (count _targetsInRange == 0 || _targetDir == 0) then {
						_movePos = [getPos _hvt, 400, random 360] call BIS_fnc_relPos;
					} else {	
						_angularDegrees = ((_targetDir/count _targetsInRange) + 180) % 360;
						_movePos = [getPos _hvt, 400, _angularDegrees] call BIS_fnc_relPos;
					};
					
					group _hvt move _movePos;

					//systemChat format ["Direction to Run: %1",_angularDegrees];
					//systemChat format ["Directions Sorted: %1",_angularDiffSort];
					//systemChat format ["MovePos: %1",_movePos];
					systemChat format ["TargetList: %1",_targetsList];
					
					if (_hvt getVariable ["ace_captives_isSurrendering", false]) exitWith {
						//systemChat "Main Scope surrender check complete, exiting script";
					};
					sleep 40;
				};
			};
		};
	};
	
	//Blow shit up
	case 3:{
						
		[west, ["_taskMissionMO", "_taskMO"], ["Destroy this thing", "MO: Destroy Cache", "objMarker"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
		objMarkerName setMarkerColor "ColorGreen";
		objMarker setMarkerColor "ColorGreen";
		
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
		_missionState = 2;
	};
	
	//----Win Lose Conditions----//
	
	//Hostage Rescue Lose Conditions
	if (_missionType == 1 && (({alive _x} count units _hostages == 0) || missionTimer == 0)) then {
	
		_missionState = 2;
		{
			_x setdamage 1;
		}forEach units _hostages;
		
		{
			_x enableAI "PATH";
		}forEach units _enyUnits;
		
		//Deduct Civilian reputation as defined in kp_liberation_config.sqf
		KP_liberation_civ_rep = KP_liberation_civ_rep - KP_liberation_cr_kill_penalty;

		_enyUnitPlayers = [];
		[_enyUnits, _hostages] spawn {
			params ["_enyUnits","_hostages"];
			_enyUnits = _this select 0;
			_hostages = _this select 1;
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
	};

	//Hostage Rescue Win Conditions
	if (_missionType == 1 && ({_x distance2D position spawnBuilding > objMarkerRadiusRescue} count units _hostages >= 1) && missionTimer > 0) then {
		
		_missionState = 1;

		//Increase Civilian reputation and intelligence 
		KP_liberation_civ_rep = KP_liberation_civ_rep + XEPKEY_LMO_HR_REWARD_CIVREP;
		resources_intel = resources_intel + XEPKEY_LMO_HR_REWARD_INTEL;

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
	if (_missionType == 2) then {
		
		//if HVT is alive, mission timer expired, or not handcuffed or surrendered and exited escape zone
		if (alive _hvt && (missionTimer == 0 || ((_hvt getVariable ["ace_captives_isSurrendering", true] || _hvt getVariable ["ace_captives_isHandcuffed", true]) && (_hvt distance2D position spawnBuilding > Bradius * 0.8)))) then {
		
			_missionState = 2;
			
			if (_hvtRunner < 0.5) then {
				deleteGroup _hvtRunnerGrp;
			};
			
			deleteVehicle _hvt;
					
			[_enyUnits] spawn {
				params ["_enyUnits"];
				_enyUnits = _this select 0;
				_enyUnitPlayers = [];
				while {{alive _x} count units _enyUnits > 0} do {
					
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man"], (Bradius * 0.8)]) select {isPlayer _x};
					}forEach units _enyUnits;
					
					if (count _enyUnitPlayers == 0) exitWith {
						_missionState = 2;
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
	
	//Eliminiate HVT Win Conditions
	if (_missionType == 2) then {
		
		//if HVT is alive, Mission Timer not expired, HVT has exited escape zone, is surrendered or handcuffed
		//OR
		//if HVT is dead, mission timer not expired
		if ((alive _hvt && missionTimer > 0 && (_hvt distance2D position spawnBuilding > Bradius * 0.8) && (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false])) || (!alive _hvt && (missionTimer > 0))) then {
			_missionState = 1;
			
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
				};
				case false: {
					if (!(primaryWeapon _hvt == "")) then {
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_LOW;
					} else {
						combat_readiness = combat_readiness - XEPKEY_LMO_HVT_REWARD_ALERT_LOW;
					};
				};

			};

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
	};
	
	if (_missionState == 2) exitWith {
	
		["_taskMO", "FAILED", true] call BIS_fnc_taskSetState;
		deleteMarker objMarker;
		deleteMarker objMarkerName;
		//deleteMarker _objMarkerName2;
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMissionMO"] call BIS_fnc_deleteTask;
		activeMission = false;
	};
	
	if (_missionState == 1) exitWith {
	
		["_taskMO", "SUCCEEDED", true] call BIS_fnc_taskSetState;
		deleteMarker objMarker;
		deleteMarker objMarkerName;
		//deleteMarker _objMarkerName2;
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMissionMO"] call BIS_fnc_deleteTask;
		activeMission = false;
	};
sleep 1;
};