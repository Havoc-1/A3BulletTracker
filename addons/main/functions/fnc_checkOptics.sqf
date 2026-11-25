params [
    ["_isADS", false, [false]],
    ["_suppressNotify", false, [false]]
];

private _isReady = false;
private _shooter = player getVariable ["sbt_shooter", objNull];

if (sbt_enabled && {_isADS} && {!isNull _shooter} && {alive player}) then {
    private _veh = objectParent player;
    if (!isNull _veh) then {
        // Covers tripod spotting scopes without requiring manual class names
        private _vehType = toLowerANSI (typeOf _veh);
        _isReady = (_vehType in sbt_scopeVehicleMap)
            || {sbt_autoIncludeOptics && {_veh isKindOf "StaticWeapon" || {_vehType find "spotting" != -1}}};
    } else {
        // Auto-include catches any modded binoculars/designators assigned to the binocular slot
        private _curWep = currentWeapon player;
        if (_curWep isNotEqualTo "") then {
            _isReady = ((toLowerANSI _curWep) in sbt_opticItemMap)
                || {sbt_autoIncludeOptics && {_curWep isEqualTo (binocular player)}};
        };
    };
};

// Draw3D runs every frame; hook it only when ADS and kill it immediately when dropping glass
if (_isReady) then {
    if (sbt_draw3dEhId == -1) then {
        sbt_draw3dEhId = addMissionEventHandler ["Draw3D", {
            call sbt_main_fnc_draw3D;
        }];
    };
} else {
    if (sbt_draw3dEhId != -1) then {
        removeMissionEventHandler ["Draw3D", sbt_draw3dEhId];
        sbt_draw3dEhId = -1;
    };
};

// Sync ADS state so shooter does not waste CPU sampling bullets when spotter is looking away
if (_isReady isNotEqualTo sbt_localSpotterReady) then {
    sbt_localSpotterReady = _isReady;
    player setVariable ["sbt_ready", _isReady, true];

    if (!_suppressNotify && {!isNull _shooter}) then {
        ["sbt_spotterReady", [player, _isReady], _shooter] call CBA_fnc_targetEvent;
    };
};

_isReady
