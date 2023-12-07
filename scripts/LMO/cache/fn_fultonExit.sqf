/* 
 *	Author: [SGC] Xephros, [DMCL] Keystone
 *	Function to fulton airlift cache.
 *
 *	Arguments:
 *		0: Cache <OBJECT>
 *		1: Task Array <ARRAY>
 *			1: Parent Task <STRING>
 *			2: Child Task <STRING>
 *
 *	Examples:
 *		[_cache,_tasks] call LMO_fn_fultonExit;
 *	
 *	Return Value: None
 */

params ["_cache","_tasks"];
["LMOTaskOutcome", ["Cache preparing for uplift", "z\ace\addons\dragging\ui\icons\box_carry.paa"]] remoteExec ["BIS_fnc_showNotification"];
private _cAttached = [];
private _cPos = [];
private _cPara = objNull;
private _cFly = objNull;
private _cBalloon = objNull;
private _inflate = 0.08;
private _bRise = 3;
private _cacheRope = objNull;
private _cLight = objNull;
private _flyMax = 1000;

_cAttached = attachedObjects _cache;
if (count _cAttached > 0) then {{deleteVehicle _x} forEach _cAttached};
_cPos = getPosATL _cache;

//Hides original cache
_cache hideObjectGlobal true;
_cache allowDamage false;
_cache setDamage 0;
_cache enableSimulationGlobal false;

["fultonExit initialized.",LMO_Debug] call LMO_fn_rptSysChat;

//Creates uplift Cache
_cFly = "C_supplyCrate_F" createVehicle _cPos;
clearItemCargoGlobal _cFly;
clearWeaponCargoGlobal _cFly;
clearMagazineCargoGlobal _cFly;

//Creates Parachute
_cPara = "B_Parachute_02_F" createVehicle _cPos;
_cPara attachTo [_cFly, [0,0,7]];
detach _cPara;
_cPara hideObjectGlobal true;

//Creates Fulton Balloon and attaches to invisible Parachute
_cBalloon = createSimpleObject ["a3\structures_f_mark\items\sport\balloon_01_air_f.p3d", _cPos];
_cBalloon attachTo [_cPara, [0,0,-2]];
//detach _cBalloon;
_cPara disableCollisionWith _cFly;
_cPara disableCollisionWith _cBalloon;
_cBalloon setPosATL [(getPosATL _cPara) select 0,(getPosATL _cPara) select 1,((getPosATL _cPara) select 2)-2];
_cBalloon setObjectScale 1;

//Inflates Fulton Balloon
[_cFly,_cBalloon,_cPara,_inflate,_cache] remoteExec ["LMO_fn_inflateBalloon",0,true];

//Uplift cache setVelocity

_cacheRope = ropeCreate [_cPara, [0,0,-2],_cFly, [0,0,0.5], 30];
ropeUnwind [_cBalloon, 20, 100];
_cLight = "PortableHelipadLight_01_red_F" createVehicle getPos _cFly;
_cLight allowDamage false;
_cLight attachTo [_cFly, [0,0,0.6]];
_cacheRope allowDamage false;	

[
	{			
		(_this select 0) params ["_cFly","_cBalloon","_cPara","_cache","_bRise","_cacheRope","_cLight","_flyMax","_tasks"];
		if (alive _cFly) then {
			
			//Fail-safe to reattach cache if detaches from rope
			if ((ropeAttachedTo _cFly) != _cPara) then {
				[_cFly, [0,0,0.5], [0,0,-1]] ropeAttachTo _cacheRope;
			};

			//Changes fulton rise rate based on height
			private _bHeight = (getPosATL _cBalloon) select 2;
			if (_bHeight >= _flyMax*0.025 && _bHeight < _flyMax*0.03) then {_bRise = 1};
			if (_bHeight >= _flyMax*0.03 && _bHeight < _flyMax*0.035) then {_bRise = 6};
			if (_bHeight >= _flyMax*0.035 && _bHeight < _flyMax*0.95) then {_bRise = 20};
			_cPara setVelocity [0,0,_bRise];
			[_cPara, 0, 0] call BIS_fnc_setPitchBank;

			if (_bHeight >= _flyMax) exitWith {
				ropeDestroy _cacheRope;
				deleteVehicle _cFly;
				deleteVehicle _cBalloon;
				deleteVehicle _cPara;
				deleteVehicle _cLight;
				deleteVehicle _cache;
				["Cache successfully airlifted. Cache deleted.",LMO_Debug] call LMO_fn_rptSysChat;
				[1,_tasks] call LMO_fn_taskState;
				[LMO_Cache_Win_Alert,0,false] call LMO_fn_rewards;

				[
					{!LMO_active},
					{
						missionNamespace setVariable ["LMO_CacheTagged", nil, true];
						["LMO_CacheTagged set to nil.",LMO_Debug] call LMO_fn_rptSysChat;
					},
					[]
				] call CBA_fnc_waitUntilAndExecute;
				

				//get the nearestFOB and deliver cache boxes
				if (GRLIB_all_fobs isEqualTo []) exitWith {
					["LMOTaskOutcomeR", ["Cache lost in transit FOB not found", "\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"]] remoteExec ["BIS_fnc_showNotification"];
					[_this select 1] call CBA_fnc_removePerFrameHandler;
				};
				
				//Assigns SAF rewards
				[[LMO_Cache_supplyBoxes,LMO_Cache_ammoBoxes,LMO_Cache_fuelBoxes,getPos _cache],3] call LMO_fn_rewards;
				
				//Removes PFH
				[_this select 1] call CBA_fnc_removePerFrameHandler;
			};
		};
	},
	0.1,
	[_cFly,_cBalloon,_cPara,_cache,_bRise,_cacheRope,_cLight,_flyMax,_tasks]
] call CBA_fnc_addPerFrameHandler;