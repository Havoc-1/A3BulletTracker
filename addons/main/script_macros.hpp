
#define DOUBLES_IMPL(var1,var2) var1##_##var2
#define DOUBLES(var1,var2) DOUBLES_IMPL(var1,var2)

#define TRIPLES_IMPL(var1,var2,var3) var1##_##var2##_##var3
#define TRIPLES(var1,var2,var3) TRIPLES_IMPL(var1,var2,var3)

#define QUOTE_IMPL(var1) #var1
#define QUOTE(var1) QUOTE_IMPL(var1)

#define ADDON DOUBLES(PREFIX,COMPONENT)
#define QADDON QUOTE(ADDON)

#define GVAR(var1) DOUBLES(ADDON,var1)
#define QGVAR(var1) QUOTE(GVAR(var1))

#define FUNC(var1) TRIPLES(ADDON,fnc,var1)
#define QFUNC(var1) QUOTE(FUNC(var1))

#define PATHTOF_SYS(var1,var2,var3) \z\var1\addons\var2\var3
#define PATHTOF(var1) PATHTOF_SYS(PREFIX,COMPONENT,var1)
#define QPATHTOF(var1) QUOTE(PATHTOF(var1))

#define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction

#define VERSION     MAJOR.MINOR
#define VERSION_STR MAJOR.MINOR.PATCHLVL.BUILD
#define VERSION_AR  MAJOR,MINOR,PATCHLVL,BUILD

#define VERSION_CONFIG version = VERSION; versionStr = QUOTE(VERSION_STR); versionAr[] = {VERSION_AR}

#define LOG_DEBUG(msg) if (GVAR(debug)) then { diag_log text format ["[SBT] (%1) %2", diag_frameNo, msg]; }
#define LOG_DEBUG_1(fmt,a1) if (GVAR(debug)) then { diag_log text format ["[SBT] (%1) %2", diag_frameNo, format [fmt, a1]]; }
#define LOG_DEBUG_2(fmt,a1,a2) if (GVAR(debug)) then { diag_log text format ["[SBT] (%1) %2", diag_frameNo, format [fmt, a1, a2]]; }
#define LOG_DEBUG_3(fmt,a1,a2,a3) if (GVAR(debug)) then { diag_log text format ["[SBT] (%1) %2", diag_frameNo, format [fmt, a1, a2, a3]]; }
