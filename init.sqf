[] execVM "scripts\XEPKEY\fn_tracerDraw.sqf";
addMissionEventHandler ["Draw3D", {
    if !(("SpottingScope" in typeOf (vehicle player)) && cameraView == "Gunner") exitWith {};
    [] call XK_tracerDraw;
}];
