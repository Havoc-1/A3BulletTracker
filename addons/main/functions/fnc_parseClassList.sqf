#include "..\script_component.hpp"

params [["_rawString", "", [""]]];

private _map = createHashMap;
if (_rawString isEqualTo "") exitWith { _map };

// Convert to lowercase HashMap keys for O(1) membership lookups instead of linear array scans
{
    private _trimmed = toLowerANSI (trim _x);
    if (_trimmed isNotEqualTo "") then {
        _map set [_trimmed, true];
    };
} forEach (_rawString splitString ",;");

_map
