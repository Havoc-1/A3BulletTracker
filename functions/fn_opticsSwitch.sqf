/* 
    Author: [SGC] Xephros, [DMCL] Keystone

    Function to toggle Draw3D EH for spotter.

    Arguments:
        0: Unit <OBJECT> (Optional) - Spotter to render Draw3D.
    
    Examples:
        [_player] call XK_spotting_fnc_opticsSwitch;
    
    Return Value: None
 */

params ["_player"];
_player addEventHandler ["OpticsSwitch", {
    params ["_unit","_isADS"];
    private _opticsSwitchEH = _unit getVariable "XK_OpticsSwitch";
    if (isNil "_opticsSwitchEH") then {
    _unit setVariable ["XK_OpticsSwitch",[_thisEvent,_thisEventHandler]];
    diag_log format ["[XK_Trace] [ACE-INTERACT] Added OpticsSwitch EH (%2) to %1", player, player getVariable "XK_OpticsSwitch"];
    };
    
    private _shooter = _unit getVariable ["XK_Spotter",objNull];
    
    //If no shooter, remove EH
    if (!alive _shooter) exitWith {
    //private _OpticsSwitchEH = _unit getVariable "XK_OpticsSwitch";
    diag_log format ["[XK_Trace] [OpticsSwitch EH] No shooter Found, exiting & removing EH %1 from %2",_OpticsSwitchEH, _unit];
    _unit removeEventHandler [_thisEvent, _thisEventHandler];
    _unit setVariable ["XK_Spotter", nil];
    };

    //If Spotter Shooter pair is different, remove EH
    private _spotterPair = _unit getVariable ["XK_Spotter",objNull];
    if (_spotterPair != _shooter) then {
    //private _OpticsSwitchEH = _unit getVariable "XK_OpticsSwitch";
    diag_log format ["[XK_Trace] [OpticsSwitch EH] Spotter (%1) is assigned to another unit (%2) exiting & removing EH",_unit,_spotterPair];
    _unit removeEventHandler [_thisEvent, _thisEventHandler];
    _unit setVariable ["XK_Spotter", nil];
    };

    if (_isADS && (
    //In vehicleClass & is Gunner
    ((typeOf (vehicle player) in XK_vehicleClassnames) && (player == gunner (vehicle player))) || 
    //Has itemClass & on Foot
    (((currentWeapon player) in XK_itemClassnames) && isNull objectParent player) ||
    //Not in vehicleClass & is not Gunner & has itemClass equipped (passenger)
    (!(typeOf (vehicle player) in XK_vehicleClassnames) && !(isNull objectParent player) && (player != gunner (vehicle player)) && ((currentWeapon player) in XK_itemClassnames))
    )) then {

        private _color = player getVariable "XK_colorVar";
        if !(isNil "_color") then {
            player setVariable ["XK_colorVar",nil];
        };

        private _color = [];
        private _light = 0;

        if (!XK_enableMinLight || ((getLighting select 1)/10) > 1) then {
            _light = 1;
        } else {
            _light = (getLighting select 1)/10;
        };

        if (XK_enableColor) then {
            _color = XK_color;
            _color pushBack _light;
        } else {
            _color = (getLighting select 0);
            _color pushback _light;
        };

        player setVariable ["XK_colorVar",_color];
        player setVariable ["XK_minLightVar",XK_minLight];
        player setVariable ["XK_textSizeVar",XK_textSize];
        player setVariable ["XK_iconSizeVar",XK_iconSize];
        diag_log format ["[XK_Trace] [fn_opticsSwitch] _color: %1", _color];

        addMissionEventHandler ["Draw3D", {
            private _Draw3D = player getVariable "XK_Draw3D";
            if (isNil "_Draw3D") then {
                player setVariable ["XK_Draw3D",[_thisEvent,_thisEventHandler]];
                diag_log format ["[XK_Trace] [OpticsSwitch EH] [Mission EH] Draw3D (%1) active on %2", player getVariable "XK_Draw3D", name player];
            };
            private _color = player getVariable ["XK_colorVar",[1,1,0,1]];
            private _minLight = player getVariable ["XK_minLightVar",0.3];
            private _textSize = player getVariable ["XK_textSizeVar",0.03];
            private _iconSize = player getVariable ["XK_iconSizeVar", 0.3];
            [player, _color, _minLight, _textSize, _iconSize] call XK_spotting_fnc_tracerDraw;
        }];
    } else {
        private _Draw3D = player getVariable "XK_Draw3D";
        diag_log format ["[XK_Trace] [OpticsSwitch EH] Draw3D EH (%1) removed from %2. isADS: %3, inVehicle: %4, inVehicleClass: %5, equippedItemClass: %6",_Draw3D, name player, cameraView == "Gunner", !(isNull objectParent player), (typeOf (vehicle player) in XK_vehicleClassnames),((currentWeapon player) in XK_itemClassnames)];
        removeMissionEventHandler _Draw3D;
        player setVariable ["XK_Draw3D",nil];
        player setVariable ["XK_colorVar",nil];
        player setVariable ["XK_minLightVar",nil];
        player setVariable ["XK_textSizeVar",nil];
        player setVariable ["XK_iconSizeVar",nil];
    };
}];