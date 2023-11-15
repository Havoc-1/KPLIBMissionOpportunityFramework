//Deletes QRF if OBJ is complete and no players are in range	
["LMO_qrfDelete",
	{
		params ["_enyUnits","_cache","_enyUnits2"];
		
		//enyUnits Grp1
		[
			{
				(_this select 0) params ["_enyUnits","_cache"];
				_enyUnitPlayers = [];
				if ({alive _x} count units _enyUnits > 0) then {
					//_enyUnits move getPos _cache;
					[_enyUnits] call CBA_fnc_clearWaypoints;
					[_enyUnits, getPos _cache, 10] call CBA_fnc_taskAttack;
					{
						_enyUnitPlayers = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
					}forEach units _enyUnits;
				};
				if ((count _enyUnitPlayers == 0) && !alive _cache) exitWith {
					{deleteVehicle _x}forEach units _enyUnits;
					deleteGroup _enyUnits;
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
			},
			20,
			[_enyUnits,_cache]
		] call CBA_fnc_addPerFrameHandler;
		
		//enyUnits Grp2
		if (_splitGrp > 0.5) then {
			[
				{
					(_this select 0) params ["_cache","_enyUnits2"];
					_enyUnitPlayers2 = [];
					if ({alive _x} count units _enyUnits2 > 0) then {
						//_enyUnits2 move getPos _cache;
						[_enyUnits2] call CBA_fnc_clearWaypoints;
						[_enyUnits2, getPos _cache, 10] call CBA_fnc_taskAttack;
						{
							_enyUnitPlayers2 = (nearestObjects [_x, ["Man"], (LMO_bRadius * 0.8)]) select {isPlayer _x};
						}forEach units _enyUnits2;
					};
					if ((count _enyUnitPlayers2 == 0) && !alive _cache) exitWith {
						{deleteVehicle _x}forEach units _enyUnits2;
						deleteGroup _enyUnits2;
						[_this select 1] call CBA_fnc_removePerFrameHandler;
					};
				},
				20,
				[_cache,_enyUnits2]
			] call CBA_fnc_addPerFrameHandler;
		};
	}
] call CBA_fnc_addEventHandler;