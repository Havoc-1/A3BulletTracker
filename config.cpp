class CfgPatches
{
	class XK_Spotting
	{
		name = "Spotting Bullet Tracker";
		requiredVersion = 2.06;
		requiredAddons[] = {
			"cba_main",
			"cba_events",
			"ace_common",
			"ace_interact_menu"
		};
		author = "XK";
		authors[] = { "Xephros", "Keystone" };
		license = "https://www.bohemia.net/community/licenses/arma-public-license-share-alike";
		url = "https://github.com/Havoc-1";
		version = 1.0;
		versionStr = "1.0.0";
		versionAr[] = { 1, 0, 0 };
		units[] = {};
		weapons[] = {};
	};
};

class CfgFunctions
{
	 class XK_Spotting
	 { // is tag
		class tracing
		{ // category (doenzt matter what is if you define file)
			file = "XK\addons\XK_Spotting\functions"; // defines next classes (functions will found from this location)
			class initTrackingMod { postInit = 1; };
			class spotter_settings { preStart = 1; };
			class tracerDraw {}; // located to functions and named "fn_tracerDraw.sqf"
			class tracking {}; // located to functions and named "fn_tracking.sqf"
		};
	};
};
