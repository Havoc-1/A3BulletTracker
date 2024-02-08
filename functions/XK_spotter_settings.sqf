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
    ["Vehicle Classnames", "Classnames of 'vehicles' that can use the tracker"], 
    ["A3BulletTracker","Spotting Scopes / Turrets"], 
    "" 
] call CBA_fnc_addSetting;

//Binocular item class names
[
    "XK_itemClassnames", 
    "EDITBOX", 
    ["Item Classnames", "Classnames of binoculars that can use the tracker"], 
    ["A3BulletTracker","Binoculars", "Vector"], 
    "" 
] call CBA_fnc_addSetting;
// Get the classnames from the CBA settings
private _vehicleClassnames = ["XK_vehicleClassnames"] call CBA_fnc_getSetting;
private _itemClassnames = ["XK_itemClassnames"] call CBA_fnc_getSetting;