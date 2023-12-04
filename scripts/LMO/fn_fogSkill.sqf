if (isServer) then {
	params [["_lowFog",0.2],["_highFog",0.6]];

	diag_log format ["[FogSkill] Fog PFH initializing. Low Fog: %1, High Fog: %2.",_lowFog,_highFog];
	[
		{
			
			(_this select 0) params ["_lowFog","_highFog"];
			
			
			//Gets current world fog value
			private _fog = fog;
			
			//Fog value that maximizes setSkill nerf, prevents setSkill 0
			if (_fog > _highFog) then {_fog = 0.95};

			//Will not adjust skills if clear day
			if (_fog < _lowFog) then {_fog = 0};
			
			//Converts fog density to a value to multiply on setSkill
			private _adjustSkill = (1 - _fog);
			
			private _allUnits = allUnits select {!isPlayer _x};

			if (count _allUnits > 0) then {
				{
					private _unit = _x;
					//get current skill of units
					private _accuracy = _unit skill "aimingAccuracy";
					private _aimSpeed = _unit skill "aimingSpeed";
					private _endurance = _unit skill "endurance";
					private _spot = _unit skill "spotDistance";
					private _spotTime = _unit skill "spotTime";
					private _courage = _unit skill "courage";
					private _command = _unit skill "commanding";
					private _gen = _unit skill "general";
					
					//Apply skill change based on fog
					if (!isPlayer _unit) then {
						if (!(_unit getVariable ["fogAdjusted", false])) then {
							_unit setVariable ["fogAdjusted", true];
							_unit setVariable ["fogValue", _fog];
							_unit setSkill ["aimingAccuracy", (_accuracy * _adjustSkill)];
							_unit setSkill ["aimingSpeed", (_aimSpeed * _adjustSkill)];
							_unit setSkill ["endurance", (_endurance * _adjustSkill)];
							_unit setSkill ["spotDistance", (_spot * _adjustSkill)];
							_unit setSkill ["spotTime", (_spotTime * _adjustSkill)];
							_unit setSkill ["courage", (_courage * _adjustSkill)];
							_unit setSkill ["commanding", (_command * _adjustSkill)];
							_unit setSkill ["general", (_gen * _adjustSkill)];
						} else {
							if (_unit getVariable ["fogAdjusted", true] && _fog > _lowFog) then {
								_newFog = (1 - (_unit getVariable "fogValue"));
								_unit setSkill ["aimingAccuracy", ((_accuracy / _newFog) * _adjustSkill)];
								_unit setSkill ["aimingSpeed", ((_aimSpeed / _newFog) * _adjustSkill)];
								_unit setSkill ["endurance", ((_endurance / _newFog) * _adjustSkill)];
								_unit setSkill ["spotDistance", ((_spot / _newFog) * _adjustSkill)];
								_unit setSkill ["spotTime", ((_spotTime / _newFog) * _adjustSkill)];
								_unit setSkill ["courage", ((_courage / _newFog) * _adjustSkill)];
								_unit setSkill ["commanding", ((_command / _newFog) * _adjustSkill)];
								_unit setSkill ["general", ((_gen / _newFog) * _adjustSkill)];
								_unit setVariable ["fogValue", _fog];
							} else {
								_newFog = (1 - (_unit getVariable "fogValue"));
								_unit setSkill ["aimingAccuracy", (_accuracy / _newFog)];
								_unit setSkill ["aimingSpeed", (_aimSpeed / _newFog)];
								_unit setSkill ["endurance", (_endurance / _newFog)];
								_unit setSkill ["spotDistance", (_spot / _newFog)];
								_unit setSkill ["spotTime", (_spotTime / _newFog)];
								_unit setSkill ["courage", (_courage / _newFog)];
								_unit setSkill ["commanding", (_command / _newFog)];
								_unit setSkill ["general", (_gen / _newFog)];
								_unit setVariable ["fogValue", nil];
								_unit setVariable ["fogAdjusted", nil];
							};
						};
					};
				}forEach _allUnits;
				diag_log format ["[FogSkill] Fog PFH adjusted skill. Spot Distance: %1",((selectRandom _allUnits) skill "spotDistance")];
			} else {
				diag_log format ["[FogSkill] No units found."];
			};
		},
		30,
		[_lowFog,_highFog]
	] call CBA_fnc_addPerFrameHandler;
};