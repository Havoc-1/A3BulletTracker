/* 
    Author: [SGC] Xephros, [DMCL] Keystone

    Init file for XK_Spotting
 */

diag_log "[XK_Trace] Initializing XK_Spotter";
diag_log format ["[XK_Trace] [Init] Item Classnames: %1",XK_itemClassnames];
diag_log format ["[XK_Trace] [Init] Vehicle Classnames: %1",XK_vehicleClassnames];

private _action_BecomeSpotter = ["trackBullets","Become Spotter","a3\ui_f\data\gui\rsc\rscdisplayarsenal\binoculars_ca.paa",
  {     
    params ["_shooter", "_spotter", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Assigned to %1 | Spotter is : %2", name _shooter, name _spotter];
    _shooter setVariable ["XK_Spotter", _spotter];
    _spotter setVariable ["XK_Spotter", _shooter];
    [_shooter] call XK_spotting_fnc_tracking;
    [_spotter] call XK_spotting_fnc_opticsSwitch;

    //Visual indicator to show you are now being spotted by a person
    ["ace_common_displayTextStructured", [format ["%1 is now spotting for you",name _spotter], 1.5, _shooter], [_shooter]] call CBA_fnc_targetEvent;
    //Visual indicator to show who you are spotting for
    ["ace_common_displayTextStructured", [format ["You are now spotting for %1", name _shooter], 1.5, _spotter], [_spotter]] call CBA_fnc_targetEvent;
  },
  {
    ((_player getVariable ["XK_Spotter",objNull]) != _target) &&
    ((_target getVariable ["XK_Spotter",objNull]) != _player) &&
    alive _target
  },
  {},
  []
] call ace_interact_menu_fnc_createAction;

//To show who your unassigning yourself from
private _removeSpotterModifier = {
  params ["_target", "_player", "_params", "_actionData"];
  diag_log format ["[XK_TRACE] [ACE-SELF] [%1, %2, %3]", _target, _player, _params];
  _actionData set [1, format ["Stop spotting for: %1", name (_target getVariable "XK_Spotter")]];
};

//get new icon for remove spotter 
_action_RemoveSpotter = ["untrackBullets","Unassign Spotter",["ca\ui\data\marker_x_ca.paa","#FF0000"], 
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Unassigned from: %1", name _target];    
    
    //Visual prompt
    ["ace_common_displayTextStructured", [format ["You are no longer spotting for %1", name (_target getVariable "XK_Spotter")], 1.5, _player], [_player]] call CBA_fnc_targetEvent;

    //Remove OpticsSwitch EH from Spotter
    private _OpticsSwitchEH = _player getVariable "XK_OpticsSwitch";
    if !(isNil "_OpticsSwitchEH") then {_player removeEventHandler _OpticsSwitchEH};
    diag_log format ["[XK_Trace] [ACE-INTERACT] Removed OpticsSwitchEH from: %1, EH: %2", name _player, _OpticsSwitchEH];  

    _target setVariable ["XK_Spotter",nil];
    _target setVariable ["XK_Lifetime",nil];
    _target setVariable ["XK_Interval",nil];
    _target setVariable ["XK_maxDist",nil];
    _target setVariable ["XK_minRange",nil];
    _player setVariable ["XK_Impact",nil];
    _player setVariable ["XK_bulletPosSpotter",nil];
    _player setVariable ["XK_OpticsSwitch",nil];
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