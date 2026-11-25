private _shooter = player getVariable ["sbt_shooter", objNull];

player setVariable ["sbt_shooter", objNull, true];
player setVariable ["sbt_ready", false, true];

// Notify shooter directly so they can detach FiredMan immediately
if (!isNull _shooter) then {
    ["sbt_unpair", [player], _shooter] call CBA_fnc_targetEvent;
    [format ["Stopped spotting for %1", name _shooter], 2] call ace_common_fnc_displayTextStructured;
};

// Force optics check to false to remove Draw3D handler and stop burning render frames
[false] call sbt_main_fnc_checkOptics;
