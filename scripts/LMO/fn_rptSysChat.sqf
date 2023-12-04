
params ["_str",["_sysChat",false]];
private _mis = "Main";
private _mType = missionNamespace getVariable "LMO_MissionType";
if (isNil "_mType") then {
	_mType = 0;
};

switch (_mType) do {
	case 1: {
		_mis = "Hostage Rescue";
	};
	case 2: {
		_mis = "HVT";
	};
	case 3: {
		_mis = "Cache";
	};
	default {
		_mis = "Main";
	};
};

diag_log format ["[LMO] [%1] %2", _mis, _str];

if (_sysChat) then {
	systemChat format ["[LMO] [%1] %2", _mis, _str];
};