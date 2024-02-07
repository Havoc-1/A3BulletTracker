/*
 *    Author: [SGC] Xephros, [DMCL] Keystone
 *
 *    Part of Bullet Tracking mod.
 *    File containing CBA addon option settings 
 */

 //Vehicle class names
[
    "XK_vehicleClassnames", 
    "ARRAY", 
    ["Vehicle Classnames", "Enter the classnames of the vehicles to use for the system."], 
    "A3BulletTracker", 
    ["SpottingScope"], 
    true 
] call CBA_fnc_addSetting;

//Binocular item class names
[
    "XK_itemClassnames", 
    "ARRAY", 
    ["Item Classnames", "Enter the classnames of the inventory items to use for the system."], 
    "A3BulletTracker", 
    ["designator", "Vector"], 
    true 
] call CBA_fnc_addSetting;

// Get the classnames from the CBA settings
private _vehicleClassnames = ["XK_vehicleClassnames"] call CBA_fnc_getSetting;
private _itemClassnames = ["XK_itemClassnames"] call CBA_fnc_getSetting;