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
    ["XK Bullet Tracing for Spotters","1. Classnames"], 
    "ACE_SpottingScopeObject",[[1, 0]]
] call CBA_fnc_addSetting;

//Binocular item class names
[
    "XK_itemClassnames", 
    "EDITBOX", 
    ["Item Classnames", "Classnames of 'items' that can trace bullets | Separate using , - no need for quotation marks"], 
    ["XK Bullet Tracing for Spotters","1. Classnames"], 
    "ACE_Vector, ACE_VectorDay",[[1, 0]]
] call CBA_fnc_addSetting;

//Enable Custom Trace Colors
[
    "XK_enableColor",
    "CHECKBOX",
    ["Enable Custom Trace Colors", "Allow custom colors for bullet trace"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    false,[[1, 0]]
] call CBA_fnc_addSetting;

//Custom Trace Color
[
    "XK_color",
    "COLOR",
    ["Custom Trace Color", "Change the color of bullet trace"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    [1.00,1.00,0.00],[[1,0]]
] call CBA_fnc_addSetting;

//Enable Minimum Light
[
    "XK_enableMinLight",
    "CHECKBOX",
    ["Enable Minimum Light", "Hides trace from being seen below a lighting threshold"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    true,[[1,0]]
] call CBA_fnc_addSetting;

//Enable Tracing under NVG
[
    "XK_traceNVG",
    "CHECKBOX",
    ["Enable NVG Tracing", "Allows bullet tracing under nightvision goggles while below minimum light threshold."],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    true,[[1,0]]
] call CBA_fnc_addSetting;

//Minimum Light Threshold
[
    "XK_minLight",
    "SLIDER",
    ["Minimum Light Threshold", "Light levels below threshold will hide trace. Default 0.3"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    [0, 1, 0.3],
    [[0,1]]
] call CBA_fnc_addSetting;

//Text Size
[
    "XK_textSize",
    "SLIDER",
    ["Text Size", "Text size for impact distance. Default 0.03"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    [0.01, 0.1, 0.03],
    [[0,1]]
] call CBA_fnc_addSetting;

//Icon Size
[
    "XK_iconSize",
    "SLIDER",
    ["Icon Size", "Icon size for impact position. Default 0.3"],
    ["XK Bullet Tracing for Spotters", "2. Parameters"],
    [0.1, 1, 0.3],
    [[0,1]]
] call CBA_fnc_addSetting;

//Debug
[
    "XK_debug",
    "CHECKBOX",
    ["Enable Debug Mode", "Outputs diag_logs into client RPT."],
    ["XK Bullet Tracing for Spotters", "3. Debug"],
    false
] call CBA_fnc_addSetting;