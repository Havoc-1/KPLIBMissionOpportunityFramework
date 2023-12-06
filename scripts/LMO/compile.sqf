//Directory Path
private _path = "LMO\";

//Main
LMO_fn_missionCheck = compile preprocessFileLineNumbers format [_path + "fn_missionCheck.sqf"];
LMO_fn_getBuildings = compile preprocessFileLineNumbers format [_path + "fn_getBuildings.sqf"];
LMO_fn_markerFunctions = compile preprocessFileLineNumbers format [_path + "fn_markerFunctions.sqf"];
LMO_fn_pickMission = compile preprocessFileLineNumbers format [_path + "fn_pickMission.sqf"];
LMO_fn_mTimerAdjust = compile preprocessFileLineNumbers format [_path + "fn_mTimerAdjust.sqf"];
LMO_fn_taskCreate = compile preprocessFileLineNumbers format [_path + "fn_taskCreate.sqf"];
LMO_fn_taskState = compile preprocessFileLineNumbers format [_path + "fn_taskState.sqf"];
LMO_fn_rewards = compile preprocessFileLineNumbers format [_path + "fn_rewards.sqf"];

//AI
LMO_fn_qrfSpawner = compile preprocessFileLineNumbers format [_path + "ai\fn_qrfSpawner.sqf"];
LMO_fn_garSpawner = compile preprocessFileLineNumbers format [_path + "ai\fn_garSpawner.sqf"];
LMO_fn_qrfAttackDel = compile preprocessFileLineNumbers format [_path + "ai\fn_qrfAttackDel.sqf"];
LMO_fn_garDelete = compile preprocessFileLineNumbers format [_path + "ai\fn_garDelete.sqf"];
LMO_fn_enyOutfit = compile preprocessFileLineNumbers format [_path + "ai\fn_enyOutfit.sqf"];
LMO_fn_removeThrowables = compile preprocessFileLineNumbers format [_path + "ai\fn_removeThrowables.sqf"];

//Hostage
LMO_fn_missionHostage = compile preprocessFileLineNumbers format [_path + "hostage\fn_missionHostage.sqf"];
LMO_fn_moveHostage = compile preprocessFileLineNumbers format [_path + "hostage\fn_moveHostage.sqf"];

//HVT
LMO_fn_missionHVT = compile preprocessFileLineNumbers format [_path + "hvt\fn_missionHVT.sqf"];
LMO_fn_hvtRunner = compile preprocessFileLineNumbers format [_path + "hvt\fn_hvtRunner.sqf"];

//Cache
LMO_fn_missionCache = compile preprocessFileLineNumbers format [_path + "cache\fn_missionCache.sqf"];
LMO_fn_cacheFulton = compile preprocessFileLineNumbers format [_path + "cache\fn_cacheFulton.sqf"];
LMO_fn_inflateBalloon = compile preprocessFileLineNumbers format [_path + "cache\fn_inflateBalloon.sqf"];
LMO_fn_fultonExit = compile preprocessFileLineNumbers format [_path + "cache\fn_fultonExit.sqf"];

//Misc
LMO_fn_rptSysChat = compile preprocessFileLineNumbers format [_path + "fn_rptSysChat.sqf"];