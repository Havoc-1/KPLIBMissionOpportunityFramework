/*	
 *	Author: [ANTEC] Xephros, [DMCL] Keystone
 *	Function to update LMO Timer, Marker Color, Marker Position and Marker Radius	
 *
 *	Arguments:
 *	0: Time in seconds to Subtract from LMO_mTimer <NUMBER>
 *	1: Marker Zone Color <STRING>
 *	2: Marker Zone Position <ARRAY>
 *	3: Marker Zone Radius <NUMBER>
 *	4: Move Marker Name to Zone Position <BOOL>
 *	5: Marker Brush <STRING>
 *
 *	Example:
 *	[0,"ColorGrey",getPos player,300,false,"Solid"] call XEPKEY_fn_mTimerAdjust;
 *
 */

params ["_tSub","_color","_mkrPos","_mkrSize","_mkrNamePos","_mkrBrush"];

LMO_mTimer = LMO_mTimer - _tSub;
LMO_mTimerStr = [LMO_mTimer, "MM:SS"] call BIS_fnc_secondsToString;
LMO_MkrName setMarkerColor _color;
LMO_Mkr setMarkerColor _color;
LMO_Mkr setMarkerPos _mkrPos;
if (_mkrNamePos == true) then {LMO_MkrName setMarkerPos _mkrPos};
LMO_Mkr setMarkerSize [_mkrSize,_mkrSize];
LMO_Mkr setMarkerBrush _mkrBrush;