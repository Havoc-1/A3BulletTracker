//Get setting information from fn_spotter_settings.sqf
private _vehicleClassnames = ["XK_vehicleClassnames"] call CBA_fnc_getSetting;
private _itemClassnames = ["XK_itemClassnames"] call CBA_fnc_getSetting;

addMissionEventHandler ["Draw3D", {
    if !((typeOf (vehicle player) in _vehicleClassnames || (currentWeapon player) in _itemClassnames) && cameraView == "Gunner") exitWith {};
    [] call fn_tracerDraw;
}];

_action_BecomeSpotter = ["trackBullets","Become Spotter","a3\ui_f\data\gui\rsc\rscdisplayarsenal\binoculars_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Assigned to %1 | Spotter is : %2", _target, _player];
    _target setVariable ["XK_Spotter", _player];
    _player setVariable ["XK_Spotter", _target];
    [_target] execVM fn_tracking;

    //Visual prompt
    ["ace_common_displayTextStructured", [format ["%1 is now spotting for you", name (_player getVariable "XK_Spotter")], 1.5, _target], [_target]] call CBA_fnc_targetEvent;

  },
  {true},
  {},
  []
] call ace_interact_menu_fnc_createAction;

//To show who your unassigning yourself from
_removeSpotterModifier = {
  params ["_target", "_player", "_params", "_actionData"];
  diag_log format ["[XK_TRACE] [ACE-SELF] [%1, %2, %3]", _target, _player, _params];
  _actionData set [1, format ["Stop spotting for: %1", name (_target getVariable "XK_Spotter")]];
};

_action_RemoveSpotter = ["untrackBullets","Unassign Spotter",["ca\ui\data\marker_x_ca.paa","#FF0000"],
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Unassigned from: %1", _target];    
    
    //Visual prompt
    ["ace_common_displayTextStructured", [format ["You are no longer spotting for %1", name (_target getVariable "XK_Spotter")], 1.5, _player], [_player]] call CBA_fnc_targetEvent;

    _target setVariable ["XK_Spotter",nil];
    _target setVariable ["XK_Lifetime",nil];
    _target setVariable ["XK_Interval",nil];
    _target setVariable ["XK_maxDist",nil];
    _target setVariable ["XK_minRange",nil];
    _player setVariable ["XK_Impact",nil];
    _player setVariable ["XK_bulletPosSpotter",nil];
  },
  {
    !isNull (_player getVariable ["XK_Spotter",objNull]);
  },
  {},
  [],
  "",
  5,
  [false,false,false,false,false],
  _removeSpotterModifier
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _action_BecomeSpotter,true] call ace_interact_menu_fnc_addActionToClass;
["CAManBase", 1, ["ACE_SelfActions"], _action_RemoveSpotter, true] call ace_interact_menu_fnc_addActionToClass;