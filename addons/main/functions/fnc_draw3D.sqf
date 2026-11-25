private _traces = sbt_activeTraces;
if (_traces isEqualTo [] || {!sbt_enabled}) exitWith {};

private _visionMode = currentVisionMode player;
if (_visionMode == 1 && {!sbt_allowNVG}) exitWith {};
if (_visionMode == 2 && {!sbt_allowTI}) exitWith {};

private _now = CBA_missionTime;
private _lightMult = 1;

// Suppress vapor in darkness so it does not unnaturally glow like a tracer without NVG/TI
if (_visionMode == 0 && {sbt_enableMinLight}) then {
    if (_now >= sbt_nextLightCheck) then {
        private _ambient = ((getLighting) # 1) * 0.1;
        private _minL = sbt_minLight;
        sbt_cachedLightMult = if (_ambient < _minL) then {
            0
        } else {
            ((_ambient - _minL) / ((1 - _minL) max 0.01)) min 1 max 0.25
        };
        sbt_nextLightCheck = _now + 0.5;
    };
    _lightMult = sbt_cachedLightMult;
};
if (_lightMult <= 0) exitWith {};

private _renderNow = _now - 0.05;
private _camPos = positionCameraToWorld [0, 0, 0];
private _camDir = getCameraViewDirection player;
private _camD = _camPos vectorDotProduct _camDir;
private _camRightFallback = vectorNormalized (_camDir vectorCrossProduct [0, 0, 1]);

private _volumetric = sbt_volumetricVapor;
private _windScaled = [0, 0, 0];
private _hasWind = false;

if (_volumetric) then {
    private _w = wind;
    private _wVec = [_w # 0, _w # 1, 0];
    if (vectorMagnitudeSqr _wVec >= 0.04) then {
        _windScaled = _wVec vectorMultiply 0.18;
        _hasWind = true;
    };
};

private _vaporAlpha = sbt_vaporAlpha * _lightMult;
private _vaporLife = sbt_vaporLifetime max 0.1;
private _invVaporLife = 1 / _vaporLife;
private _expireCut = _renderNow - (_vaporLife * 0.8586);

private _vRGB = sbt_vaporColor;
private _vCol = [_vRGB # 0, _vRGB # 1, _vRGB # 2, _vaporAlpha];
private _vFlankCol = [_vRGB # 0, _vRGB # 1, _vRGB # 2, _vaporAlpha * 0.38];
private _vTipCol = [(_vRGB # 0) * 0.4 + 0.6, (_vRGB # 1) * 0.4 + 0.6, (_vRGB # 2) * 0.4 + 0.6, (_vaporAlpha * 1.35) min 1];

// Pre-declare locals to avoid allocation overhead during per-frame rendering
private [
    "_tr", "_posArr", "_timeArr", "_impacted", "_ptCount", "_stillAlive",
    "_startVis", "_endVis", "_checkSeg",
    "_cursor", "_startIdx", "_t0", "_p0", "_p1", "_t1",
    "_frac", "_tipPos", "_age", "_fade", "_age0", "_lastT", "_extDt", "_velEst", "_segDt",
    "_chord", "_billboard", "_rightBase", "_rightStep",
    "_dp0", "_dp1", "_off0", "_off1", "_l0", "_r0", "_l1", "_r1", "_hasPrev",
    "_impactTime", "_impactAge", "_impactPos", "_dist", "_iFade", "_iAlpha", "_iRGB", "_shooter"
];

for "_tIdx" from (count _traces - 1) to 0 step -1 do {
    _tr = _traces # _tIdx;
    _posArr = _tr # 1;
    _impacted = _tr # 2;
    _timeArr = _tr # 7;
    _ptCount = count _posArr;
    _stillAlive = false;

    // Fast frustum reject: skip trace math if both ends lie behind the camera plane
    _checkSeg = false;
    if (_ptCount >= 2) then {
        _startVis = ((_posArr # 0) vectorDotProduct _camDir) > _camD;
        _endVis = ((_posArr # -1) vectorDotProduct _camDir) > _camD;
        if (!_startVis && {!_endVis}) then {
            if (_ptCount > 0 && {((_timeArr # -1) > _expireCut) || {!_impacted && {(_now - (_timeArr # -1)) < 10}}}) then {
                _stillAlive = true;
            };

            // Hold trace in memory until impact icon duration has finished
            if (_impacted && {sbt_showImpactIcon}) then {
                _impactTime = _tr # 11;
                if (_impactTime > 0 && {(_now - _impactTime) < sbt_impactDuration}) then {
                    _stillAlive = true;
                };
            };

            if (!_stillAlive) then {
                sbt_traceIndexMap deleteAt (_tr # 0);
                _traces deleteAt _tIdx;
            };
            continue;
        };
        _checkSeg = !(_startVis && _endVis);
    };

    if (_ptCount >= 2) then {
        // Fast-forward cursor past segments that already faded to avoid redundant iterations
        _cursor = _tr # 6;
        while {_cursor < _ptCount && {(_timeArr # _cursor) <= _expireCut}} do {
            _cursor = _cursor + 1;
        };
        _tr set [6, _cursor];

        if (_cursor < _ptCount) then {
            // Billboard vector perpendicular to camera view and flight chord ensures ribbons face the viewer
            if (_volumetric) then {
                _chord = (_posArr # -1) vectorDiff (_posArr # 0);
                _billboard = _chord vectorCrossProduct _camDir;
                _billboard = if (vectorMagnitudeSqr _billboard > 0.001) then {
                    vectorNormalized _billboard
                } else {
                    _camRightFallback
                };
                _rightBase = _billboard vectorMultiply 0.028;
                _rightStep = _billboard vectorMultiply 0.22;
            };

            _startIdx = _cursor max 1;
            _p0 = _posArr # (_startIdx - 1);
            _t0 = _timeArr # (_startIdx - 1);
            _hasPrev = false;

            for "_i" from _startIdx to (_ptCount - 1) do {
                if (_t0 >= _renderNow) then {
                    _stillAlive = true;
                    break;
                };

                _p1 = _posArr # _i;
                _t1 = _timeArr # _i;

                if (_t1 > _renderNow) then {
                    _frac = ((_renderNow - _t0) / ((_t1 - _t0) max 0.0001)) min 1 max 0;
                    _tipPos = _p0 vectorAdd ((_p1 vectorDiff _p0) vectorMultiply _frac);
                    if (!_checkSeg || {(_tipPos vectorDotProduct _camDir) > _camD}) then {
                        drawLine3D [_p0, _tipPos, _vTipCol];
                    };
                    _stillAlive = true;
                    break;
                };

                // Quadratic fade mimics non-linear atmospheric dispersion better than linear fade
                _age = _renderNow - _t1;
                _fade = 1 - (_age * _invVaporLife);
                _fade = _fade * _fade;

                if (_fade > 0.02) then {
                    if (!_checkSeg || {(_p1 vectorDotProduct _camDir) > _camD}) then {
                        if (_volumetric) then {
                            if (!_hasPrev) then {
                                _age0 = (_renderNow - _t0) max 0;
                                _dp0 = if (_hasWind) then { _p0 vectorAdd (_windScaled vectorMultiply _age0) } else { _p0 };
                                _off0 = _rightBase vectorAdd (_rightStep vectorMultiply _age0);
                                _l0 = _dp0 vectorAdd _off0;
                                _r0 = _dp0 vectorDiff _off0;
                            };

                            _dp1 = if (_hasWind) then { _p1 vectorAdd (_windScaled vectorMultiply _age) } else { _p1 };
                            if (_age < 0.08) then {
                                drawLine3D [_dp0, _dp1, _vTipCol];
                            } else {
                                _vCol set [3, _fade * _vaporAlpha];
                                drawLine3D [_dp0, _dp1, _vCol];
                            };

                            // Flanking ribbons widen for the first 0.5s of wake expansion
                            if (_age < 0.5) then {
                                _off1 = _rightBase vectorAdd (_rightStep vectorMultiply _age);
                                _l1 = _dp1 vectorAdd _off1;
                                _r1 = _dp1 vectorDiff _off1;
                                _vFlankCol set [3, _fade * _vaporAlpha * 0.38];
                                drawLine3D [_l0, _l1, _vFlankCol];
                                drawLine3D [_r0, _r1, _vFlankCol];
                                _l0 = _l1;
                                _r0 = _r1;
                                _hasPrev = true;
                            } else {
                                _hasPrev = false;
                            };

                            _dp0 = _dp1;
                        } else {
                            if (_age < 0.08) then {
                                drawLine3D [_p0, _p1, _vTipCol];
                            } else {
                                _vCol set [3, _fade * _vaporAlpha];
                                drawLine3D [_p0, _p1, _vCol];
                            };
                        };
                    } else {
                        _hasPrev = false;
                    };
                    _stillAlive = true;
                } else {
                    _hasPrev = false;
                };

                _p0 = _p1;
                _t0 = _t1;
            };

            // Dead-reckon bullet tip forward to hide network latency between 50ms chunks
            if (!_impacted && {_ptCount >= 1}) then {
                _lastT = _timeArr # -1;
                _extDt = _renderNow - _lastT;
                if (_extDt > 0 && {_extDt < 0.35}) then {
                    _velEst = _tr # 8;
                    _segDt = _extDt * ((1 - ((_tr # 9) * _extDt)) max 0.7);
                    _tipPos = (_posArr # -1) vectorAdd (_velEst vectorMultiply _segDt);
                    _tipPos set [2, (_tipPos # 2) - (4.905 * _extDt * _extDt)];
                    if (!_checkSeg || {(_tipPos vectorDotProduct _camDir) > _camD}) then {
                        drawLine3D [_posArr # -1, _tipPos, _vTipCol];
                    };
                    _stillAlive = true;
                };
            };
        };
    } else {
        if (!_impacted && {_ptCount > 0} && {(_now - (_timeArr # -1)) < 10}) then {
            _stillAlive = true;
        };
    };

    if (_impacted && {sbt_showImpactIcon}) then {
        _impactTime = _tr # 11;
        if (_impactTime > 0) then {
            _impactAge = _now - _impactTime;
            if (_impactAge < sbt_impactDuration) then {
                _stillAlive = true;
                _impactPos = _tr # 10;
                if (_impactPos isNotEqualTo [] && {!_checkSeg || {(_impactPos vectorDotProduct _camDir) > _camD}}) then {
                    // Full visibility for initial 60% of duration so spotters have time to call target hits
                    _iFade = if (_impactAge < (sbt_impactDuration * 0.6)) then {
                        1
                    } else {
                        ((sbt_impactDuration - _impactAge) / (sbt_impactDuration * 0.4)) max 0 min 1
                    };
                    _iAlpha = _iFade * _lightMult;

                    if (_iAlpha > 0.02) then {
                        _iRGB = sbt_impactColor;
                        _shooter = player getVariable ["sbt_shooter", objNull];

                        // Measure from rifle muzzle to give true ballistic engagement range
                        _dist = if (!isNull _shooter && {alive _shooter}) then {
                            round (_shooter distance _impactPos)
                        } else {
                            round (player distance _impactPos)
                        };

                        drawIcon3D [
                            "\a3\ui_f\data\map\markers\military\dot_ca.paa",
                            [_iRGB # 0, _iRGB # 1, _iRGB # 2, _iAlpha],
                            _impactPos,
                            0.6,
                            0.6,
                            0,
                            format ["%1m", _dist],
                            2,
                            0.035,
                            "RobotoCondensed",
                            "right"
                        ];
                    };
                };
            };
        };
    };

    // Clean up only when both the vapor trail and the impact icon have completed
    if (!_stillAlive) then {
        sbt_traceIndexMap deleteAt (_tr # 0);
        _traces deleteAt _tIdx;
    };
};
