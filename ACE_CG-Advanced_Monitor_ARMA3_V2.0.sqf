private _use_ace_interaction = true;
private _show_group = true;   
private _show_group_number = true;   
private _show_distance = true;   
private _show_additional_sides = [["blufor", true], ["opfor", false], ["independent", false], ["civilian", true]];
private _ui_color_list_rgba = [0, 0.42, 1, 1];   
private _ui_color_confirm_rgba = [0, 0.42, 1, 0.8];   
private _ui_color_cancel_rgba = [0.1, 0.1, 0.3, 0.8];   
private _ui_color_header_hex_RRGGBB = "#006BC4";   
private _string_ui_confirm = "Confirm";   
private _string_ui_cancel = "Cancel";   
private _string_interactionMenu_select_operator = "Select Operator";   
private _string_interactionMenu_change_operator = "Change Operator";   
private _string_interactionMenu_disconnect_camera = "Disconnect Cameras";   
private _string_noCams_found_hint = "No operators with cameras available";
private _helmet_cam_offset = [0.2, 0, 0.175];
private _helmet_cam_pitch = 0;
private _helmet_cam_yaw = 0;
private _helmet_cam_roll = 0;
private _helmet_cam_fov = 0.87;

ARTEK_fnc_getOperatorTextureIndex = { 0 };

if ((count _ui_color_header_hex_RRGGBB) == 9) then {
    _ui_color_header_hex_RRGGBB = _ui_color_header_hex_RRGGBB select [0,7];
};

if (isServer) then {   
    missionNamespace setVariable ["ARTEK_allow_groupID", _show_group, true];   
    missionNamespace setVariable ["ARTEK_allow_groupNumber", _show_group_number, true];   
    missionNamespace setVariable ["ARTEK_allow_distance", _show_distance, true];    
    missionNamespace setVariable ["ARTEK_allowed_sides", _show_additional_sides, true];
    missionNamespace setVariable ["ARTEK_ui_color_list", _ui_color_list_rgba, true];   
    missionNamespace setVariable ["ARTEK_ui_color_confirm", _ui_color_confirm_rgba, true];   
    missionNamespace setVariable ["ARTEK_ui_color_cancel", _ui_color_cancel_rgba, true];   
    missionNamespace setVariable ["ARTEK_ui_color_header", _ui_color_header_hex_RRGGBB, true];   
    missionNamespace setVariable ["ARTEK_string_ui_confirm", _string_ui_confirm, true];   
    missionNamespace setVariable ["ARTEK_string_ui_cancel", _string_ui_cancel, true];   
    missionNamespace setVariable ["ARTEK_string_interactionMenu_select", _string_interactionMenu_select_operator, true];   
    missionNamespace setVariable ["ARTEK_string_interactionMenu_change", _string_interactionMenu_change_operator, true];   
    missionNamespace setVariable ["ARTEK_string_interactionMenu_disconnect", _string_interactionMenu_disconnect_camera, true];   
    missionNamespace setVariable ["ARTEK_helmet_cam_offset", _helmet_cam_offset, true];  
    missionNamespace setVariable ["ARTEK_helmet_cam_pitch", _helmet_cam_pitch, true];  
    missionNamespace setVariable ["ARTEK_helmet_cam_yaw", _helmet_cam_yaw, true];  
    missionNamespace setVariable ["ARTEK_helmet_cam_roll", _helmet_cam_roll, true];  
    missionNamespace setVariable ["ARTEK_helmet_cam_fov", _helmet_cam_fov, true];
    missionNamespace setVariable ["ARTEK_string_nocams_hint", _string_noCams_found_hint, true];
    
    if (isClass (configFile >> "CfgPatches" >> "ace_main") && _use_ace_interaction) then { 
        missionNamespace setVariable ["ARTEK_use_ace_interaction", true, true]; 
    };
    
    private _ARTEK_OperatorCam_SyncConfig = [];   
    {   
        _ARTEK_OperatorCam_SyncConfig pushBack _x;   
        _x setVehicleVarName format ["ARTEK_monitor_%1", _forEachIndex];   
    } forEach synchronizedObjects this;   
    missionNamespace setVariable ["ARTEK_OperatorCam_SyncConfig", _ARTEK_OperatorCam_SyncConfig, true];   
};   

if (isNil "ARTEK_OperatorCam_Index") then { ARTEK_OperatorCam_Index = 0; };     
if (isNil "ARTEK_OperatorCam_Initialized") then { ARTEK_OperatorCam_Initialized = false; };     
    
ARTEK_fnc_selectOperatorDialog = {    
    params ["_title", "_options", "_onConfirm", "_onCancel", "_params"];    
    if (!hasInterface) exitWith {};    
    private _display = findDisplay 46 createDisplay "RscDisplayEmpty";    
    private _background = _display ctrlCreate ["RscText", -1];    
    _background ctrlSetPosition [0.3, 0.2, 0.4, 0.6];    
    _background ctrlSetBackgroundColor [0, 0, 0, 0.8];    
    _background ctrlCommit 0;    
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", -1];    
    _titleCtrl ctrlSetPosition [0.3, 0.21, 0.4, 0.05];    
    _titleCtrl ctrlSetStructuredText parseText format["<t align='center' size='1.2' color='%1'>%2</t>", missionNamespace getVariable ["ARTEK_ui_color_header","#006BC4"], _title];   
    _titleCtrl ctrlCommit 0;    
    private _listBox = _display ctrlCreate ["RscListBox", 1500];    
    _listBox ctrlSetPosition [0.32, 0.28, 0.36, 0.42];    
    _listBox ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.9];    
    _listBox ctrlCommit 0;    
    {    
        private _index = _listBox lbAdd (_x select 0);    
        _listBox lbSetColor [_index, _x select 1];    
    } forEach _options;
    if (count _options > 0) then {
        _listBox lbSetCurSel 0;
    };    
    private _confirmBtn = _display ctrlCreate ["RscButton", 1600];    
    _confirmBtn ctrlSetPosition [0.32, 0.72, 0.17, 0.05];    
    _confirmBtn ctrlSetText (missionNamespace getVariable ["ARTEK_string_ui_confirm", "Confirm"]);   
    _confirmBtn ctrlSetBackgroundColor (missionNamespace getVariable ["ARTEK_ui_color_confirm", [0, 0.42, 1, 0.8]]);   
    _confirmBtn ctrlSetTextColor [1, 1, 1, 1];    
    _confirmBtn ctrlCommit 0;    
    private _cancelBtn = _display ctrlCreate ["RscButton", 1601];    
    _cancelBtn ctrlSetPosition [0.51, 0.72, 0.17, 0.05];    
    _cancelBtn ctrlSetText (missionNamespace getVariable ["ARTEK_string_ui_cancel", "Cancel"]);   
    _cancelBtn ctrlSetBackgroundColor (missionNamespace getVariable ["ARTEK_ui_color_cancel", [0.1, 0.1, 0.3, 0.8]]);   
    _cancelBtn ctrlSetTextColor [1, 1, 1, 1];    
    _cancelBtn ctrlCommit 0;    
    _confirmBtn ctrlAddEventHandler ["ButtonClick", {    
        params ["_ctrl"];    
        private _display = ctrlParent _ctrl;    
        private _listBox = _display displayCtrl 1500;    
        private _selected = lbCurSel _listBox;
        if (_selected >= 0) then {    
            private _onConfirm = _display getVariable ["onConfirm", {}];    
            private _params = _display getVariable ["params", []];    
            [_selected] + _params call _onConfirm;
        };    
        _display closeDisplay 1;    
    }];    
    _cancelBtn ctrlAddEventHandler ["ButtonClick", {    
        params ["_ctrl"];    
        private _display = ctrlParent _ctrl;    
        private _onCancel = _display getVariable ["onCancel", {}];    
        private _params = _display getVariable ["params", []];    
        _params call _onCancel;    
        _display closeDisplay 2;    
    }];    
    _display setVariable ["onConfirm", _onConfirm];    
    _display setVariable ["onCancel", _onCancel];    
    _display setVariable ["params", _params];    
};    
     
ARTEK_fnc_getOperatorsWithCamera = {
    params ["_caller"];
    private _blufor = false;
    private _opfor = false;
    private _independent = false;
    private _civilian = false;
    {
        switch (true) do {
            case (_x#0 == "blufor" && _x#1 == true): { _blufor = true; };
            case (_x#0 == "opfor" && _x#1 == true): { _opfor = true; };
            case (_x#0 == "independent" && _x#1 == true): { _independent = true; };
            case (_x#0 == "civilian" && _x#1 == true): { _civilian = true; };
        };
    } forEach (missionNamespace getVariable ["ARTEK_allowed_sides", [["blufor", false], ["opfor", false], ["independent", false], ["civilian", false]]]);

    allUnits select {     
        (side _x == side _caller || (side _x == blufor && _blufor) || (side _x == opfor && _opfor) || (side _x == independent && _independent) || (side _x == civilian && _civilian)) &&     
        alive _x &&     
        !isNull _x &&     
        ([_x, ["ItemcTabHCam"]] call cTab_fnc_checkGear || "ItemcTabHCam" in (items _x))     
    }     
};

ARTEK_fnc_getVehiclesWithTurrets = {   
    params ["_caller"]; 
    private _blufor = false;  
    private _opfor = false;  
    private _independent = false;  
    private _civilian = false;  
    {  
        switch (true) do {  
            case (_x#0 == "blufor" && _x#1 == true): { _blufor = true; };  
            case (_x#0 == "opfor" && _x#1 == true): { _opfor = true; };  
            case (_x#0 == "independent" && _x#1 == true): { _independent = true; };  
            case (_x#0 == "civilian" && _x#1 == true): { _civilian = true; };  
        };  
    } forEach (missionNamespace getVariable ["ARTEK_allowed_sides", [["blufor", false], ["opfor", false], ["independent", false], ["civilian", false]]]); 
   
    vehicles select {   
        private _veh = _x;   
        (side _veh == side _caller || (side _veh == blufor && _blufor) || (side _veh == opfor && _opfor) || (side _veh == independent && _independent) || (side _veh == civilian && _civilian)) && 
        alive _veh &&   
        !isNull _veh &&   
        (count (allTurrets [_veh, true]) > 0) &&   
        unitIsUAV _veh   
    }   
};

ARTEK_fnc_getSpottersWithOptics = { 
    params ["_caller"]; 
    private _blufor = false; 
    private _opfor = false; 
    private _independent = false; 
    private _civilian = false; 
    { 
        switch (true) do { 
            case (_x#0 == "blufor" && _x#1 == true): { _blufor = true; }; 
            case (_x#0 == "opfor" && _x#1 == true): { _opfor = true; }; 
            case (_x#0 == "independent" && _x#1 == true): { _independent = true; }; 
            case (_x#0 == "civilian" && _x#1 == true): { _civilian = true; }; 
        }; 
    } forEach (missionNamespace getVariable ["ARTEK_allowed_sides", [["blufor", false], ["opfor", false], ["independent", false], ["civilian", false]]]); 
 
    private _spotterOptics = [
        "Nikon_DSLR_HUD", "Nikon_DSLR", 
        "Hate_Smartphone_HUD", "Hate_Smartphone", 
        "Laserdesignator"
    ]; 
     
    allUnits select { 
        (side _x == side _caller || (side _x == blufor && _blufor) || (side _x == opfor && _opfor) || (side _x == independent && _independent) || (side _x == civilian && _civilian)) && 
        alive _x && 
        !isNull _x && 
        {currentWeapon _x in _spotterOptics} 
    } 
};

ARTEK_fnc_getUAVCameraPoints = {   
    params ["_vehicle"];   
    private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;   
    private _posPoint = getText (_config >> "uavCameraGunnerPos");   
    private _dirPoint = getText (_config >> "uavCameraGunnerDir");   
    if (_posPoint == "") then {   
        {   
            private _testPos = _vehicle selectionPosition _x;   
            if (!(_testPos isEqualTo [0,0,0])) exitWith {_posPoint = _x;};   
        } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos"];   
    };   
    if (_dirPoint == "") then {   
        {   
            private _testDir = _vehicle selectionPosition _x;   
            if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};   
        } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir"];   
    };   
    [_posPoint, _dirPoint]   
};

ARTEK_fnc_getCurrentOpticsZoom = { 
    private _fov = getObjectFOV player; 
    if (!isNil "_fov" && {typeName _fov == "ARRAY"} && {count _fov > 0}) then { 
        _fov select 0 
    } else { 
        0.75 
    } 
};

ARTEK_fnc_changeVisionMode = {   
    params ["_monitor"];   
    private _currentMode = _monitor getVariable ["visionMode", 0];   
    private _newMode = (_currentMode + 1) mod 2;   
    _monitor setVariable ["visionMode", _newMode, true];   
    private _renderTarget = _monitor getVariable ["operatorRenderTarget", "rendertarget0"];   
    switch (_newMode) do {   
        case 0: {_renderTarget setPiPEffect [0];};   
        case 1: {_renderTarget setPiPEffect [1];};   
    };   
};
     
ARTEK_fnc_startOperatorFeed = {     
    params ["_monitor", "_operator"];     
    private _textureIndex = [_monitor] call ARTEK_fnc_getOperatorTextureIndex;     
    private _renderTarget = _monitor getVariable ["operatorRenderTarget", "rendertarget0"];     
    private _cam = "camera" camCreate [0,0,0];     
    _cam cameraEffect ["internal", "back", _renderTarget];     
    _monitor setObjectTextureGlobal [_textureIndex, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"];     
    _monitor setVariable ["operatorCam", _cam, false];     
    _monitor setVariable ["connectedOperator", _operator, true];     
    _monitor setVariable ["operatorFeedActive", true, true];
    _monitor setVariable ["feedType", "operator", true];
    _monitor setVariable ["visionMode", 0, true];
    _renderTarget setPiPEffect [0];
    
    [_monitor] spawn {     
        params ["_monitor"];     
        private _cam = _monitor getVariable ["operatorCam", objNull];  
        private _offset = missionNamespace getVariable ["ARTEK_helmet_cam_offset", [0.2, 0, 0.175]];  
        private _pitch = missionNamespace getVariable ["ARTEK_helmet_cam_pitch", 0];  
        private _yaw = missionNamespace getVariable ["ARTEK_helmet_cam_yaw", 0];  
        private _roll = missionNamespace getVariable ["ARTEK_helmet_cam_roll", 0];  
        private _fov = missionNamespace getVariable ["ARTEK_helmet_cam_fov", 0.87];  
          
        while {_monitor getVariable ["operatorFeedActive", false] && !isNull _cam} do {     
            private _operator = _monitor getVariable ["connectedOperator", objNull];     
            if (isNull _operator || !alive _operator ||      
                !([_operator, ["ItemcTabHCam"]] call cTab_fnc_checkGear || "ItemcTabHCam" in (items _operator))) exitWith {     
                [_monitor] call ARTEK_fnc_stopOperatorFeed;     
            };  

            private _headPos = _operator selectionPosition "head"; 
            private _modelPos = _operator modelToWorldVisual _headPos; 
            private _dirVec = vectorDir _operator; 
            private _upVec = vectorUp _operator; 
            private _rightVec = _dirVec vectorCrossProduct _upVec; 
            private _offsetVec = (_rightVec vectorMultiply (_offset select 0)) vectorAdd (_dirVec vectorMultiply (_offset select 1)) vectorAdd (_upVec vectorMultiply (_offset select 2)); 
            private _camPos = _modelPos vectorAdd _offsetVec; 
            _cam setPosASL (AGLToASL _camPos); 
            private _modelDir = vectorDir _operator; 
            private _modelDirYaw = (_modelDir select 0) atan2 (_modelDir select 1); 
            private _finalYaw = _modelDirYaw + _yaw;  
            private _pitchRad = _pitch * (pi / 180);  
            private _dirX = sin(_finalYaw) * cos(_pitchRad);  
            private _dirY = cos(_finalYaw) * cos(_pitchRad);  
            private _dirZ = sin(_pitchRad);  
            private _finalDir = [_dirX, _dirY, _dirZ];  
            private _rollRad = _roll * (pi / 180);  
            private _camUpVec = [-sin(_finalYaw) * sin(_rollRad), -cos(_finalYaw) * sin(_rollRad), cos(_rollRad)];  
            _cam setVectorDirAndUp [_finalDir, _camUpVec];  
            _cam camSetFov _fov;  
            _cam camCommit 0;  
            sleep 0.01;     
        };  
          
        if (!isNull _cam) then {     
            _cam cameraEffect ["terminate", "back"];     
            camDestroy _cam;     
        };     
    };  
};

ARTEK_fnc_startVehicleFeed = {   
    params ["_monitor", "_vehicle", "_turretPath"];   
    private _textureIndex = [_monitor] call ARTEK_fnc_getOperatorTextureIndex;   
    private _renderTarget = _monitor getVariable ["operatorRenderTarget", "rendertarget0"];   
    private _cam = "camera" camCreate [0,0,0];   
    _cam cameraEffect ["Internal", "Back", _renderTarget];   
    _monitor setObjectTextureGlobal [_textureIndex, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"];   
    _monitor setVariable ["vehicleCam", _cam, false];   
    _monitor setVariable ["connectedVehicle", _vehicle, true];   
    _monitor setVariable ["turretPath", _turretPath, true];   
    _monitor setVariable ["operatorFeedActive", true, true];   
    _monitor setVariable ["feedType", "vehicle", true]; 
    _monitor setVariable ["visionMode", 0, true];   
    private _cameraPoints = [_vehicle] call ARTEK_fnc_getUAVCameraPoints;   
    private _posPoint = _cameraPoints select 0;   
    private _dirPoint = _cameraPoints select 1;   
    _monitor setVariable ["camPosPoint", _posPoint, false];   
    _monitor setVariable ["camDirPoint", _dirPoint, false];   
    _cam attachTo [_vehicle, [0,0,0], _posPoint];   
    _cam camSetFov 0.75;
    _cam camPrepareFov 0.75;
    _cam camSetFocus [10000, 1];
    _cam camPrepareFocus [10000, 1];   
    _renderTarget setPiPEffect [0];   
     
    [_monitor] spawn {   
        params ["_monitor"];   
        private _cam = _monitor getVariable ["vehicleCam", objNull];   
        while {_monitor getVariable ["operatorFeedActive", false] && !isNull _cam} do {   
            private _vehicle = _monitor getVariable ["connectedVehicle", objNull];   
            if (isNull _vehicle || !alive _vehicle) exitWith {[_monitor] call ARTEK_fnc_stopOperatorFeed;};   
            private _posPoint = _monitor getVariable ["camPosPoint", ""];   
            private _dirPoint = _monitor getVariable ["camDirPoint", ""];   
            if (_posPoint != "" && _dirPoint != "") then {   
                private _start = _vehicle selectionPosition _posPoint;   
                private _end = _vehicle selectionPosition _dirPoint;   
                if (!(_start isEqualTo [0,0,0]) && !(_end isEqualTo [0,0,0])) then {   
                    private _dir = _start vectorFromTo _end;   
                    _cam setVectorDirAndUp [_dir, _dir vectorCrossProduct [-(_dir select 1), _dir select 0, 0]];   
                };   
            }; 
            sleep 0.01;   
        };   
        if (!isNull _cam) then {   
            _cam cameraEffect ["terminate", "back"];   
            camDestroy _cam;   
        };   
    };   
};

ARTEK_fnc_startSpotterFeed = { 
    params ["_monitor", "_spotter"]; 
    private _textureIndex = [_monitor] call ARTEK_fnc_getOperatorTextureIndex; 
    private _renderTarget = _monitor getVariable ["operatorRenderTarget", "rendertarget0"]; 
    private _cam = "camera" camCreate [0,0,0]; 
    _cam cameraEffect ["internal", "back", _renderTarget]; 
    _monitor setObjectTextureGlobal [_textureIndex, "#(argb,512,512,1)r2t(" + _renderTarget + ",1.0)"]; 
    _monitor setVariable ["spotterCam", _cam, false]; 
    _monitor setVariable ["connectedSpotter", _spotter, true]; 
    _monitor setVariable ["operatorFeedActive", true, true]; 
    _monitor setVariable ["feedType", "spotter", true];
    _monitor setVariable ["visionMode", 0, true];
    _renderTarget setPiPEffect [0];
 
    [_monitor] spawn { 
        params ["_monitor"]; 
        private _cam = _monitor getVariable ["spotterCam", objNull]; 
        private _spotterOptics = [
            "Nikon_DSLR_HUD", "Nikon_DSLR", 
            "Hate_Smartphone_HUD", "Hate_Smartphone", 
            "Laserdesignator"
        ]; 
         
        while {_monitor getVariable ["operatorFeedActive", false] && !isNull _cam} do { 
            private _currentSpotter = _monitor getVariable ["connectedSpotter", objNull]; 
            if (isNull _currentSpotter || !alive _currentSpotter || !(currentWeapon _currentSpotter in _spotterOptics)) exitWith { 
                [_monitor] call ARTEK_fnc_stopOperatorFeed; 
            }; 
             
            private _camPos = eyePos _currentSpotter;
            private _camDir = vectorDir _currentSpotter;
            private _camUp = vectorUp _currentSpotter;
            private _currentFOV = 0.75; 
            private _weapon = currentWeapon _currentSpotter;
             
            if (_currentSpotter == player) then {
                if (cameraView == "GUNNER" && _weapon != "" && _weapon in _spotterOptics) then {
                    private _intersects = lineIntersectsSurfaces [
                        AGLToASL positionCameraToWorld [0, 0, 0],
                        AGLToASL positionCameraToWorld [0, 0, 10000],
                        _currentSpotter,
                        objNull,
                        true,
                        1,
                        "GEOM",
                        "NONE"
                    ];
                    
                    if (count _intersects > 0) then {
                        private _hitPos = (_intersects select 0) select 0;
                        private _eyeP = eyePos _currentSpotter;
                        _camDir = _eyeP vectorFromTo _hitPos;
                    } else {
                        _camDir = (positionCameraToWorld [0, 0, 1]) vectorDiff (positionCameraToWorld [0, 0, 0]);
                    };
                    
                    _camPos = eyePos _currentSpotter;
                    
                    private _config = configFile >> "CfgWeapons" >> _weapon; 
                    if (isClass _config) then { 
                        private _zoomMin = getNumber (_config >> "opticsZoomMin"); 
                        if (_zoomMin > 0) then { 
                            private _currentZoom = (call ARTEK_fnc_getCurrentOpticsZoom); 
                            if (!isNil "_currentZoom" && {_currentZoom > 0}) then { 
                                _currentFOV = _currentZoom; 
                            } else { 
                                _currentFOV = _zoomMin max 0.001; 
                            };
                        };
                    };
                } else {
                    if (_weapon != "" && _weapon in _spotterOptics) then { 
                        private _config = configFile >> "CfgWeapons" >> _weapon; 
                        if (isClass _config) then { 
                            private _zoomInit = getNumber (_config >> "opticsZoomInit"); 
                            if (_zoomInit > 0) then { 
                                _currentFOV = (_zoomInit max 0.001) min 0.75; 
                            }; 
                        }; 
                    };
                };
            } else {
                if (_weapon != "" && _weapon in _spotterOptics) then { 
                    private _config = configFile >> "CfgWeapons" >> _weapon; 
                    if (isClass _config) then { 
                        private _zoomMin = getNumber (_config >> "opticsZoomMin"); 
                        private _zoomInit = getNumber (_config >> "opticsZoomInit"); 
                        if (_zoomMin > 0) then { 
                            _currentFOV = (_zoomInit max 0.001) min 0.75; 
                        }; 
                    }; 
                };
            };
             
            _cam setPosASL _camPos; 
            _cam setVectorDirAndUp [_camDir, _camUp]; 
            _cam camSetFov _currentFOV;
            _cam camPrepareFov _currentFOV;
            _cam camSetFocus [5000, 1];
            _cam camPrepareFocus [5000, 1]; 
            _cam camCommit 0; 
            sleep 0.01; 
        }; 
         
        if (!isNull _cam) then { 
            _cam cameraEffect ["terminate", "back"]; 
            camDestroy _cam; 
        }; 
    }; 
};
     
ARTEK_fnc_stopOperatorFeed = {     
    params ["_monitor"];     
    if (isNull _monitor) exitWith {}; 
    _monitor setVariable ["operatorFeedActive", false, true];  
    
    private _cam = _monitor getVariable ["operatorCam", objNull];  
    if (!isNull _cam) then {  
        _cam cameraEffect ["terminate", "back"];  
        camDestroy _cam;
        _monitor setVariable ["operatorCam", objNull, false];  
    };
    
    private _vehicleCam = _monitor getVariable ["vehicleCam", objNull];  
    if (!isNull _vehicleCam) then {  
        _vehicleCam cameraEffect ["terminate", "back"];  
        camDestroy _vehicleCam;
        _monitor setVariable ["vehicleCam", objNull, false];  
    };
    
    private _spotterCam = _monitor getVariable ["spotterCam", objNull];  
    if (!isNull _spotterCam) then {  
        _spotterCam cameraEffect ["terminate", "back"];  
        camDestroy _spotterCam;
        _monitor setVariable ["spotterCam", objNull, false];  
    };
    
    private _textureIndex = [_monitor] call ARTEK_fnc_getOperatorTextureIndex;  
    _monitor setObjectTextureGlobal [_textureIndex, "a3\data_f\black_sum.paa"];
    _monitor setVariable ["connectedOperator", objNull, true]; 
    _monitor setVariable ["connectedVehicle", objNull, true]; 
    _monitor setVariable ["connectedSpotter", objNull, true];
    _monitor setVariable ["feedType", "none", true];
}; 
 
ARTEK_fnc_disconnectSingleMonitor = { 
    params ["_monitorNetId"]; 
    private _monitor = objectFromNetId _monitorNetId; 
    if (!isNull _monitor) then { 
        [_monitor] call ARTEK_fnc_stopOperatorFeed; 
    }; 
};     
     
ARTEK_fnc_syncOperatorMonitorState = {     
    params ["_monitorNetId", "_operatorNetId", "_start"];     
    private _monitor = objectFromNetId _monitorNetId;     
    private _operator = objectFromNetId _operatorNetId;     
    if (isNull _monitor) exitWith {};     
    if (_start) then {     
        if (!isNull _operator) then {     
            [_monitor, _operator] call ARTEK_fnc_startOperatorFeed;   
        };     
    } else {
        [_monitor] call ARTEK_fnc_stopOperatorFeed;
    };     
};

ARTEK_fnc_syncVehicleMonitorState = {   
    params ["_monitorNetId", "_vehicleNetId", "_turretPath", "_start"];   
    private _monitor = objectFromNetId _monitorNetId;   
    private _vehicle = objectFromNetId _vehicleNetId;   
    if (isNull _monitor) exitWith {};   
    if (_start) then {   
        if (!isNull _vehicle) then {   
            [_monitor, _vehicle, _turretPath] call ARTEK_fnc_startVehicleFeed;   
        };   
    } else {   
        [_monitor] call ARTEK_fnc_stopOperatorFeed;   
    };   
};

ARTEK_fnc_syncSpotterMonitorState = { 
    params ["_monitorNetId", "_spotterNetId", "_start"]; 
    private _monitor = objectFromNetId _monitorNetId; 
    private _spotter = objectFromNetId _spotterNetId; 
    if (isNull _monitor) exitWith {}; 
    if (_start) then { 
        if (!isNull _spotter) then { 
            [_monitor, _spotter] call ARTEK_fnc_startSpotterFeed; 
        }; 
    } else { 
        [_monitor] call ARTEK_fnc_stopOperatorFeed; 
    }; 
};

ARTEK_fnc_buildOperatorList = {
    params ["_operators", "_caller"];
    private _operatorList = [];
    {
        private _group = "";
        private _number = "";
        private _dist = "";
        if (missionNamespace getVariable ["ARTEK_allow_groupID", false]) then {
            _group = groupId (group _x);
            _group = format ["[%1] ", _group];
        };
        if (missionNamespace getVariable ["ARTEK_allow_groupNumber", false]) then {
            _number = ((units (group _x)) find _x) + 1;
            _number = format ["[%1] ", _number];
        };
        if (missionNamespace getVariable ["ARTEK_allow_distance", false]) then {
            _dist = round (_caller distance _x);
            _dist = format [" (%1m)", _dist];
        };
        private _color = if (side _x == civilian) then {[0.5, 0, 0.5, 1]} else {missionNamespace getVariable ["ARTEK_ui_color_list", [0, 0.42, 1, 1]]};
        _operatorList pushBack [format["%1%2%3%4", _group, _number, name _x, _dist], _color, _x];
    } forEach _operators;
    _operatorList
};

ARTEK_fnc_buildSpotterList = {
    params ["_spotters", "_caller"];
    private _spotterList = [];
    {
        private _group = "";
        private _number = "";
        private _dist = "";
        if (missionNamespace getVariable ["ARTEK_allow_groupID", false]) then {
            _group = groupId (group _x);
            _group = format ["[%1] ", _group];
        };
        if (missionNamespace getVariable ["ARTEK_allow_groupNumber", false]) then {
            _number = ((units (group _x)) find _x) + 1;
            _number = format ["[%1] ", _number];
        };
        if (missionNamespace getVariable ["ARTEK_allow_distance", false]) then {
            _dist = round (_caller distance _x);
            _dist = format [" (%1m)", _dist];
        };
        private _opticName = getText (configFile >> "CfgWeapons" >> (currentWeapon _x) >> "displayName");
        private _civilianOptics = ["Nikon_DSLR_HUD", "Nikon_DSLR", "Hate_Smartphone_HUD", "Hate_Smartphone"];
        private _color = if (currentWeapon _x in _civilianOptics) then {
            [0.5, 0, 0.5, 1]
        } else {
            missionNamespace getVariable ["ARTEK_ui_color_list", [0, 0.42, 1, 1]]
        };
        _spotterList pushBack [format["%1%2%3 [%4]%5", _group, _number, name _x, _opticName, _dist], _color, _x];
    } forEach _spotters;
    _spotterList
};

ARTEK_fnc_buildVehicleList = {
    params ["_vehicles", "_caller"];
    private _vehicleList = [];
    {
        private _veh = _x;
        private _dist = round(_caller distance _veh);
        private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
        private _turrets = allTurrets [_veh, true];
        {
            private _turretPath = _x;
            private _turretConfig = [_veh, _turretPath] call BIS_fnc_turretConfig;
            private _turretName = getText (_turretConfig >> "gunnerName");
            if (_turretName == "") then {_turretName = "Main Turret";};
            private _displayText = format["%1 - %2 (%3m)", _vehName, _turretName, _dist];
            _vehicleList pushBack [_displayText, [0, 0.42, 1, 1], _veh, _turretPath];
        } forEach _turrets;
    } forEach _vehicles;
    _vehicleList
};
   
ARTEK_fnc_initOperatorCam = {     
    params ["_monitor"];     
    removeAllActions _monitor;     
    private _renderIndex = ARTEK_OperatorCam_Index mod 4;     
    ARTEK_OperatorCam_Index = ARTEK_OperatorCam_Index + 1;     
    _monitor setVariable ["operatorRenderTarget", format["rendertarget%1", _renderIndex], true];     
    _monitor setVariable ["operatorFeedActive", false, true];
    _monitor setVariable ["feedType", "none", true];     
    
    if (!hasInterface) exitWith {};
   
    private _statement_selectOperator = {
        params ["_target", "_caller"];    
        private _operators = [_caller] call ARTEK_fnc_getOperatorsWithCamera;    
        if (count _operators == 0) exitWith { hintSilent (missionNamespace getVariable ["ARTEK_string_nocams_hint", "No operators with cameras available"]); };    
        private _operatorList = [_operators, _caller] call ARTEK_fnc_buildOperatorList;
        [    
            missionNamespace getVariable ["ARTEK_string_interactionMenu_select", "Select Operator"],    
            _operatorList,    
            {    
                params ["_choice", "_target", "_operatorList"];    
                private _selectedOperator = (_operatorList select _choice) select 2;    
                [[netId _target, netId _selectedOperator, true], "ARTEK_fnc_syncOperatorMonitorState", true, false] call BIS_fnc_MP;    
            },    
            {},    
            [_target, _operatorList]    
        ] call ARTEK_fnc_selectOperatorDialog;    
    };   
   
    private _condition_selectOperator = { !(_target getVariable ["operatorFeedActive", false]) };   
   
    private _statement_changeOperator = {    
        params ["_target", "_caller"];    
        private _operators = [_caller] call ARTEK_fnc_getOperatorsWithCamera;    
        if (count _operators == 0) exitWith { hintSilent "No operators with cameras available"; };    
        private _operatorList = [_operators, _caller] call ARTEK_fnc_buildOperatorList;
        [    
            missionNamespace getVariable ["ARTEK_string_interactionMenu_change", "Change Operator"],    
            _operatorList,    
            {    
                params ["_choice", "_target", "_operatorList"];    
                private _selectedOperator = (_operatorList select _choice) select 2;    
                [_target, _selectedOperator] spawn {   
                    params ["_target", "_selectedOperator"];   
                    [[netId _target, "", false], "ARTEK_fnc_syncOperatorMonitorState", true, false] call BIS_fnc_MP;   
                    sleep 0.1;   
                    [[netId _target, netId _selectedOperator, true], "ARTEK_fnc_syncOperatorMonitorState", true, false] call BIS_fnc_MP;   
                };   
            },    
            {},    
            [_target, _operatorList]    
        ] call ARTEK_fnc_selectOperatorDialog;    
    };   
   
    private _condition_changeOperator = { 
        _target getVariable ["operatorFeedActive", false] && 
        (_target getVariable ["feedType", "none"]) == "operator"
    };

    private _statement_selectVehicle = {
        params ["_target", "_caller"];
        private _vehicles = [_caller] call ARTEK_fnc_getVehiclesWithTurrets;
        if (count _vehicles == 0) exitWith {hintSilent "No drones with turrets available.";};
        private _vehicleList = [_vehicles, _caller] call ARTEK_fnc_buildVehicleList;
        if (count _vehicleList == 0) exitWith {hintSilent "No turrets available.";};
        [
            "Select Drone Turret",
            _vehicleList,
            {
                params ["_choice", "_target", "_vehicleList"];
                private _selectedVehicle = (_vehicleList select _choice) select 2;
                private _selectedTurret = (_vehicleList select _choice) select 3;
                [[netId _target, netId _selectedVehicle, _selectedTurret, true], "ARTEK_fnc_syncVehicleMonitorState", true, false] call BIS_fnc_MP;
            },
            {},
            [_target, _vehicleList]
        ] call ARTEK_fnc_selectOperatorDialog;
    };
    
    private _condition_selectVehicle = { !(_target getVariable ["operatorFeedActive", false]) };
    
    private _statement_changeVehicle = {
        params ["_target", "_caller"];
        private _vehicles = [_caller] call ARTEK_fnc_getVehiclesWithTurrets;
        if (count _vehicles == 0) exitWith {hintSilent "No drones with turrets available.";};
        private _vehicleList = [_vehicles, _caller] call ARTEK_fnc_buildVehicleList;
        if (count _vehicleList == 0) exitWith {hintSilent "No turrets available.";};
        [
            "Change Drone Turret",
            _vehicleList,
            {
                params ["_choice", "_target", "_vehicleList"];
                private _selectedVehicle = (_vehicleList select _choice) select 2;
                private _selectedTurret = (_vehicleList select _choice) select 3;
                [_target, _selectedVehicle, _selectedTurret] spawn {
                    params ["_target", "_selectedVehicle", "_selectedTurret"];
                    [[netId _target, "", [], false], "ARTEK_fnc_syncVehicleMonitorState", true, false] call BIS_fnc_MP;
                    sleep 0.1;
                    [[netId _target, netId _selectedVehicle, _selectedTurret, true], "ARTEK_fnc_syncVehicleMonitorState", true, false] call BIS_fnc_MP;
                };
            },
            {},
            [_target, _vehicleList]
        ] call ARTEK_fnc_selectOperatorDialog;
    };
    
    private _condition_changeVehicle = { 
        _target getVariable ["operatorFeedActive", false] && 
        (_target getVariable ["feedType", "none"]) == "vehicle"
    };

    private _statement_selectSpotter = {
        params ["_target", "_caller"];
        private _spotters = [_caller] call ARTEK_fnc_getSpottersWithOptics;
        if (count _spotters == 0) exitWith {hintSilent "No spotters with optics available";};
        private _spotterList = [_spotters, _caller] call ARTEK_fnc_buildSpotterList;
        [
            "Select Spotter",
            _spotterList,
            {
                params ["_choice", "_target", "_spotterList"];
                private _selectedSpotter = (_spotterList select _choice) select 2;
                [[netId _target, netId _selectedSpotter, true], "ARTEK_fnc_syncSpotterMonitorState", true, false] call BIS_fnc_MP;
            },
            {},
            [_target, _spotterList]
        ] call ARTEK_fnc_selectOperatorDialog;
    };
    
    private _condition_selectSpotter = { !(_target getVariable ["operatorFeedActive", false]) };
    
    private _statement_changeSpotter = {
        params ["_target", "_caller"];
        private _spotters = [_caller] call ARTEK_fnc_getSpottersWithOptics;
        if (count _spotters == 0) exitWith {hintSilent "No spotters with optics available";};
        private _spotterList = [_spotters, _caller] call ARTEK_fnc_buildSpotterList;
        [
            "Change Spotter",
            _spotterList,
            {
                params ["_choice", "_target", "_spotterList"];
                private _selectedSpotter = (_spotterList select _choice) select 2;
                [_target, _selectedSpotter] spawn {
                    params ["_target", "_selectedSpotter"];
                    [[netId _target, "", false], "ARTEK_fnc_syncSpotterMonitorState", true, false] call BIS_fnc_MP;
                    sleep 0.1;
                    [[netId _target, netId _selectedSpotter, true], "ARTEK_fnc_syncSpotterMonitorState", true, false] call BIS_fnc_MP;
                };
            },
            {},
            [_target, _spotterList]
        ] call ARTEK_fnc_selectOperatorDialog;
    };
    
    private _condition_changeSpotter = { 
        _target getVariable ["operatorFeedActive", false] && 
        (_target getVariable ["feedType", "none"]) == "spotter"
    };

    private _statement_changeVision = {
        [_this select 0] call ARTEK_fnc_changeVisionMode;
    };
    
    private _condition_changeVision = {
        _target getVariable ["operatorFeedActive", false] && 
        ((_target getVariable ["feedType", "none"]) == "vehicle" || 
         (_target getVariable ["feedType", "none"]) == "operator" || 
         (_target getVariable ["feedType", "none"]) == "spotter")
    };
   
    private _statement_disconnect_cams = {    
        params ["_target"];    
        [[netId _target], "ARTEK_fnc_disconnectSingleMonitor", true, false] call BIS_fnc_MP; 
    };   
   
    private _condition_disconnect_cams = { _target getVariable ["operatorFeedActive", false] };   
   
    if (missionNamespace getVariable ["ARTEK_use_ace_interaction", false]) then {   
        private _selectOperator = ["Select Operator", missionNamespace getVariable ["ARTEK_string_interactionMenu_select", "Select Operator"], "", _statement_selectOperator, _condition_selectOperator, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;   
        private _changeOperator = ["Change Operator", missionNamespace getVariable ["ARTEK_string_interactionMenu_change", "Change Operator"], "", _statement_changeOperator, _condition_changeOperator, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _selectVehicle = ["Select Drone", "Select Drone", "", _statement_selectVehicle, _condition_selectVehicle, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _changeVehicle = ["Change Drone", "Change Drone", "", _statement_changeVehicle, _condition_changeVehicle, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _selectSpotter = ["Select Spotter", "Select Spotter", "", _statement_selectSpotter, _condition_selectSpotter, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _changeSpotter = ["Change Spotter", "Change Spotter", "", _statement_changeSpotter, _condition_changeSpotter, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _changeVision = ["Change Vision", "Change Vision", "", _statement_changeVision, _condition_changeVision, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
        private _disconnectCams = ["Disconnect Camera", missionNamespace getVariable ["ARTEK_string_interactionMenu_disconnect", "Disconnect Camera"], "", _statement_disconnect_cams, _condition_disconnect_cams, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;   
        [_monitor, 0, ["ACE_MainActions"], _selectOperator] call ace_interact_menu_fnc_addActionToObject;   
        [_monitor, 0, ["ACE_MainActions"], _changeOperator] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _selectVehicle] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _changeVehicle] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _selectSpotter] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _changeSpotter] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _changeVision] call ace_interact_menu_fnc_addActionToObject;
        [_monitor, 0, ["ACE_MainActions"], _disconnectCams] call ace_interact_menu_fnc_addActionToObject;   
    } else {   
        _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_select", "Select Operator"], _statement_selectOperator, nil, 1.5, true, true, "", str _condition_selectOperator];   
        _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_change", "Change Operator"], _statement_changeOperator, nil, 1.4, true, true, "", str _condition_changeOperator];
        _monitor addAction ["Select Drone", _statement_selectVehicle, nil, 1.3, true, true, "", str _condition_selectVehicle];
        _monitor addAction ["Change Drone", _statement_changeVehicle, nil, 1.2, true, true, "", str _condition_changeVehicle];
        _monitor addAction ["Select Spotter", _statement_selectSpotter, nil, 1.25, true, true, "", str _condition_selectSpotter];
        _monitor addAction ["Change Spotter", _statement_changeSpotter, nil, 1.15, true, true, "", str _condition_changeSpotter];
        _monitor addAction ["Change Vision", _statement_changeVision, nil, 1.1, true, true, "", str _condition_changeVision];
        _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_disconnect", "Disconnect Camera"], _statement_disconnect_cams, nil, 1.0, true, true, "", str _condition_disconnect_cams];   
    };   
};     
     
if (isServer) then {     
    ARTEK_OperatorCam_Initialized = true;     
    publicVariable "ARTEK_OperatorCam_Initialized";     
};     
     
{   
    if (!isNull _x) then {   
        [_x] call ARTEK_fnc_initOperatorCam;   
    };   
} forEach ARTEK_OperatorCam_SyncConfig;