private _becomeSpotterAction = [
    "sbt_becomeSpotter",
    "Become Spotter",
    "",
    {
        params ["_target"];
        [_target] call sbt_main_fnc_becomeSpotter;
    },
    {
        params ["_target"];
        // Only show for alive players we aren't already spotting for
        alive _target
        && {isPlayer _target}
        && {_target isNotEqualTo player}
        && {(player getVariable ["sbt_shooter", objNull]) isNotEqualTo _target}
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 0, ["ACE_MainActions"], _becomeSpotterAction, true] call ace_interact_menu_fnc_addActionToClass;

private _stopSpottingAction = [
    "sbt_stopSpotting",
    "Stop Spotting",
    "",
    {
        call sbt_main_fnc_stopSpotting;
    },
    {
        !isNull (player getVariable ["sbt_shooter", objNull])
    }
] call ace_interact_menu_fnc_createAction;

[player, 1, ["ACE_SelfActions"], _stopSpottingAction] call ace_interact_menu_fnc_addActionToObject;
