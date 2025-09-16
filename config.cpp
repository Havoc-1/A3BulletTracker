class CfgPatches
{
    class XK_Spotting {
        name="Spotting Bullet Tracker";
        requiredVersion=2.06;
        requiredAddons[] = {
            "cba_main", 
            "cba_events",
            "ace_common",
            "ace_interact_menu"
        };
        author="XK";
        authors[]={"Xephros","Keystone"};
        license = "https://www.bohemia.net/community/licenses/arma-public-license-share-alike";
        url = "https://github.com/Havoc-1";
        version = 2.0;
        versionStr = "2.0.0";
        versionAr[] = {2,0,0};
        units[]={};
        weapons[]={};
    };
};

class CfgFunctions {
     class XK_spotting { // is tag
        class tracing { // category (doenzt matter what is if you define file)
            file = "\XK_Spotting\functions"; // defines next classes (functions will found from this location)
            class initTrackingMod { postInit = 1; };
            class tracking {}; // located to functions and named "fn_tracking.sqf"
            class tracerDraw {}; // located to functions and named "fn_tracerDraw.sqf"
            class opticsSwitch {}; // located to functions and named "fn_opticsSwitch.sqf"
        };
    };
};

class Extended_PreInit_EventHandlers
{
	class XK_spotting {init = " call compile preprocessFileLineNumbers '\XK_Spotting\functions\XK_spotter_settings.sqf'";};
};