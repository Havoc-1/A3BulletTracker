if (!sbt_enabled) exitWith {};

params ["_unit", "", "", "", "_ammo", "", "_projectile"];

private _spotter = _unit getVariable ["sbt_spotter", objNull];
if (isNull _spotter || {!alive _spotter}) exitWith {};
if (isNull _projectile) exitWith {};

// Enforces physical proximity between shooter and spotter
if (_unit distanceSqr _spotter > sbt_maxSpotterDistSqr) exitWith {};

// Skip tracking entirely if spotter is not looking through optics
if !(_spotter getVariable ["sbt_ready", false]) exitWith {};

// Cache isKindOf to avoid expensive config lookups during bursts
private _isBullet = sbt_ammoBulletCache get _ammo;
if (isNil "_isBullet") then {
    _isBullet = _ammo isKindOf "BulletCore";
    sbt_ammoBulletCache set [_ammo, _isBullet];
};
if (!_isBullet) exitWith {};

// Check initial velocity
private _initVel = velocity _projectile;
if (vectorMagnitudeSqr _initVel < sbt_minVelocitySqr) exitWith {};

sbt_shotCounter = sbt_shotCounter + 1;
private _traceKey = str sbt_shotCounter;
private _startPosASL = getPosASL _projectile;
private _nowShot = CBA_missionTime;

// HitPart captures exact engine impact coords without relying on post-despawn raycasts
private _impactState = [false, []];
_projectile setVariable ["sbt_impactState", _impactState];
_projectile addEventHandler ["HitPart", {
    params ["_firstHit"];
    if (!isNil "_firstHit" && {_firstHit isNotEqualTo []}) then {
        _firstHit params ["", "", "_proj", "_posASL"];
        private _state = _proj getVariable ["sbt_impactState", []];
        if (_state isNotEqualTo []) then {
            _state set [0, true];
            _state set [1, _posASL];
        };
    };
}];

// Send initial muzzle point immediately so spotter can allocate the trace buffer early
private _initialPoint = [_startPosASL, 0];
private _meta = [round (vectorMagnitude _initVel), _initVel];
["sbt_traceChunk", [_traceKey, [_initialPoint], _meta], _spotter] call CBA_fnc_targetEvent;

if (isNil "sbt_trackedQueue") then { sbt_trackedQueue = []; };
sbt_trackedQueue pushBack [
    _projectile,
    _spotter,
    _traceKey,
    _meta,
    _nowShot,
    _startPosASL,
    _impactState,
    [_initialPoint],
    [],
    _startPosASL,
    _nowShot,
    false
];

if (isNil "sbt_trackPfhId" || {sbt_trackPfhId == -1}) then {
    sbt_trackPfhId = [{
        params ["", "_pfhId"];
        private _queue = sbt_trackedQueue;

        // Auto-kill PFH when queue clears to maintain 0.00ms idle overhead
        if (_queue isEqualTo []) exitWith {
            [_pfhId] call CBA_fnc_removePerFrameHandler;
            sbt_trackPfhId = -1;
        };

        private _now = CBA_missionTime;
        private _maxDistSqr = sbt_maxTrackDistSqr;

        private [
            "_entry", "_proj", "_spotter", "_startTime", "_startPosASL",
            "_impactState", "_pending", "_lastPosASL", "_elapsed",
            "_impacted", "_finished", "_curPosASL", "_pt", "_meta",
            "_finalPosASL"
        ];

        // Step backwards so deleteAt does not corrupt index traversal
        for "_idx" from (count _queue - 1) to 0 step -1 do {
            _entry = _queue # _idx;
            _proj = _entry # 0;
            _spotter = _entry # 1;

            if (isNull _spotter || {!alive _spotter}) then {
                _queue deleteAt _idx;
                continue;
            };

            _startTime = _entry # 4;
            _startPosASL = _entry # 5;
            _impactState = _entry # 6;
            _pending = _entry # 8;
            _lastPosASL = _entry # 9;

            _elapsed = _now - _startTime;
            _impacted = _impactState # 0;
            _finished = false;

            if (!_impacted && {!isNull _proj}) then {
                _curPosASL = getPosASL _proj;

                // 4m^2 delta prevents recording zero-movement points if physics stalls
                if (_curPosASL distanceSqr _lastPosASL > 4) then {
                    _pt = [_curPosASL, _elapsed];
                    _pending pushBack _pt;
                    _entry set [9, _curPosASL];
                };

                // Guard against skybox/ocean shots running infinitely
                if (_curPosASL distanceSqr _startPosASL > _maxDistSqr || {_elapsed > 8}) then {
                    _finished = true;
                };
            } else {
                _finished = true;
            };

            // 50ms chunking balances smooth spline arrival against network packet rate
            if (!_finished && {(_now - (_entry # 10)) >= 0.05} && {_pending isNotEqualTo []}) then {
                _meta = if (_entry # 11) then { [] } else { _entry set [11, true]; _entry # 3 };
                ["sbt_traceChunk", [_entry # 2, +_pending, _meta], _spotter] call CBA_fnc_targetEvent;
                _pending resize 0;
                _entry set [10, _now];
            };

            if (_finished) then {
                _queue deleteAt _idx;
                _finalPosASL = if (_impacted && {(_impactState # 1) isNotEqualTo []}) then {
                    _impactState # 1
                } else {
                    _entry # 9
                };
                _pending pushBack [_finalPosASL, _elapsed];
                _meta = if (_entry # 11) then { [] } else { _entry set [11, true]; _entry # 3 };
                ["sbt_traceImpact", [_entry # 2, +_pending, _meta], _spotter] call CBA_fnc_targetEvent;
            };
        };

        if (_queue isEqualTo []) then {
            [_pfhId] call CBA_fnc_removePerFrameHandler;
            sbt_trackPfhId = -1;
        };
    }, 0.02] call CBA_fnc_addPerFrameHandler;
};
