params ["_type", "_payload"];

if (!sbt_localSpotterReady) exitWith {};

private _now = CBA_missionTime;
private _traceKey = _payload # 0;
private _rawPoints = _payload # 1;
private _meta = _payload # 2;

private _trace = sbt_traceIndexMap getOrDefault [_traceKey, []];

if (_trace isEqualTo []) then {
    // Evict oldest completed traces to keep Draw3D render time bounded during rapid fire
    private _maxTraces = round sbt_maxTraces;
    while {count sbt_activeTraces >= _maxTraces} do {
        private _evictIdx = sbt_activeTraces findIf { _x # 2 };
        if (_evictIdx == -1) then { _evictIdx = 0; };
        private _dropped = sbt_activeTraces deleteAt _evictIdx;
        sbt_traceIndexMap deleteAt (_dropped # 0);
    };

    // Align shooter elapsed flight time with spotter local clock
    private _latestElapsed = if (_rawPoints isNotEqualTo []) then { (_rawPoints # -1) # 1 } else { 0 };
    private _localStart = _now - _latestElapsed;

    private _initSpeed = if (_meta isNotEqualTo []) then { _meta # 0 } else { 800 };
    private _initVel = if (count _meta > 1) then { _meta # 1 } else { [0, 0, 0] };

    // Tuple layout: [key, posArr, impacted, localStart, rawASL, bakedCursor, renderCursor, timeArr, velEst, dragFactor, impactPosAGL, impactTime]
    _trace = [
        _traceKey,
        [],
        false,
        _localStart,
        [],
        0,
        1,
        [],
        _initVel,
        _initSpeed * 0.00045,
        [],
        -1
    ];
    sbt_activeTraces pushBack _trace;
    sbt_traceIndexMap set [_traceKey, _trace];
};

private _posArr = _trace # 1;
private _localStart = _trace # 3;
private _rawASL = _trace # 4;
private _timeArr = _trace # 7;

// Keep raw points in ASL so terrain elevation variations beneath the bullet do not distort the curve
{
    _rawASL pushBack [_x # 0, _localStart + (_x # 1)];
} forEach _rawPoints;

private _n = count _rawASL;
private _weights = sbt_splineWeights;
private _baked = _trace # 5;

if (_n > 0 && {_posArr isEqualTo []}) then {
    private _first = _rawASL # 0;
    _posArr pushBack (ASLToAGL (_first # 0));
    _timeArr pushBack (_first # 1);
};

private _isImpact = _type isEqualTo "impact";

// Catmull-Rom requires 4 control points; terminal impacts clamp the final endpoint to connect cleanly
private _endSpan = [_n - 3, _n - 2] select _isImpact;

if (_endSpan >= _baked) then {
    private [
        "_p0", "_t0", "_e1", "_p1", "_t1", "_e2", "_p2", "_t2", "_p3", "_t3",
        "_dt", "_dt02", "_dt13", "_v1", "_v2", "_m1", "_m2",
        "_chord", "_maxM", "_ptASL"
    ];
    for "_i" from _baked to _endSpan do {
        private _i0 = (_i - 1) max 0;
        private _i3 = (_i + 2) min (_n - 1);

        _p0 = (_rawASL # _i0) # 0;
        _t0 = (_rawASL # _i0) # 1;

        _e1 = _rawASL # _i;
        _p1 = _e1 # 0;
        _t1 = _e1 # 1;

        _e2 = _rawASL # (_i + 1);
        _p2 = _e2 # 0;
        _t2 = _e2 # 1;

        _p3 = (_rawASL # _i3) # 0;
        _t3 = (_rawASL # _i3) # 1;

        _dt = (_t2 - _t1) max 0.0001;
        _dt02 = (_t2 - _t0) max 0.001;
        _dt13 = (_t3 - _t1) max 0.001;

        // Tangents normalized by elapsed flight time so variable frame rates do not cause overshoot
        _v1 = (_p2 vectorDiff _p0) vectorMultiply (1 / _dt02);
        _v2 = (_p3 vectorDiff _p1) vectorMultiply (1 / _dt13);

        _m1 = _v1 vectorMultiply _dt;
        _m2 = _v2 vectorMultiply _dt;

        // Clamp tangents to prevent overshoot loops during abrupt velocity changes
        _chord = _p2 vectorDiff _p1;
        _maxM = (vectorMagnitude _chord) * 1.25;
        if (vectorMagnitudeSqr _m1 > _maxM * _maxM) then {
            _m1 = (vectorNormalized _m1) vectorMultiply _maxM;
        };
        if (vectorMagnitudeSqr _m2 > _maxM * _maxM) then {
            _m2 = (vectorNormalized _m2) vectorMultiply _maxM;
        };

        {
            _ptASL = (
                ((_p1 vectorMultiply (_x # 0)) vectorAdd (_m1 vectorMultiply (_x # 1)))
                vectorAdd
                ((_p2 vectorMultiply (_x # 2)) vectorAdd (_m2 vectorMultiply (_x # 3)))
            );
            // Convert to AGL once baked so Draw3D gets fast, terrain-aligned display coordinates
            _posArr pushBack (ASLToAGL _ptASL);
            _timeArr pushBack (_t1 + _dt * (_x # 4));
        } forEach _weights;
    };
    _trace set [5, _endSpan + 1];

    // Estimate instantaneous velocity at the leading tip to extrapolate between 50ms chunk arrivals
    private _pCnt = count _posArr;
    if (_pCnt >= 2) then {
        private _segDt = ((_timeArr # -1) - (_timeArr # (_pCnt - 2))) max 0.005;
        private _vEst = ((_posArr # -1) vectorDiff (_posArr # (_pCnt - 2))) vectorMultiply (1 / _segDt);
        _trace set [8, _vEst];
        _trace set [9, (vectorMagnitude _vEst) * 0.00045];
    };
};

if (_isImpact) then {
    _trace set [2, true];

    if (_rawASL isNotEqualTo []) then {
        private _terminalPt = _rawASL # -1;
        _trace set [10, ASLToAGL (_terminalPt # 0)];
        _trace set [11, _now];
    };
};
