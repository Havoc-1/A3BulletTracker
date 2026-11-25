#include "script_component.hpp"

// Dedicated servers have no screen or camera; exit immediately to maintain 0.00ms server footprint
if (!hasInterface) exitWith {};

sbt_localSpotterReady = false;
sbt_draw3dEhId = -1;
sbt_activeTraces = [];
sbt_traceIndexMap = createHashMap;
sbt_shotCounter = 0;
sbt_ammoBulletCache = createHashMap;
sbt_cachedLightMult = 1;
sbt_nextLightCheck = -1;

["sbt_pair", {
    _this call sbt_main_fnc_handlePairRequest;
}] call CBA_fnc_addEventHandler;

["sbt_unpair", {
    _this call sbt_main_fnc_handleUnpair;
}] call CBA_fnc_addEventHandler;

["sbt_spotterReady", {
    params ["_spotter", "_isReady"];
    if (isNull _spotter) exitWith {};
    _spotter setVariable ["sbt_ready", _isReady];
}] call CBA_fnc_addEventHandler;

["sbt_traceChunk", {
    ["chunk", _this] call sbt_main_fnc_receiveTrace;
}] call CBA_fnc_addEventHandler;

["sbt_traceImpact", {
    ["impact", _this] call sbt_main_fnc_receiveTrace;
}] call CBA_fnc_addEventHandler;

player addEventHandler ["OpticsSwitch", {
    params ["", "_isADS"];
    [_isADS] call sbt_main_fnc_checkOptics;
}];

player addEventHandler ["GetInMan", {
    params ["", "_role"];
    if (_role isEqualTo "gunner") then {
        [cameraView isEqualTo "GUNNER"] call sbt_main_fnc_checkOptics;
    };
}];

player addEventHandler ["GetOutMan", {
    [false] call sbt_main_fnc_checkOptics;
}];

// Clean up references on death so dead bodies don't retain ghost pairings or leak Draw3D
player addEventHandler ["Killed", {
    call sbt_main_fnc_stopSpotting;
    player setVariable ["sbt_spotter", objNull, true];
    player setVariable ["sbt_shooter", objNull, true];
    player setVariable ["sbt_ready", false, true];
}];

player addEventHandler ["Respawn", {
    [false] call sbt_main_fnc_checkOptics;
}];

call sbt_main_fnc_initInteractions;
