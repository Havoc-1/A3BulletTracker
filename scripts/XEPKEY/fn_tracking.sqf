/*
    Author: [SGC] Xephros, [DMCL] Keystone

    Assigns Fired & FiredNear EH to Shooter and Spotter pair, enables bullet tracking for drawLine3D in Spotting Scope

    Arguments:
        0: Shooter <OBJECT>
        1: Lifetime <NUMBER> (Optional) - Time in seconds to display tracked bullet trajectory after impact
        2: Interval <NUMBER> (Optional) - Interval in seconds to record projectile path
        3: Max Distance <NUMBER> (Optional) - Stop tracking bullet if bullet travels further than this distance
        4: Minimum Range <NUMBER> (Optional) - Minimum distance between spotter and shooter to record bullet trajectory
        5: Maximum Indexes <NUMBER> (Optional) - Maximum number of array indexes in projectile tracking

    Example:
        [unit1,unit2] call XEPKEY_fn_tracking;
    
    Return Value: None
 */

params [["_shooter",objNull],["_lifetime",5],["_int",0.02],["_maxDist",1500],["_minRange",10],["_maxIndex",25]];

//Shooter Variables
if (isNull _shooter) exitWith {diag_log format ["[XK_Trace] [Shooter EH] Invalid shooter (%1)",_shooter]};
_shooter setVariable ["XK_Lifetime",_lifetime];
_shooter setVariable ["XK_Interval",_int];
_shooter setVariable ["XK_maxDist",_maxDist];
_shooter setVariable ["XK_minRange",_minRange];
_shooter setVariable ["XK_maxIndex",_maxIndex];

//Add EH to Shooter to expose Projectile variable
private _ehShooter = _shooter addEventHandler ["Fired", {
    params ["_shooter", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_proj"];
    private _spotter = _shooter getVariable ["XK_Spotter",objNull];
    
    //If no spotter, remove EH
    if (!alive _spotter) exitWith {
        diag_log "[XK_Trace] [Shooter EH] No Spotter Found, exiting EH";
        _shooter removeEventHandler [_thisEvent, _thisEventHandler];
        _shooter setVariable ["XK_Spotter", nil];
    };
    //If Spotter Shooter pair is different, remove EH
    private _spotterPair = _spotter getVariable ["XK_Spotter",objNull];
    if (_spotterPair != _shooter) then {
        diag_log format ["[XK_Trace] [Shooter EH] Spotter (%1) is assigned to another unit (%2), not shooter (%3), exiting EH",_spotter,_spotterPair,_shooter];
        _shooter removeEventHandler [_thisEvent, _thisEventHandler];
        _shooter setVariable ["XK_Spotter", nil];
    };

    private _minRange = _shooter getVariable "XK_minRange";
    if (isNil "_proj" || isNull _proj) exitWith {diag_log "[XK_Trace] [Shooter EH] Projectile not found."};
    if (_shooter distance _spotter >= _minRange) exitWith {diag_log "[XK_Trace] [Shooter EH] Spotter is too far away from shooter, exiting EH."};

    //Adds EH to Projectile to track impact position
    _proj addEventHandler ["HitPart", {
        params ["_projectile", "_hitEntity", "_projectileOwner", "_pos"];
        private _spotter = _projectileOwner getVariable "XK_Spotter";
        _spotter setVariable ["XK_Impact", (ASLToATL _pos)];
        diag_log format ["[XK_Trace] [Projectile EH] XK_Spotter: %1, Impact Pos: %2", _spotter,_pos];
        _projectile removeEventHandler [_thisEvent, _thisEventHandler];
    }];

    if (!alive _spotter || isNull _proj) exitWith {diag_log "[XK_Trace] [Spotter EH] Tracking exited, no spotter or projectile found";};
    diag_log "[XK_Trace] [Spotter EH] Tracking Started";

    private _lifetime = _shooter getVariable "XK_Lifetime";
    private _int = _shooter getVariable "XK_Interval";
    private _maxDist = _shooter getVariable "XK_maxDist";
    private _minRange = _shooter getVariable "XK_minRange";
    private _maxIndex = _shooter getVariable "XK_maxIndex";
    private _bulletPos = [];
    private _impactOld = _spotter getVariable ["XK_Impact", [0,0,0]];
    [
        {
            (_this select 0) params ["_spotter","_shooter","_proj","_lifetime","_maxDist","_minRange","_bulletPos","_impactOld"];
            private _impactNew = _spotter getVariable ["XK_Impact", [0,0,0]];
            //Removes PFH if Trace is finished
            if (!alive _spotter || !alive _proj || _shooter distance _proj >= _maxDist || _spotter distance _shooter >= _minRange ||_impactOld isEqualTo _impactNew) then {
                [_this select 1] call CBA_fnc_removePerFrameHandler;

                //Diag logs
                diag_log "[XK_Trace] [Tracking PFH] PFH finished";
                if !(alive _proj) then {diag_log "[XK_Trace] [Tracking PFH] Projectile dead."};
                if (_spotter distance _proj >= _maxDist) then {diag_log "[XK_Trace] [Tracking PFH] Projectile exceed max distance."};
                if (_spotter distance _shooter >= _minRange) then {diag_log "[XK_Trace] [Tracking PFH] Too far away from shooter/spotter"};
                
                if (alive _spotter) then {
                    private _bulletArray = _spotter getVariable ["XK_bulletPosSpotter",[]];
                    _bulletArray pushback _bulletPos;
                    _spotter setVariable ["XK_bulletPosSpotter",_bulletArray];
                    diag_log format ["[XK_Trace] [Tracking PFH] bulletPos Indexes: %1, assigned to %2", count _bulletPos,_spotter];
                    [{
                            params ["_spotter"];
                            if !(alive _spotter) exitWith {diag_log "[XK_Trace] [Tracking PFH Lifetime] Spotter is dead, bulletArray not updated."};
                            private _bulletArray = _spotter getVariable ["XK_bulletPosSpotter",[]];
                            _bulletArray deleteAt 0;
                            _spotter setVariable ["XK_bulletPosSpotter",_bulletArray];
                        },[_spotter],
                        _lifetime
                    ] call CBA_fnc_waitAndExecute;
                };                    
            } else {
                _bulletPos pushback (getPos _proj);
                if (count _bulletPos >= _maxIndex && _maxIndex > 2) then {_bulletPos deleteAt 0};
            };
        },
        _int,
        [_spotter,_shooter,_proj,_lifetime,_maxDist,_minRange,_bulletPos,_impactOld]
    ] call CBA_fnc_addPerFrameHandler;
    diag_log "[XK_Trace] [Tracking PFH] PFH started";
    
}];
diag_log format ["[XK_Trace] [fn_tracking] Assigned Shooter: %1, Assigned Spotter: %2", _shooter,_shooter getVariable ["XK_Spotter",objNull]];