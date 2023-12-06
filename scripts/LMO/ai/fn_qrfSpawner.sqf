/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to spawn QRF.
 *
 *	Arguments:
 *		0: Positon or Unit <ARRAY> OR <OBJECT> - Positon center of QRF.
 *		1: Outfit <ARRAY> - Equipment array for QRF (Refer to Outfit Params in fn_LMOinit.sqf).
 *		2: Chance to spawn <NUMBER> (Optional) - Chance from 0 to 1 to determine whether QRF is spawned. Default 1.
 *		3: Multiplier <NUMBER> (Optional) - Adds extra unit based on each player. Default 0.
 *		4: Chance to split QRF <NUMBER> (Optional) - Chance from 0 to 1 to determine whether QRF splits into two groups. Default is 0.5.
 *		5: Range of players <NUMBER> (Optional) - Range to determine whether a player is counted in the squad multiplier. Default 500.
 *		6: QRF Spawn distance <ARRAY> (Optional)
 *			0: Minimum distance from players <NUMBER>
 *			1: Distance from Position <NUMBER>
 *
 *	Example:
 *		[getPos _cache, LMO_qrfOutfit, 0.5, 1.5, 0.5, 500, [200,300]] call LMO_fn_qrfSpawner
 *		[_hvt, LMO_qrfOutfit] call LMO_fn_qrfSpawner;
 */

params ["_pos",["_outfit",LMO_qrfOutfit],["_c",1],["_m",0],["_split",0.5],["_playerRng",500],["_dist",[300,350]]];

if ( _pos isEqualType objNull) then {
	_posObj = _pos;
	_pos = getPos _posObj;
};

if (random 1 <= _c) then {

	["QRF spawner initialized.",LMO_Debug] call LMO_fn_rptSysChat;

	private _sqdOrbat = [];
	_sqdOrbat append LMO_Orbat;

	private _sqdMultiply = _m*(count ((nearestObjects [_pos, ["CAManbase", "LandVehicle"], _playerRng]) select {side _x == GRLIB_side_friendly}));
	private _sqdSize = round ((LMO_sqdSize call BIS_fnc_randomInt)+_sqdMultiply);

	//Scales squad size
	while {_sqdSize != count _sqdOrbat} do {
		if (_sqdSize < count _sqdOrbat) then {
			_sqdOrbat resize _sqdSize;
		};
		if (_sqdSize > count _sqdOrbat) then {
			private _sqdAdd = selectRandom LMO_Orbat;
			_sqdOrbat pushBack _sqdAdd;
		};
	};
	
	[format ["SqdSize: %1, SqdOrbat: %2", _sqdSize, count _sqdOrbat],LMO_Debug] call LMO_fn_rptSysChat;
	[
		{
			params ["_sqdSize","_sqdOrbat"];
			_sqdSize == count _sqdOrbat;
		},
		{
			params ["_sqdSize","_sqdOrbat","_playerRng","_pos","_dist","_split","_outfit",["_posObj",nil]];
			["Squad Orbat resized.",LMO_Debug] call LMO_fn_rptSysChat;
			private _defaultPos = [_pos, (_dist select 1), random 360] call BIS_fnc_relPos;
			private _spawnPos = [_pos,(_dist select 0),(_dist select 1),0,0,0,0,[],_defaultPos] call BIS_fnc_findSafePos;
			private _pCount = count ((nearestObjects [_spawnPos, ["CAManbase", "LandVehicle"], (_dist select 0)]) select {side _x == GRLIB_side_friendly});

			[format ["SpawnPos: %1, pCount: %2.",_spawnPos,_pCount],LMO_Debug] call LMO_fn_rptSysChat;

			//Finds spawn position for QRF
			if  (_pCount != 0) then {
				private _distAdd = _dist select 1;
				while {_pCount != 0} do {

					_spawnPos = [_pos,(_dist select 0),(_distAdd + 20)] call BIS_fnc_findSafePos;
					_pCount = count ((nearestObjects [_spawnPos, ["CAManbase", "LandVehicle"], (_dist select 0)]) select {side _x == GRLIB_side_friendly});
					
					if (_pCount == 0) exitWith {
						["QRF Spawn position found.",LMO_Debug] call LMO_fn_rptSysChat;
					};
				};
			};

			//Spawns QRF
			[
				{
					params ["_pCount"];
					_pCount == 0;
				},
				{
					params ["_pCount","_spawnPos","_sqdSize","_sqdOrbat","_split","_playerRng","_pos","_dist","_outfit",["_posObj",nil]];
					["Spawning QRF.",LMO_Debug] call LMO_fn_rptSysChat;

					private _qrfCount = 0;
					private _enyUnits = createGroup east;

					{
						private _holder = _enyUnits createUnit [
							_x,
							_spawnPos,
							[],0,"NONE"
						];
						[_holder] joinSilent _enyUnits;

						_qrfCount = _qrfCount + 1;

						if (_qrfCount == _sqdSize) then {
							[format ["%1 Enemies spawned.",count units _enyUnits],LMO_Debug] call LMO_fn_rptSysChat;
						};
					} forEach _sqdOrbat;

					//QRF Split
					[
						{
							params ["_qrfCount","_sqdSize"];
							_qrfCount == _sqdSize;
						},
						{
							params ["_qrfCount","_sqdSize","_spawnPos","_playerRng","_pos","_enyUnits","_split","_dist","_outfit",["_posObj",nil]];

							if (random 1 <= _split) then {
								["Splitting QRF.",LMO_Debug] call LMO_fn_rptSysChat;
								
								private _sqd2Size = round (_sqdSize/2);
								private _defaultPos = [_pos, (_dist select 1), random 360] call BIS_fnc_relPos;
								private _spawnPos2 = [_pos,(_dist select 0),(_dist select 1),0,0,0,0,[[_spawnPos,(_dist select 0)]],[_defaultPos]] call BIS_fnc_findSafePos;
								private _pCount = count ((nearestObjects [_spawnPos2, ["CAManbase", "LandVehicle"], (_dist select 0)]) select {side _x == GRLIB_side_friendly});

								//Finds spawn position for QRF
								if  (_pCount != 0) then {
									private _distAdd = _dist select 1;
									while {_pCount != 0} do {

										_spawnPos2 = [_pos,(_dist select 0),(_distAdd + 20),0,0,0,0,[[_spawnPos,(_dist select 0)]],[_defaultPos]] call BIS_fnc_findSafePos;
										_pCount = count ((nearestObjects [_spawnPos2, ["CAManbase", "LandVehicle"], (_dist select 0)]) select {side _x == GRLIB_side_friendly});
										
										if (_pCount == 0) exitWith {
											["QRF Spawn position found.",LMO_Debug] call LMO_fn_rptSysChat;
										};
									};
								};

								//Splits QRF
								[
									{
										params ["_pCount"];
										_pCount == 0;
									},
									{
										params ["_pCount","_enyUnits","_sqdSize","_sqd2Size","_spawnPos2","_outfit","_pos",["_posObj",nil]];
										private _enyUnits2 = createGroup east;
										private _sqd2Orbat = [];
										for "_i" from _sqd2Size to _sqdSize do {
											private _sqd2Unit = selectRandom units _enyUnits;
											_sqd2Orbat pushBack _sqd2Unit;
											_sqd2Unit setPos _spawnPos2;
										};
										_sqd2Orbat joinSilent _enyUnits2;
										
										if (LMO_VCOM_On == true) then {
											_enyUnits setVariable ["VCM_NORESCUE",true];
											_enyUnits2 setVariable ["VCM_NORESCUE",true];
										};

										{
											[_x, _outfit] call LMO_fn_enyOutfit;
										}forEach units _enyUnits;
										{
											[_x, _outfit] call LMO_fn_enyOutfit;
										}forEach units _enyUnits2;
										["Outfit and equipment assigned to enemy units.",LMO_Debug] call LMO_fn_rptSysChat;

										if (!isNil "_posObj") then {
											[_enyUnits,_pos,_posObj] call LMO_fn_qrfAttackDel;
											[_enyUnits2,_pos,_posObj] call LMO_fn_qrfAttackDel;
										} else {
											[_enyUnits,_pos] call LMO_fn_qrfAttackDel;
											[_enyUnits2,_pos] call LMO_fn_qrfAttackDel;
										};
	
										[format ["QRF Size: %1, QRF Dir: %2, QRF2 Dir: %3.", _sqdSize, round(_pos getDir (selectRandom units _enyUnits)), round(_pos getDir _spawnPos2)],LMO_Debug] call LMO_fn_rptSysChat;
										
									},
									[_pCount,_enyUnits,_sqdSize,_sqd2Size,_spawnPos2,_outfit,_pos,_posObj]
								] call CBA_fnc_waitUntilandExecute;
							} else {
								[format ["QRF Size: %1, QRF Dir: %2.", _sqdSize, round(_pos getDir (selectRandom units _enyUnits))],LMO_Debug] call LMO_fn_rptSysChat;

								{
									[_x, _outfit] call LMO_fn_enyOutfit;
								}forEach units _enyUnits;
								["Outfit and equipment assigned to enemy units.",LMO_Debug] call LMO_fn_rptSysChat;

								[_enyUnits,_pos] call LMO_fn_qrfAttackDel;
								
								if (LMO_VCOM_On == true) then {
									_enyUnits setVariable ["VCM_NORESCUE",true];
								};
							};
						},
						[_qrfCount,_sqdSize,_spawnPos,_playerRng,_pos,_enyUnits,_split,_dist,_outfit,_posObj]
					] call CBA_fnc_waitUntilandExecute;	
				},
				[_pCount,_spawnPos,_sqdSize,_sqdOrbat,_split,_playerRng,_pos,_dist,_outfit,_posObj]
			] call CBA_fnc_waitUntilandExecute;
		},
		[_sqdSize,_sqdOrbat,_playerRng,_pos,_dist,_split,_outfit,_posObj]
	] call CBA_fnc_waitUntilandExecute;

} else {
	["No QRF spawned.",LMO_Debug] call LMO_fn_rptSysChat;
};

