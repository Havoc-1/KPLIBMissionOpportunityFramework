params ["_cFly","_cBalloon","_cPara","_inflate","_cache"];
_handle = [];
_handle = [
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
				[_handle] call CBA_fnc_removePerFrameHandler;
			};
		};
		//[_cBalloon, ((getObjectScale _cBalloon) + _inflate)] remoteExec ["setObjectScale"];
		//_cBalloon setObjectScale ((getObjectScale _cBalloon) + _inflate);
	},
	0.05,
	[_cFly,_cBalloon,_cPara,_inflate,_cache]
] call CBA_fnc_addPerFrameHandler;