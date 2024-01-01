//Convert to preprocess, hpp, or merge with init

/* 
    Author: [SGC] Xephros, [DMCL] Keystone

    Function to call in Draw3D MissionEventHandler to draw bullet trajectory and impact position from shooter.

    Arguments:
        0: Unit <OBJECT> (Optional) - Player unit to grab positional data.
        1: Text Size <NUMBER> (Optional) - Size of text for distance of impact to shooter
        2: Icon Size <NUMBER> (Optional) - Size of icon for impact position.
        3: Angle <NUMBER> (Optional) - Rotation angle of icon.
    
    Examples:
        [] call XEPKEY_fnc_tracerDraw;
    
    Return Value: None
 */

XK_tracerDraw = {
    params [["_unit",player],["_textSize",0.03],["_iconSize",0.3],["_ang",0]];
    private _bulletPos = _unit getVariable "XK_bulletPosSpotter";
    if (isNil "_bulletPos") exitWith {};
    if (count _bulletPos == 0) exitWith {};

    //Get Bullet Impact position
    private _pos = _unit getVariable "XK_Impact";
    if (isNil "_pos") exitWith {};

    private _color = [1,1,0,1];
    private _text = format ["%1m",round (player distance _pos)];
    
    //Draw Bullet Trajectory and Impact
    drawIcon3D ["\A3\ui_f\data\map\markers\military\circle_CA.paa", _color, _pos, _iconSize, _iconSize, _ang, _text, 1, _textSize, "TahomaB","center",true,0,0.003];
    {
        private _indexes = _x;
        {
            for "_i" from 0 to ((count _indexes) - 1) do {
                if (_i == (count _indexes) - 1) exitWith {};
                //diag_log format ["[tracerDraw] _i: %1, _i+1: %2",_indexes select _i, _indexes select (_i + 1)];
                drawLine3D [_indexes select _i, _indexes select (_i + 1), _color];
            };
        } forEach _indexes;
    } forEach _bulletPos;
};