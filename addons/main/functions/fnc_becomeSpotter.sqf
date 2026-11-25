params [["_shooter", objNull, [objNull]]];

if (isNull _shooter || {!alive _shooter} || {!isPlayer _shooter}) exitWith {};

// Enforce pairing by dropping any previous assignment first
private _currentShooter = player getVariable ["sbt_shooter", objNull];
if (!isNull _currentShooter && {_currentShooter isNotEqualTo _shooter}) then {
    call sbt_main_fnc_stopSpotting;
};

player setVariable ["sbt_shooter", _shooter, true];

// Send initial ADS state so shooter knows if we are ready
private _isReady = [cameraView isEqualTo "GUNNER", true] call sbt_main_fnc_checkOptics;

// Target event talks directly to the shooter machine over targetEvent
["sbt_pair", [player, _isReady], _shooter] call CBA_fnc_targetEvent;

[format ["Spotting for %1", name _shooter], 2] call ace_common_fnc_displayTextStructured;
 
