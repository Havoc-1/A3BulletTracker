[
    "sbt_enabled",
    "CHECKBOX",
    ["Enable Bullet Tracker", "Master toggle for Spotter Bullet Tracker."],
    "Spotter Bullet Tracker",
    true,
    1
] call CBA_fnc_addSetting;

[
    "sbt_maxTraces",
    "SLIDER",
    ["Max Active Traces", "Maximum simultaneous traces rendered before oldest are removed."],
    "Spotter Bullet Tracker",
    [1, 10, 4, 0],
    0
] call CBA_fnc_addSetting;

[
    "sbt_maxSpotterDist",
    "SLIDER",
    ["Max Spotter-Shooter Distance (m)", "Maximum distance between spotter and shooter to maintain pairing."],
    "Spotter Bullet Tracker",
    [5, 50, 15, 0],
    1,
    {
        // Cache squared distance to avoid sqrt calls during FiredMan checks
        sbt_maxSpotterDistSqr = _this * _this;
    }
] call CBA_fnc_addSetting;

[
    "sbt_autoIncludeOptics",
    "CHECKBOX",
    ["Auto-Include All Binoculars & Scopes", "Automatically allows any binocular/rangefinder/designator and static spotting scope without manual classnames."],
    "Spotter Bullet Tracker",
    true,
    1
] call CBA_fnc_addSetting;

[
    "sbt_scopeVehicles",
    "EDITBOX",
    ["Extra Spotting Scope Vehicles / Turrets", "Additional comma-separated vehicle/turret classnames."],
    "Spotter Bullet Tracker",
    "ACE_SpottingScopeObject",
    1,
    {
        sbt_scopeVehicleMap = [_this] call sbt_main_fnc_parseClassList;
    }
] call CBA_fnc_addSetting;

[
    "sbt_opticsList",
    "EDITBOX",
    ["Extra Spotting Optic Weapon / Item Classes", "Additional comma-separated weapon/item classnames."],
    "Spotter Bullet Tracker",
    "Laserdesignator, Laserdesignator_02, Laserdesignator_03, Rangefinder, Binocular",
    1,
    {
        sbt_opticItemMap = [_this] call sbt_main_fnc_parseClassList;
    }
] call CBA_fnc_addSetting;

[
    "sbt_vaporColor",
    "COLOR",
    ["Vapor Trail Color", "RGB color of the bullet condensation wake."],
    "Spotter Bullet Tracker",
    [0.90, 0.93, 0.96],
    0
] call CBA_fnc_addSetting;

[
    "sbt_vaporAlpha",
    "SLIDER",
    ["Vapor Trail Opacity", "Peak opacity of the vapor trail behind the bullet."],
    "Spotter Bullet Tracker",
    [0.10, 1.00, 0.42, 2],
    0
] call CBA_fnc_addSetting;

[
    "sbt_vaporLifetime",
    "SLIDER",
    ["Vapor Trail Duration (s)", "How long each vapor segment remains visible."],
    "Spotter Bullet Tracker",
    [0.3, 3.0, 0.85, 1],
    0
] call CBA_fnc_addSetting;

[
    "sbt_volumetricVapor",
    "CHECKBOX",
    ["Volumetric Vapor Wake", "Adds subtle expanding ribbons that drift with wind."],
    "Spotter Bullet Tracker",
    true,
    0
] call CBA_fnc_addSetting;

[
    "sbt_showImpactIcon",
    "CHECKBOX",
    ["Show Impact Distance Icon", "Draws an icon with target distance reading at the bullet impact location."],
    "Spotter Bullet Tracker",
    true,
    0
] call CBA_fnc_addSetting;

[
    "sbt_impactDuration",
    "SLIDER",
    ["Impact Icon Duration (s)", "How long the impact marker and distance reading stay visible."],
    "Spotter Bullet Tracker",
    [0.5, 6.0, 2.5, 1],
    0
] call CBA_fnc_addSetting;

[
    "sbt_impactColor",
    "COLOR",
    ["Impact Icon Color", "RGB color of the impact marker and distance text."],
    "Spotter Bullet Tracker",
    [1.0, 0.75, 0.20],
    0
] call CBA_fnc_addSetting;

[
    "sbt_enableMinLight",
    "CHECKBOX",
    ["Require Ambient Light", "Suppresses traces in pitch darkness unless using night vision or thermals."],
    "Spotter Bullet Tracker",
    true,
    1
] call CBA_fnc_addSetting;

[
    "sbt_minLight",
    "SLIDER",
    ["Minimum Light Threshold", "Normalized light level required to see traces without NVG/TI."],
    "Spotter Bullet Tracker",
    [0.00, 1.00, 0.25, 2],
    1
] call CBA_fnc_addSetting;

[
    "sbt_allowNVG",
    "CHECKBOX",
    ["Visible Through NVGs", "Allows seeing bullet traces while wearing night vision goggles."],
    "Spotter Bullet Tracker",
    true,
    1
] call CBA_fnc_addSetting;

[
    "sbt_allowTI",
    "CHECKBOX",
    ["Visible Through Thermals (TI)", "Allows seeing bullet traces while in thermal imaging mode."],
    "Spotter Bullet Tracker",
    false,
    1
] call CBA_fnc_addSetting;
