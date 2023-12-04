params ["_target"];

private _radius = 10; 
_nearbyVics = nearestObjects [_target, ["Car", "Tank", "Helicopter", "Plane"], _radius];

_fieldRepair = {
  //here you need define params what you are passing in code
  params ["_nearbyVics"];
    {
        _vic = _x;
        _vic setDamage 0;
    } forEach _nearbyVics;
};

if ((count _nearbyVics) == 0 ) exitWith {hintSilent "No vehicles to repair in radius"};

private _time = 10 * (count _nearbyVics);
[_time, _nearbyVics, _fieldRepair, {hint "Repairing cancelled"}, "Field Repair"] call ace_common_fnc_progressBar;

