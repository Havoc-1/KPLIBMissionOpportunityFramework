//Randomizes HVT outfit based on LMO_hvtOutfit parameters in LMOinit.sqf
/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to apply custom loadouts to unit.
 *	
 *	Arguments:
 *		0: Unit <OBJECT> - Unit to apply outfit
 *		
 *		1: Outfit Array <ARRAY> - Large array containing arrays for unit outfit and booleans to enable custom equipment.
 *			0: Outfit <ARRAY> - An array containing arrays of item class name strings.
 *				0: Headgear <ARRAY>
 *				1: Goggles <ARRAY>
 *				2: Vest <ARRAY>
 *				3: Uniform <ARRAY>
 *				4: Backpack <ARRAY>
 *				5: NVG <ARRAY>
 *				6: Weapon <ARRAY>
 *					0: Weapon Class Name <STRING>
 *					1: Magazine Class Name <STRING>
 *					2: Magazine Quantity <NUMBER> (Optional)
 *					3: Optic Class Name <STRING> (Optional)
 *					4: Muzzle Class Name <STRING> (Optional)
 *					5: Rail Attachment Class Name <STRING> (Optional)
 *					6: Inventory Items <ARRAY> (Optional)
 *						0: Item Class Name <STRING>
 *						1: Quantity <NUMBER>
 *					7: Secondary Magazine Class Name <STRING> (Optional)
 *					8: Secondary Magazine Quantity <NUMBER> (Optional)
 *
 *			1: Boolean array enable custom equipment <ARRAY> (Optional)
 *				0: Headgear <BOOL>
 *				1: Goggles <BOOL>
 *				2: Vest <BOOL>
 *				3: Uniform <BOOL>
 *				4: Backpack <BOOL>
 *				5: NVG <BOOL>
 *				6: Weapon <BOOL>
 *		
 *			2: Boolean array to enable chance for empty equipment slot <ARRAY> (Optional)
 *				0: Headgear <BOOL>
 *				1: Backpack <BOOL>
 *				2: NVG <BOOL>
 *	
 *	Example:
 *		[man1, LMO_hvtOutfit] call LMO_fn_enyOutfit;
 *		
 *	Return Value: None
 */

params ["_unit","_eq"];
[
	{
		params ["_unit","_eq"];
		_eq params ["_outfit",["_bools",[true,true,true,true,true,true,true]],["_empty",[false,false,false]]];
		
		if (_bools select 0 == true) then {
			if ((random ((count (_outfit select 0)) + 1)) <= 1 && ((_empty select 0) == true)) then {
				removeHeadgear _unit;
			} else {
				removeHeadgear _unit;
				if (count (_outfit select 0) > 0) then {_unit addHeadGear selectRandom (_outfit select 0)};
			};
		};
		if (_bools select 1 == true) then {
			removeGoggles _unit;
			if (count (_outfit select 1) > 0) then {_unit addGoggles selectRandom (_outfit select 1)};
		};
		if (_bools select 2 == true) then {
			_vestItems = vestItems _unit;
			removeVest _unit;
			if (count (_outfit select 2) > 0) then {
				_unit addVest selectRandom (_outfit select 2);
				{if (_unit canAddItemToVest _x) then {_unit addItemToVest _x}}forEach _vestItems;
			};
		};
		if (_bools select 3 == true) then {
			_uniItems = uniformItems _unit;
			removeUniform _unit;
			if (count (_outfit select 3) > 0) then { 
				_unit forceAddUniform selectRandom (_outfit select 3);
				[
					{
						params ["_unit","_uniItems"];
						{if (_unit canAddItemToUniform _x) then {_unit addItemToUniform _x}}forEach _uniItems;
					},
					[_unit,_uniItems],
					1
				] call CBA_fnc_waitAndExecute;
			};
		};
		if (_bools select 4 == true) then {
			_bpkItems = backpackItems _unit;
			if ((random ((count (_outfit select 4)) + 1)) <= 1 && ((_empty select 1) == true)) then {
				removeBackpack _unit;
			} else {
				removeBackpack _unit;
				if (count (_outfit select 4) > 0) then { 
					_unit addBackpack selectRandom (_outfit select 4);
					[
						{
							params ["_unit","_bpkItems"];
							{if (_unit canAddItemToBackpack _x) then {_unit addItemToBackpack _x}}forEach _bpkItems;
						},
						[_unit,_bpkItems],
						1
					] call CBA_fnc_waitAndExecute;
				};
			};
		};
		if (_bools select 5 == true) then {
			if ((random ((count (_outfit select 5)) + 1)) <= 1 && ((_empty select 2) == true)) then {
				_unit unassignItem hmd _unit;
			} else {
				if (count (_outfit select 5) > 0) then {
					_unit linkItem selectRandom (_outfit select 5);
				};
			};
		};
		if (_bools select 6 == true) then {
			removeAllWeapons _unit;
			if (count (_outfit select 6) > 0) then {
				_Weap = selectRandom (_outfit select 6);
				_Weap params ["_gun","_mag",["_magCount",7],["_optic",nil],["_muzzle",nil],["_rail",nil],["_inv",nil],["_2mag",nil],["_2magCount",3]];
				_unit addWeapon _gun;
				_unit addMagazines [_mag,_magCount];
				if (!isNil "_2mag") then {
					_unit addMagazines [_2mag,_2magCount];
				};
				if (!isNil "_optic") then {
					_unit addWeaponItem [(primaryWeapon _unit),_optic, true];
				};
				if (!isNil "_muzzle") then {
					_unit addWeaponItem [(primaryWeapon _unit),_muzzle, true];
				};
				if (!isNil "_rail") then {
					_unit addWeaponItem [(primaryWeapon _unit),_rail, true];
				};
				if (!isNil "_inv" && count _inv > 0) then {
					{
						for "_i" from 1 to (_x select 1) do { 
							_unit addItem (_x select 0);
						};
					} forEach _inv;
				};
			};
		};

		//Attempts to reoutfit unit if uniform is missing
		[
			{
				params ["_unit","_eq"];
				if (uniform _unit == "") then {
					[_unit,_eq] call LMO_fn_enyOutfit;
				};
			},
			[_unit,_eq],
			10
		] call CBA_fnc_waitAndExecute;
	},
	[_unit,_eq],
	5
] call CBA_fnc_waitAndExecute;