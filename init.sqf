[] execVM "scripts\XEPKEY\fn_tracerDraw.sqf";

_action_BecomeSpotter = ["trackBullets","Become Spotter","a3\ui_f\data\gui\rsc\rscdisplayarsenal\binoculars_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Assigned to %1 | Spotter is : %2", _target, _player];
    _target setVariable ["XK_Spotter", _player];
    _player setVariable ["XK_Spotter", _target];
    [_target] execVM "scripts\XEPKEY\fn_tracking.sqf";

    _player addEventHandler ["OpticsSwitch", {
      params ["_unit","_isADS"];
      _unit setVariable ["XK_OpticsSwitch",[_thisEvent,_thisEventHandler]];
      
      private _shooter = _unit getVariable ["XK_Spotter",objNull];
      
      //If no shooter, remove EH
      if (!alive _shooter) exitWith {
        private _OpticsSwitchEH = _unit getVariable "XK_OpticsSwitch";
        diag_log format ["[XK_Trace] [OpticsSwitch EH] No shooter Found, exiting & removing EH %1 from %2",_OpticsSwitchEH, _unit];
        _unit removeEventHandler [_thisEvent, _thisEventHandler];
        _unit setVariable ["XK_Spotter", nil];
      };

      //If Spotter Shooter pair is different, remove EH
      private _spotterPair = _unit getVariable ["XK_Spotter",objNull];
      if (_spotterPair != _shooter) then {
        private _OpticsSwitchEH = _unit getVariable "XK_OpticsSwitch";
        diag_log format ["[XK_Trace] [OpticsSwitch EH] Spotter (%1) is assigned to another unit (%2) exiting & removing EH",_unit,_spotterPair];
        _unit removeEventHandler [_thisEvent, _thisEventHandler];
        _unit setVariable ["XK_Spotter", nil];
      };

      if (_isADS && (("SpottingScope" in typeOf (vehicle player) || "designator" in (currentWeapon player) || "Vector" in (currentWeapon player)))) then {
        addMissionEventHandler ["Draw3D", {
          private _Draw3D = player getVariable "XK_Draw3D";
          if (isNil "_Draw3D") then {
            player setVariable ["XK_Draw3D",[_thisEvent,_thisEventHandler]];
            diag_log format ["[XK_Trace] [MISSION-EH] Draw3D active on %1, EH: %2", player, player getVariable "XK_Draw3D"];
          };
          [] call XK_tracerDraw;
        }];
        
      } else {
        private _Draw3D = player getVariable "XK_Draw3D";
          diag_log format ["[XK_Trace] [MISSION-EH] Draw3D removed from %1. SpottingScope %2, Designator %3, Vector %4, Gunner %5, Draw3D %6", player,"SpottingScope" in typeOf (vehicle player),"designator" in (currentWeapon player),"Vector" in (currentWeapon player),cameraView == "Gunner", _Draw3D];
          removeMissionEventHandler _Draw3D;
          player setVariable ["XK_Draw3D",nil];
      };
    }];
    diag_log format ["[XK_Trace] [EH] Added OpticsSwitch EH to %1, EH: %2 (doesnt fetch properly yet)", player, player getVariable "XK_OpticsSwitch"];

    //Visual prompt
    ["ace_common_displayTextStructured", [format ["%1 is now spotting for you",name _player], 1.5, _target], [_target]] call CBA_fnc_targetEvent;
    ["ace_common_displayTextStructured", [format ["Your are now spotting for %1", name _target], 1.5, _player], [_player]] call CBA_fnc_targetEvent;
    //call sqf 
    //put checks if alive 
    //delete previous spotters later if dead etc. 
  },
  {
    ((_player getVariable ["XK_Spotter",objNull]) != _target) && alive _target
  },
  {},
  []
] call ace_interact_menu_fnc_createAction;

//To show who your unassigning yourself from
_removeSpotterModifier = {
  params ["_target", "_player", "_params", "_actionData"];
  diag_log format ["[XK_TRACE] [ACE-SELF] [%1, %2, %3]", _target, _player, _params];
  _actionData set [1, format ["Stop Spotting for: %1", name (_target getVariable "XK_Spotter")]];
};

_action_RemoveSpotter = ["untrackBullets","Unassign Spotter","ca\ui\data\marker_x_ca.paa",
  {     
    params ["_target", "_player", "_params"];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Unassigned from: %1", _target];    
    
    //Visual prompt
    ["ace_common_displayTextStructured", [format ["You are no longer spotting for %1", name (_target getVariable "XK_Spotter")], 1.5, _player], [_player]] call CBA_fnc_targetEvent;

    //Remove OpticsSwitch EH from Spotter
    private _OpticsSwitchEH = _player getVariable "XK_OpticsSwitch";
    if !(isNil "_OpticsSwitchEH") then {_player removeEventHandler _OpticsSwitchEH};
    diag_log format ["[XK_Trace] [ACE-INTERACT] Removed OpticsSwitchEH from: %1, EH: %2", _player, _OpticsSwitchEH];  

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
    private _varCheck = _player getVariable "XK_Spotter";
    !isNil "_varCheck";
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

//Perhaps run initPlayerLocal code here for local only (maybe remoteExec for local?) for plug and play solution
//see seb's briefing table 