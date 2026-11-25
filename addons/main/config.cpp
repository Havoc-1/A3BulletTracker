#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Spotter Bullet Tracker";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {
            "cba_main",
            "cba_events",
            "cba_settings",
            "ace_common",
            "ace_interact_menu"
        };
        author = "VIVbeam / v.s.k9";
        authors[] = {"VIVbeam", "v.s.k9"};
        VERSION_CONFIG;
    };
};

class Extended_PreStart_EventHandlers {
    class ADDON {
        init = "call compileScript ['\z\sbt\addons\main\XEH_preStart.sqf']";
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = "call compileScript ['\z\sbt\addons\main\XEH_preInit.sqf']";
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = "call compileScript ['\z\sbt\addons\main\XEH_postInit.sqf']";
    };
};
