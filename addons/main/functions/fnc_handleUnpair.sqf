params [["_sender", objNull, [objNull]]];

private _currentSpotter = player getVariable ["sbt_spotter", objNull];

// Verify sender is our actual spotter so unrelated players cannot unhook us
if (!isNull _sender && {_sender isEqualTo _currentSpotter}) then {
    player setVariable ["sbt_spotter", objNull, true];

    // Detach FiredMan entirely so shooter returns to no CPU usage
    private _ehId = player getVariable ["sbt_firedEhId", -1];
    if (_ehId != -1) then {
        player removeEventHandler ["FiredMan", _ehId];
        player setVariable ["sbt_firedEhId", -1];
    };

    [format ["%1 stopped spotting for you", name _sender], 2] call ace_common_fnc_displayTextStructured;
};
