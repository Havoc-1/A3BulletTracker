/*
    Author: [SGC] Xephros, [DMCL] Keystone

    Assigns Fired & FiredNear EH to Shooter and Spotter pair, enables bullet tracking for drawLine3D in Spotting Scope

    Arguments:
        0: Shooter <OBJECT>
        1: Spotter <OBJECT>
        2: Lifetime <NUMBER> - Time in seconds to display tracked bullet trajectory after impact
        3: Color <ARRAY> - [R,G,B,A] Color for drawLine3D trace
        4: Interval <NUMBER> - Interval in seconds to record projectile path
        5: Max Distance <NUMBER> - Stop tracking bullet if bullet travels further than this distance
        6: Minimum Range <NUMBER> - Minimum distance between spotter and shooter to record bullet trajectory

    Example:
        [unit1,unit2] call XEPKEY_fn_tracking;
    
    Return Value: None

    To do:
    - Fix tracing on only first bulet
    - Delete trace after lifetime exceeded 
    - Test for multiplayer 
 */

params [["_uShooter",objNull],["_uSpotter",objNull],["_lifetime",5],["_color",[1,1,0,1]],["_int",0.02],["_maxDist",1500],["_minRange",10]];

//Shooter Variables
if (isNull _uShooter || isNull _uSpotter) exitWith {diag_log format ["[XK_Trace] [Shooter EH] Shooter (%1), Spotter (%2). Invalid shooter or spotter.",_uShooter,_uSpotter]};
_uShooter setVariable ["XK_Lifetime",_lifetime];
_uShooter setVariable ["XK_Color",_color];
_uShooter setVariable ["XK_Interval",_int];
_uShooter setVariable ["XK_maxDist",_maxDist];
_uShooter setVariable ["XK_minRange",_minRange];

//Add EH to Shooter to expose Projectile variable
private _ehShooter = _uShooter addEventHandler ["Fired", {
    params ["_shooter", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_proj"];
    private _spotter = _shooter getVariable "XK_Spotter";
    if (isNil "_spotter") exitWith {diag_log "[XK_Trace] [Shooter EH] No Spotter Found, exiting EH"};
    if (!alive _spotter) exitWith {diag_log "[XK_Trace] [Shooter EH] Spotter is dead, exiting EH"};
    //Expose Projectile
    //_spotter setvariable ["XK_PubProj", _projectile];
    //diag_log format ["[XK_Trace] [Shooter EH] Shooter fired, sending projectile (%1) to Spotter (%2)",_proj, _spotter];

    private _minRange = _shooter getVariable "XK_minRange";
    if (isNil "_proj" || isNull _proj) exitWith {diag_log "[XK_Trace] [Shooter EH] Projectile not found."};

    if (_shooter distance _spotter >= _minRange) exitWith {diag_log "[XK_Trace] [Shooter EH] Spotter is too far away from shooter, exiting EH."};
    diag_log format ["[XK_Trace] [Spotter EH] Shooter: %1, Spotter: %2, Projectile: %3",_shooter,_spotter,_proj];

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
    private _color = _shooter getVariable "XK_Color";
    private _int = _shooter getVariable "XK_Interval";
    private _maxDist = _shooter getVariable "XK_maxDist";
    private _minRange = _shooter getVariable "XK_minRange";
    private _bulletPos = [];
    private _impactOld = _spotter getVariable ["XK_Impact", [0,0,0]];
    [
        {
            (_this select 0) params ["_spotter","_shooter","_proj","_lifetime","_maxDist","_minRange","_bulletPos","_impactOld"];
            private _impactNew = _spotter getVariable ["XK_Impact", [0,0,0]];
            //Removes PFH if Trace is finished
            if (!alive _spotter || !alive _proj || getPosATL _proj select 2 < 0.05 || _shooter distance _proj >= _maxDist || _spotter distance _shooter >= _minRange ||
            (_impactOld select 0 != _impactNew select 0 ||
            _impactOld select 1 != _impactNew select 1 ||
            _impactOld select 2 != _impactNew select 2)
            ) then {
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
                    [
                        {
                            params ["_spotter"];
                            if !(alive _spotter) exitWith {diag_log "[XK_Trace] [Tracking PFH Lifetime] Spotter is dead, bulletArray not updated."};
                            private _bulletArray = _spotter getVariable ["XK_bulletPosSpotter",[]];
                            _bulletArray deleteAt 0;
                            _spotter setVariable ["XK_bulletPosSpotter",_bulletArray];
                        },
                        [_spotter],
                        _lifetime
                    ] call CBA_fnc_waitAndExecute;
                };                    
            } else {
                _bulletPos pushback (getPos _proj);
                if (count _bulletPos >= 15) then {_bulletPos deleteAt 0};
                private _impactNew = _spotter getVariable ["XK_Impact", [0,0,0]];
            };
        },
        _int,
        [_spotter,_shooter,_proj,_lifetime,_maxDist,_minRange,_bulletPos,_impactOld]
    ] call CBA_fnc_addPerFrameHandler;
    diag_log "[XK_Trace] [Tracking PFH] PFH started";

}];
_uShooter setVariable ["XK_traceEH",_ehShooter];
diag_log format ["[XK_Trace] [fn_tracking] Assigned Shooter: %1, Assigned Spotter: %2", _uShooter,_uSpotter];

//Spotter Variables
/* _uSpotter setVariable ["XK_Lifetime",_lifetime];
_uSpotter setVariable ["XK_Color",_color];
_uSpotter setVariable ["XK_Interval",_int];
_uSpotter setVariable ["XK_maxDist",_maxDist];
_uSpotter setVariable ["XK_minRange",_minRange]; */

/* private _ehSpotter = _uSpotter addEventHandler ["FiredNear", {
    params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
    diag_log format ["[XK_Trace] [Projectile EH] Fired Near Spotter (%1), Shooter (%2) is %3m away.",_unit,_firer,_distance];
    private _spotter = _unit;
    private _shooter = _spotter getVariable "XK_Spotter";
    if !(_shooter == _firer) exitWith {diag_log "[XK_Trace] [Projectile EH] Shooter is not firer."};
    private _minRange = _spotter getVariable "XK_minRange";
    private _proj = _spotter getVariable "XK_PubProj";
    if (isNil "_proj" || isNull _proj) exitWith {diag_log "[XK_Trace] [Projectile EH] Projectile not found."};
    diag_log format ["[XK_Trace] [Projectile EH] Projectile found: %1",_proj];
    
    //If Shooter is Spotter Partner AND Shooter is on Foot AND Shooter is in range of Spotter
    if ((_shooter == _firer) && (isNull objectParent _firer) && (_distance <= _minRange)) then {
        diag_log format ["[XK_Trace] [Spotter EH] Shooter: %1, Spotter: %2, Projectile: %3",_shooter,_spotter,_proj];

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

        private _lifetime = _spotter getVariable "XK_Lifetime";
        private _color = _spotter getVariable "XK_Color";
        private _int = _spotter getVariable "XK_Interval";
        private _maxDist = _spotter getVariable "XK_maxDist";
        private _minRange = _spotter getVariable "XK_minRange";
        private _bulletPos = [];
        
        [
            {
                (_this select 0) params ["_spotter","_shooter","_proj","_lifetime","_maxDist","_minRange","_bulletPos"];
                
                //Removes PFH if Trace is finished
                if (!alive _spotter || !alive _proj || getPosATL _proj select 2 < 0.1 || _shooter distance _proj >= _maxDist || _spotter distance _shooter >= _minRange) then {
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
                        [
                            {
                                params ["_spotter"];
                                if !(alive _spotter) exitWith {diag_log "[XK_Trace] [Tracking PFH Lifetime] Spotter is dead, bulletArray not updated."};
                                private _bulletArray = _spotter getVariable ["XK_bulletPosSpotter",[]];
                                _bulletArray deleteAt 0;
                                _spotter setVariable ["XK_bulletPosSpotter",_bulletArray];
                            },
                            [_spotter],
                            _lifetime
                        ] call CBA_fnc_waitAndExecute;
                    };                    
                } else {
                    _bulletPos pushback (getPos _proj);
                    //if (count _bulletPos >= 15) then {_bulletPos deleteAt 0};
                };
            },
            _int,
            [_spotter,_shooter,_proj,_lifetime,_maxDist,_minRange,_bulletPos]
        ] call CBA_fnc_addPerFrameHandler;
        diag_log "[XK_Trace] [Tracking PFH] PFH started";
    };
}]; */
//_uSpotter setVariable ["XK_SpotterEH", _ehSpotter];

//diag_log format ["[XK_Trace] [fn_tracking] Shooter (%1) EH Index: %2, Spotter (%3) EH Index: %4", _uShooter,_uShooter getVariable "XK_traceEH",_uSpotter,_uSpotter getVariable "XK_SpotterEH"];