params [
    ["_spotter", objNull, [objNull]],
    ["_isReady", false, [false]]
];

if (isNull _spotter || {!alive _spotter}) exitWith {};

// Only allow one spotter at a time; notify previous spotter if replaced
private _oldSpotter = player getVariable ["sbt_spotter", objNull];
if (!isNull _oldSpotter && {_oldSpotter isNotEqualTo _spotter}) then {
    ["sbt_unpair", [player], _oldSpotter] call CBA_fnc_targetEvent;
};

player setVariable ["sbt_spotter", _spotter, true];
_spotter setVariable ["sbt_ready", _isReady];

// Attach FiredMan on-demand so trigger pulls cost zero CPU when nobody is spotting
private _ehId = player getVariable ["sbt_firedEhId", -1];
if (_ehId == -1) then {
    _ehId = player addEventHandler ["FiredMan", {
        _this call sbt_main_fnc_onFired;
    }];
    player setVariable ["sbt_firedEhId", _ehId];
};

[format ["%1 is now your spotter", name _spotter], 2] call ace_common_fnc_displayTextStructured;
