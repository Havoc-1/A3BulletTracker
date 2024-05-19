/*
 *    Author: [SGC] Xephros, [DMCL] Keystone
 *
 *    Part of Bullet Tracking mod.
 *    File containing CBA addon option settings 
 */
 //Vehicle class names
[
    "XK_vehicleClassnames", 
    "EDITBOX", 
    ["Vehicle Classnames", "Classnames of 'vehicles' that can trace bullets | Separate using , - no need for quotation marks"], 
    ["A3BulletTracker","Classnames"], 
    "",[[1, 0]]
] call CBA_fnc_addSetting;

//Binocular item class names
[
    "XK_itemClassnames", 
    "EDITBOX", 
    ["Item Classnames", "Classnames of 'items' that can trace bullets | Separate using , - no need for quotation marks"], 
    ["A3BulletTracker","Classnames"], 
    "",[[1, 0]]
] call CBA_fnc_addSetting;

/* //Enable Custom Trace Colors
[
    "XK_enableColor",
    "CHECKBOX",
    ["Enable Custom Trace Colors", "Allow custom colors for bullet trace"],
    ["A3BulletTracker", "Parameters"],
    false,[[1, 0]]
] call CBA_fnc_addSetting;

//Custom Trace Color
[
    "XK_color",
    "COLOR",
    ["Custom Trace Color", "Change the color of bullet trace"],
    ["A3BulletTracker", "Parameters"],
    [1.00,1.00,0.00],[[1,0]]
] call CBA_fnc_addSetting;

//Enable Minimum Light
[
    "XK_enableMinLight",
    "CHECKBOX",
    ["Enable Minimum Light", "Hides trace from being seen below a lighting threshold"],
    ["A3BulletTracker", "Parameters"],
    true,[[1,0]]
] call CBA_fnc_addSetting;

//Minimum Light Threshold
[
    "XK_minLight",
    "SLIDER",
    ["Minimum Light Threshold", "Light levels below threshold will hide trace. Default 0.3"],
    ["A3BulletTracker", "Parameters"],
    [0, 1, 0.3],
    [[0,1]]
] call CBA_fnc_addSetting; */

//Text Size
[
    "XK_textSize",
    "EDITBOX",
    ["Text Size", "Text size for impact distance. Default 0.03"],
    ["A3BulletTracker", "Parameters"],
    "0.03",
    [[0,1]]
] call CBA_fnc_addSetting;

//Icon Size
[
    "XK_iconSize",
    "EDITBOX",
    ["Icon Size", "Icon size for impact position. Default 0.3"],
    ["A3BulletTracker", "Parameters"],
    "0.3",
    [[0,1]]
] call CBA_fnc_addSetting;