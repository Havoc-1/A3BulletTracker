//Interact with scope 
// Remvoe spotter only visible when spotter is active

_action_BecomeSpotter = ["trackBullets","Become Spotter","a3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    hint format ["Assigned to %1 | Spotter is : %2", _target, _player];
    _target setVariable ["XK_Spotter", _player];
    _player setVariable ["XK_Spotter", _target];
    [_target, _player] execVM "scripts\XEPKEY\fn_tracking.sqf";
    //call sqf 
    //put checks if alive 
    //delete previous spotters later if dead etc. 
  },
  {true},
  {},
  []
] call ace_interact_menu_fnc_createAction;

_action_RemoveSpotter = ["untrackBullets","Unassign Spotter","a3\ui_f\data\igui\cfg\simpletasks\types\run_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    hint format ["Unassigned from: %1", _target];    
    _target setVariable ["XK_Spotter", nil];
  },
  {true},
  {},
  []
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _action_BecomeSpotter,true] call ace_interact_menu_fnc_addActionToClass;
["CAManBase", 0, ["ACE_MainActions"], _action_RemoveSpotter,true] call ace_interact_menu_fnc_addActionToClass;