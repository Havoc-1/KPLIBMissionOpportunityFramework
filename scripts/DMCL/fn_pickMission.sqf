//Variable init

/* - Mission States
0 = Default/In Progress
1 = Success
2 = Failed
3 = Cancelled */
_missionState = 0;

//Randomizes LMO Mission Type
_missionType = [1,2] call BIS_fnc_randomInt;

//Hostage Pause Timer Range
_hostagePauseRng = 10;

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
						
						_surInRngWest = ((_hvt nearEntities [["Man","LandVehicle"],HVTrunSurRng]) select {side _x == west}) select {!(currentWeapon _x == "")};
						_surInRngEast = ((_hvt nearEntities [["Man","LandVehicle"],HVTrunSurRng]) select {side _x == east}) select {!(currentWeapon _x == "")};
						if (count _surInRngWest > count _surInRngEast && _hvt call BIS_fnc_enemyDetected) exitWith {
							[_hvt, true] call ace_captives_fnc_setSurrendered;
							if (LMO_HVTDebug == 1) then {systemChat "HVT surrendered, exiting scope"};
						};
						//systemChat format ["SurrenderInRangeWest: %1",_surInRngWest];
						//systemChat format ["SurrenderInRangeEast: %1",_surInRngEast];
						sleep 1;
					};
				};
				
				//HVT escape from zone
				while {true} do {
					_targetsList = [];
					_movePos = [];
					_targetsInRange = ((_hvt nearEntities [["Man","LandVehicle"],HVTrunSearchRng]) select {side _x == west}) select {!(currentWeapon _x == "")};
					_targetsList append _targetsInRange;
					
					{
						_targetGetDir = _hvt getDir _x;
						//systemChat format ["%1", _targetGetDir];
						_targetDir = _targetDir + _targetGetDir;
					}forEach _targetsList;

					if (count _targetsInRange == 0 || _targetDir == 0) then {
						_movePos = [getPos _hvt, HVTrunDist, random 360] call BIS_fnc_relPos;
					} else {	
						_angularDegrees = ((_targetDir/count _targetsInRange) + 180) % 360;
						_movePos = [getPos _hvt, HVTrunDist, _angularDegrees] call BIS_fnc_relPos;
					};
					
					group _hvt move _movePos;
					

					if (LMO_HVTDebug == 1) then {
						systemChat format ["HVT TargetsList Run: %1",_targetsList];
						systemChat format ["Direction to Run: %1",_angularDegrees];
						systemChat format ["MovePos: %1",_movePos];
					};
				
					if (_hvt getVariable ["ace_captives_isSurrendering", false]) exitWith {
						if (LMO_HVTDebug == 1) then {systemChat "Main Scope HVT surrender check complete, exiting script"};
					};
					sleep 40;
				};
			};
		};
	};
	
	//Locate Cache
	case 3:{
						
		[west, ["_taskMisMO", "_taskMO"], [format ["Blow some shit up nearby <marker name =%1>%2</marker>. Big boom mission.", LMO_MkrName,LMO_MkrText], "LMO: Destroy or Secure Cache", "Kill"], objNull, 1, 3, false] call BIS_fnc_taskCreate;
		["_taskMisMO","Kill"] call BIS_fnc_taskSetType;
		["LMOTask", ["Destroy or Secure Cache", "\A3\ui_f\data\igui\cfg\simpletasks\types\kill_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
		LMO_MkrName setMarkerColor "ColorGreen";
		LMO_Mkr setMarkerColor "ColorGreen";
		
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
				LMO_Mkr setMarkerSize [LMO_objMkrRadRescue,LMO_objMkrRadRescue];
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
	
		LMO_mTimer = LMO_mTimer - 1;
		LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
	
	};
	
	//hintSilent format ["Time Remaining: %1", LMO_mTimerStr];
	
	LMO_MkrName setMarkerText format [" %1 [%2]",LMO_MkrText, LMO_mTimerStr];
	
	if (LMO_mTimer == 0) then {
		_missionState = 2;
	};
	
	//----Win Lose Conditions----//
	
	//Hostage Rescue Lose Conditions
	if (_missionType == 1 && (!alive _hostage || LMO_mTimer == 0)) then {
		["LMOTaskOutcome", ["Hostage was killed", "\A3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
	
		_missionState = 2;
		{
			_x setdamage 1;
		}forEach units _hostageGrp;
		
		{
			_x enableAI "PATH";
		}forEach units _enyUnits;
		
		//Deduct Civilian reputation as defined in kp_liberation_config.sqf
		KP_liberation_civ_rep = KP_liberation_civ_rep - KP_liberation_cr_kill_penalty;

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
	if (_missionType == 1 && (_hostage distance2D position LMO_spawnBldg > LMO_objMkrRadRescue) && alive _hostage && LMO_mTimer > 0) then {
		
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
		if (alive _hvt && (LMO_mTimer == 0 || (_hvt getVariable ["ace_captives_isHandcuffed", true] && (_hvt distance2D position LMO_spawnBldg > HVTescapeRng)))) then {
		
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
	
	if (_missionState == 2) exitWith {
	
		["_taskMO", "FAILED", false] call BIS_fnc_taskSetState;
		deleteMarker LMO_Mkr;
		deleteMarker LMO_MkrName;
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMisMO"] call BIS_fnc_deleteTask;
		LMO_active = false;
	};
	
	if (_missionState == 1) exitWith {
	
		["_taskMO", "SUCCEEDED", false] call BIS_fnc_taskSetState;
		deleteMarker LMO_Mkr;
		deleteMarker LMO_MkrName;
		sleep 5;
		["_taskMO"] call BIS_fnc_deleteTask;
		["_taskMisMO"] call BIS_fnc_deleteTask;
		LMO_active = false;
	};
sleep 1;
};