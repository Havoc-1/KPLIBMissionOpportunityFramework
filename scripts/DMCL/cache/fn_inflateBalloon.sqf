/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Inflate Balloon PFH for airlift cache
 *
 *	Arguments:
 *		0: Uplift Cache Object <OBJECT>
 *		1: Cache Balloon <OBJECT>
 *		2: Cache Parachute <OBJECT>
 *		3: Cache Balloon Inflate Rate <NUMBER>
 *		4: Original Cache Object that gets hidden <OBJECT>
 *
 *	Examples:
 *		[_cFly,_cBalloon,_cPara,_inflate,_cache] call LMO_fn_cacheFulton;
 *	
 *	Return Value: _handle PFH
 */

params ["_cFly","_cBalloon","_cPara","_inflate","_cache"];
[
	{
		(_this select 0) params ["_cFly","_cBalloon","_cPara","_inflate","_cache"];
		_cBalloon setPosATL [((getPosATL _cPara) select 0),((getPosATL _cPara) select 1),(((getPosATL _cPara) select 2)-2)];
		//[_cBalloon, _cache] call BIS_fnc_attachToRelative;
		if (getObjectScale _cBalloon <= 20 || (getPosATL _cBalloon) select 2 <= 20) then {
			_bHeight = (getPosATL _cBalloon) select 2;
			if (getObjectScale _cBalloon >= 20) then {_inflate = 0};
			if (getObjectScale _cBalloon >= 4 && getObjectScale _cBalloon < 7) then {_inflate = 0.15};
			if (getObjectScale _cBalloon >= 15) then {_inflate = 0.03};
			_cBalloon setObjectScale ((getObjectScale _cBalloon) + _inflate);
			if (!alive _cFly) then {
				[_this select 1] call CBA_fnc_removePerFrameHandler;
			};
		};
	},
	0.05,
	[_cFly,_cBalloon,_cPara,_inflate,_cache]
] call CBA_fnc_addPerFrameHandler;