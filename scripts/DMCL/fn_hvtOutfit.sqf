//Randomizes HVT outfit based on LMO_hvtOutfit parameters in LMOinit.sqf

if (LMO_hvtOutfit select 0 == true) then {
	_noHdgr = random ((count LMO_hvtHead) + 1);
	if (_noHdgr <= 1 && ((LMO_hvtNone select 0) == true)) then {
		removeHeadgear _hvt;
	} else {
		removeHeadgear _hvt;
		if (count LMO_hvtHead > 0) then {_hvt addHeadGear selectRandom LMO_hvtHead};
	};
};
if (LMO_hvtOutfit select 1 == true) then {
	removeGoggles _hvt;
	if (count LMO_hvtGog > 0) then {_hvt addGoggles selectRandom LMO_hvtGog};
};
if (LMO_hvtOutfit select 2 == true) then {
	_hvtVestItems = vestItems _hvt;
	removeVest _hvt;
	if (count LMO_hvtVest > 0) then {
		_hvt addVest selectRandom LMO_hvtVest;
		{if (_hvt canAddItemToVest _x) then {_hvt addItemToVest _x}}forEach _hvtVestItems;
	};
};
if (LMO_hvtOutfit select 3 == true) then {
	_hvtUniItems = uniformItems _hvt;
	removeUniform _hvt;
	if (count LMO_hvtVest > 0) then { 
		_hvt forceAddUniform selectRandom LMO_hvtUni;
		{if (_hvt canAddItemToUniform _x) then {_hvt addItemToUniform _x}}forEach _hvtUniItems;
	};
};
if (LMO_hvtOutfit select 4 == true) then {
	_hvtBpkItems = backpackItems _hvt;
	_noBpk = random ((count LMO_hvtBpk) + 1);
	systemChat format ["noBpk: %1", _noBpk];
	if (_noBpk <= 1 && ((LMO_hvtNone select 1) == true)) then {
		removeBackpack _hvt;
	} else {
		removeBackpack _hvt;
		if (count LMO_hvtBpk > 0) then { 
			_hvt addBackpack selectRandom LMO_hvtBpk;
			{if (_hvt canAddItemToBackpack _x) then {_hvt addItemToBackpack _x}}forEach _hvtBpkItems;
		};
	};
};
if (LMO_hvtOutfit select 5 == true) then {
	_noNvg = random ((count LMO_hvtNVG) + 1);
	if (_noNVG <= 1 && ((LMO_hvtNone select 2) == true)) then {
		_hvt unassignItem hmd _hvt;
	} else {
		if (count LMO_hvtNVG > 0) then {
			_hvt linkItem selectRandom LMO_hvtNVG;
		};
	};
};
if (LMO_hvtOutfit select 6 == true) then {
	removeAllWeapons _hvt;
	if (count LMO_hvtWeap > 0) then {
		_hvtWeap = selectRandom LMO_hvtWeap;
		_hvt addWeapon (_hvtWeap select 0);
		_hvt addMagazines [(_hvtWeap select 1),(_hvtWeap select 2)];
	};
};