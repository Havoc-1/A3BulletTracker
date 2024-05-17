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
    ["Vehicle Classnames", "Classnames of 'vehicles' that can use the tracker | Separate using , - no need for quotation marks"], 
    ["A3BulletTracker","Spotting Scopes / Turrets"], 
    "" 
] call CBA_fnc_addSetting;

//Binocular item class names
[
    "XK_itemClassnames", 
    "EDITBOX", 
    ["Item Classnames", "Classnames of binoculars that can use the tracker | Separate using , - no need for quotation marks"], 
    ["A3BulletTracker","Binoculars", "Vector"], 
    "" 
] call CBA_fnc_addSetting;