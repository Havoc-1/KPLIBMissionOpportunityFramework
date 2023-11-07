if ((!isServer) && (player != player)) then {waitUntil {player == player};};
enableSaving [ false, false ];

[] execVM "scripts\DMCL\fn_LMOinit.sqf";										//Liberation Side Ops

//To allow diary entries to run post-init
[] spawn {
    waitUntil {missionNamespace getVariable ["BIS_fnc_init", false]};
    [[] call XEPKEY_fn_diaryContent call BIS_fnc_execVM];
};
