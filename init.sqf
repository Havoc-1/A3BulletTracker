[] execVM "scripts\XEPKEY\fn_tracerDraw.sqf";

addMissionEventHandler ["Draw3D", {
    if !(("SpottingScope" in typeOf (vehicle player) || "designator" in (currentWeapon player) || "Vector" in (currentWeapon player)) && cameraView == "Gunner") exitWith {};
    [] call XK_tracerDraw;
}];

//Interact with scope 
//Remove spotter only visible when spotter is active

_action_BecomeSpotter = ["trackBullets","Become Spotter","a3\ui_f\data\gui\rsc\rscdisplayarsenal\binoculars_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Assigned to %1 | Spotter is : %2", _target, _player];
    _target setVariable ["XK_Spotter", _player];
    _player setVariable ["XK_Spotter", _target];
    [_target] execVM "scripts\XEPKEY\fn_tracking.sqf";
    //call sqf 
    //put checks if alive 
    //delete previous spotters later if dead etc. 
  },
  {true},
  {},
  []
] call ace_interact_menu_fnc_createAction;

//To show who your unassigning yourself from
_removeSpotterModifier = {
  params ["_target", "_player", "_params", "_actionData"];
  diag_log format ["[XK_TRACE] [ACE-SELF] [%1, %2, %3]", _target, _player, _params];
  _actionData set [1, format ["Unassign Spotter from: %1", (_target getVariable "XK_Spotter")]];
};

_action_RemoveSpotter = ["untrackBullets","Unassign Spotter","ca\ui\data\marker_x_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Unassigned from: %1", _target];    
    
    _target setVariable ["XK_Spotter",nil];
    _target setVariable ["XK_Lifetime",nil];
    _target setVariable ["XK_Interval",nil];
    _target setVariable ["XK_maxDist",nil];
    _target setVariable ["XK_minRange",nil];
    _player setVariable ["XK_Impact",nil];
    _player setVariable ["XK_bulletPosSpotter",nil];
  },
  {
    private _varCheck = _player getVariable "XK_Spotter";
    !isNil "_varCheck";
  },
  {},
  [],
  "",
  5,
  [false,false,false,false,false],
  _modifierFunc
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _action_BecomeSpotter,true] call ace_interact_menu_fnc_addActionToClass;
["CAManBase", 1, ["ACE_SelfActions"], _action_RemoveSpotter, true] call ace_interact_menu_fnc_addActionToClass;

//Perhaps run initPlayerLocal code here for local only (maybe remoteExec for local?) for plug and play solution
//see seb's briefing table 