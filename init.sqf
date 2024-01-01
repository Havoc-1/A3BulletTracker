[] execVM "scripts\XEPKEY\fn_tracerDraw.sqf";

addMissionEventHandler ["Draw3D", {
    if !(("SpottingScope" in typeOf (vehicle player)) && cameraView == "Gunner") exitWith {};
    [] call XK_tracerDraw;
}];

//Perhaps run initPlayerLocal code here for local only (maybe remoteExec for local?) for plug and play solution