_hvtRunner = random 1;

if (_hvtRunner < 0.5 || LMO_HVTrunnerOnly == true) then {

diag_log "[LMO] [HVT] HVT is a runner.";

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
			["HVT is spooked, initializing runner code.", LMO_Debug] call LMO_fn_rptSysChat;
			params ["_hvt"];
			_hvt enableAI "PATH";
			_hvt setVariable ["LMO_AngDeg",nil];

			
			//Checks whether armed west > east near HVT to surrender
			[
				{
					(_this select 0) params ["_hvt"];
					if (_hvt getVariable ["ace_captives_isSurrendering", true] || _hvt getVariable ["ace_captives_isHandcuffed", false]) then {
						_hvt setBehaviour "CARELESS";
						_surInRngWest = ((_hvt nearEntities [["CAManBase","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_friendly}) select {!(currentWeapon _x == "")};
						_surInRngEast = ((_hvt nearEntities [["CAManBase","LandVehicle"],LMO_HVTrunSurRng]) select {side _x == GRLIB_side_enemy}) select {!(currentWeapon _x == "")};
						if (count _surInRngWest > count _surInRngEast && (_hvt call BIS_fnc_enemyDetected)) exitWith {
							[_hvt, true] call ace_captives_fnc_setSurrendered;
							[_hvt, LMO_qrfOutfit, LMO_HVTqrfChance, LMO_qrfSqdMultiply, LMO_qrfSplit, LMO_qrfPlayerRng,LMO_qrfSqdSpawnDist] call LMO_fn_qrfSpawner;
							["HVT surrendered, exiting surrender PFH.", LMO_Debug] call LMO_fn_rptSysChat;
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
						if (_hvt getVariable ["ace_captives_isSurrendering", false] || _hvt getVariable ["ace_captives_isHandcuffed", false]) exitWith {
							["HVT surrendered, exiting runner PFH.", LMO_Debug] call LMO_fn_rptSysChat;
							[_this select 1] call CBA_fnc_removePerFrameHandler;
						};
						
						_targetsList = [];
						_movePos = [];
						_targetsInRange = ((_hvt nearEntities [["CAManBase","LandVehicle"],LMO_HVTrunSearchRng]) select {side _x == GRLIB_side_friendly}) select {!(currentWeapon _x == "")};
						_targetsList append _targetsInRange;
						_hvt setBehaviour "CARELESS";
						_angDeg = nil;
						_targetDir = 0;
						_targetGetDir = 0;
						_defaultPos = [];

						{
							_targetGetDir = _hvt getDir _x;
							_targetDir = _targetDir + _targetGetDir;
						}forEach _targetsList;

						//HVT Run Direction
						_angDeg = _hvt getVariable "LMO_AngDeg";
						if (count _targetsInRange == 0 || _targetDir == 0) then {
							if (isNil "_angDeg") then {
								_angDeg = random 360;
								_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;

								if (surfaceIsWater _movePos) then {
									_defaultPos = _movePos;
									_movePos = [getPos _hvt,(LMO_HVTrunDist - 30),LMO_HVTrunDist,0,0,0,0,[],_defaultPos] call BIS_fnc_findSafePos;
									_hvt setVariable ["LMO_AngDeg",(getPos _hvt) getDir _movePos];
									[format ["HVT movePos is in water, adjusting running direction to %1", round((getPos _hvt) getDir _movePos)], LMO_Debug] call LMO_fn_rptSysChat;
								} else {
									_hvt setVariable ["LMO_AngDeg",_angDeg];
								};

								group _hvt move _movePos;
								[format ["No AngDeg Found. Random AngDeg: %1.",_angDeg], LMO_Debug] call LMO_fn_rptSysChat;
								
							} else {
								_angDeg = _hvt getVariable "LMO_AngDeg";
								_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;

								if (surfaceIsWater _movePos) then {
									_defaultPos = _movePos;
									_movePos = [getPos _hvt,(LMO_HVTrunDist - 30),LMO_HVTrunDist,0,0,0,0,[],_defaultPos] call BIS_fnc_findSafePos;
									if (_movePos isEqualType 0) then {
										_movePos = [getPos _hvt, LMO_HVTrunDist, (_angDeg + (selectRandom [90,(-90)]))] call BIS_fnc_relPos;
										["No valid position found due to water. Attempting to adjust.", LMO_Debug] call LMO_fn_rptSysChat;
									};
									_hvt setVariable ["LMO_AngDeg",(getPos _hvt) getDir _movePos];
									_angDeg = (getPos _hvt) getDir _movePos;
									[format ["HVT movePos is in water, adjusting running direction to %1", ((getPos _hvt) getDir _movePos)], LMO_Debug] call LMO_fn_rptSysChat;
								};
								
								group _hvt move _movePos;
								[format ["AngDeg Found: %1.",_angDeg], LMO_Debug] call LMO_fn_rptSysChat;
								
							};
						} else {	
							_angDeg = ((_targetDir/count _targetsInRange) + 180) % 360;
							_movePos = [getPos _hvt, LMO_HVTrunDist, _angDeg] call BIS_fnc_relPos;

							if (surfaceIsWater _movePos) then {
								
								private _bList = [[([getPos _hvt, LMO_HVTrunDist, (_targetDir/count _targetsInRange)] call BIS_fnc_relPos), LMO_HVTrunDist*1.5]];
								{
									_bList pushBack [([getPos _hvt, LMO_HVTrunDist, _hvt getDir _x] call BIS_fnc_relPos), 150];
								}forEach _targetsInRange;

								_defaultPos = _movePos;
								_movePos = [getPos _hvt,(LMO_HVTrunDist - 30),LMO_HVTrunDist,0,0,0,0,_bList,_defaultPos] call BIS_fnc_findSafePos;
								if (_movePos isEqualType 0) then {
									_movePos = [getPos _hvt, LMO_HVTrunDist, (_angDeg + (selectRandom [90,(-90)]))] call BIS_fnc_relPos;
									["No valid position found due to water. Attempting to adjust.", LMO_Debug] call LMO_fn_rptSysChat;
								};
								_hvt setVariable ["LMO_AngDeg",(_hvt getDir _movePos)];
								_angDeg = (getPos _hvt) getDir _movePos;
								[format ["HVT movePos is in water, adjusting running direction to %1", ((getPos _hvt) getDir _movePos)], LMO_Debug] call LMO_fn_rptSysChat;
								[format ["Targets in Range: %1", count _bList], LMO_Debug] call LMO_fn_rptSysChat;
							};

							group _hvt move _movePos;

							_hvt setVariable ["LMO_AngDeg",_angDeg];
							[format ["Armed enemy units in range, AngDeg made: %1",_angDeg], LMO_Debug] call LMO_fn_rptSysChat;
						};

						[format ["HVT Running from %1 armed enemies. Run Dir: %2. Move Pos: %3.",count _targetsList,round (_hvt getVariable "LMO_AngDeg"),_movePos], LMO_Debug] call LMO_fn_rptSysChat;
					} else {
						["HVT is dead or deleted, exiting runner PFH.", LMO_Debug] call LMO_fn_rptSysChat;
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