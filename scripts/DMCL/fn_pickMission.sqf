
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

_missionType = [1,2] call BIS_fnc_randomInt;

[west, "_taskMO", ["A mission of opporunity has appeared on the map, complete the task before the timer expires.", "Mission of Opportunity", "objMarker"], objNull, 1, 3, false] call BIS_fnc_taskCreate;

//Creates Child Task
switch (_missionType) do {

	//Hostage Rescue
	case 1:{
		
		//Creates Task
		[west, ["_taskMissionMO", "_taskMO"], [format ["Our intel indicates a small group of combatants holding a hostage at <marker name =%1>%2</marker>. Locate and extract the hostage.", objMarkerName,objMarkerText], "MO: Hostage Rescue", "REGROUP_MARKER"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
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
		
		[west, ["_taskMissionMO", "_taskMO"], [format ["Some guy needs to die at <marker name =%1>%2</marker>. Locate and extract kill the dude.", objMarkerName,objMarkerText], "MO: Eliminate HVT", "REGROUP_MARKER"], objNull, 1, 3, true] call BIS_fnc_taskCreate;
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
		[_enyUnits] spawn {
			params ["_enyUnits"];
			_enyUnits = _this select 0;
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
		
		[_enyUnits] spawn {
			params ["_enyUnits"];
			_enyUnits = _this select 0;
			_enyUnitPlayers = [];
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
	};
	
	//Eliminiate HVT Win Conditions
	if (_missionType == 2 && !alive _hvt && (missionTimer > 0)) then {
	
		_missionSuccess = true;
		
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