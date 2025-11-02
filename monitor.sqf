private _use_ace_interaction = true;
private _show_group = true;
private _show_group_number = true;
private _show_distance = true;
private _show_civillian = false;
private _helment_camera_pos_xyz = [0, 0.1, -0.1];
private _ui_color_list_rgba = [0.8, 0.051, 0.051, 1];
private _ui_color_confirm_rgba = [0.8, 0.051, 0.051, 0.8];
private _ui_color_cancel_rgba = [0.3, 0.02, 0.02, 0.8];
private _ui_color_header_hex_RRGGBB = "#cc0d0d";
private _string_ui_confirm = "Confirm";
private _string_ui_cancel = "Cancel";
private _string_interactionMenu_select_operator = "Select Operator";
private _string_interactionMenu_change_operator = "Change Operator";
private _string_interactionMenu_disconnect_camera = "Disconnect Cameras";
ARTEK_fnc_getOperatorTextureIndex = { 0 };

if ((count _ui_color_header_hex_RRGGBB) == 9) then {
    _ui_color_header_hex_RRGGBB = _ui_color_header_hex_RRGGBB select [0,7];
};

if (isServer) then {
	missionNamespace setVariable ["ARTEK_allow_groupID",_show_group, true];
	missionNamespace setVariable  ["ARTEK_allow_groupNumber",_show_group_number, true];
	missionNamespace setVariable  ["ARTEK_allow_distance",_show_distance, true]; 
	missionNamespace setVariable  ["ARTEK_allow_civillian",_show_civillian, true];
	missionNamespace setVariable ["ARTEK_ui_color_list",_ui_color_list_rgba, true];
	missionNamespace setVariable ["ARTEK_ui_color_confirm",_ui_color_confirm_rgba, true];
	missionNamespace setVariable ["ARTEK_ui_color_cancel",_ui_color_cancel_rgba, true];
	missionNamespace setVariable ["ARTEK_ui_color_header",_ui_color_header_hex_RRGGBB, true];
	missionNamespace setVariable ["ARTEK_string_ui_confirm",_string_ui_confirm, true];
	missionNamespace setVariable ["ARTEK_string_ui_cancel",_string_ui_cancel, true];
	missionNamespace setVariable ["ARTEK_string_interactionMenu_select",_string_interactionMenu_select_operator,true];
	missionNamespace setVariable ["ARTEK_string_interactionMenu_change",_string_interactionMenu_change_operator,true];
	missionNamespace setVariable ["ARTEK_string_interactionMenu_disconnect",_string_interactionMenu_disconnect_camera,true];
    if (isClass (configFile >> "CfgPatches" >> "ace_main") && _use_ace_interaction) then { missionNamespace setVariable ["ARTEK_use_ace_interaction", true, true]; };
    missionNamespace setVariable ["ARTEK_adjust_hcam_pos", _helment_camera_pos_xyz, true];

	private _ARTEK_OperatorCam_SyncConfig = [];
	{
		_ARTEK_OperatorCam_SyncConfig pushBack _x;
		_x setVehicleVarName format ["ARTEK_monitor_%1", _forEachIndex];
	} forEach synchronizedObjects this;
	missionNamespace setVariable ["ARTEK_OperatorCam_SyncConfig", _ARTEK_OperatorCam_SyncConfig];
};

ARTEK_fnc_shouldInitMonitor = {
    params ["_varName"];
    private _shouldInit = false;
    
    {
        if (_x == _varName) exitWith {
            _shouldInit = true;
        };
    } forEach ARTEK_OperatorCam_SyncConfig;
    
    _shouldInit
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
    _listBox lbSetCurSel 0; 
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
        private _onConfirm = _display getVariable ["onConfirm", {}]; 
        private _params = _display getVariable ["params", []]; 
        [_selected] + _params call _onConfirm; 
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
    allUnits select {  
        (side _x == west || (side _x == civilian && missionNamespace getVariable ["ARTEK_allow_civillian", false])) &&  
        alive _x &&  
        !isNull _x &&  
        ([_x, ["ItemcTabHCam"]] call cTab_fnc_checkGear || "ItemcTabHCam" in (items _x))  
    }  
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
 
    [_monitor] spawn {  
        params ["_monitor"];  
        private _cam = _monitor getVariable ["operatorCam", objNull];  
        while {_monitor getVariable ["operatorFeedActive", false] && !isNull _cam} do {  
            private _operator = _monitor getVariable ["connectedOperator", objNull];  
            if (isNull _operator || !alive _operator ||   
                !([_operator, ["ItemcTabHCam"]] call cTab_fnc_checkGear || "ItemcTabHCam" in (items _operator))) exitWith {  
                [_monitor] call ARTEK_fnc_stopOperatorFeed;  
            };  
            private _eyePos = eyePos _operator;  
            private _eyeDir = eyeDirection _operator;  
            private _adjustedPos = _eyePos vectorAdd ((_eyeDir vectorMultiply 0.08) vectorAdd (missionNamespace getVariable ["ARTEK_adjust_hcam_pos", [0.12, 0, 0.15]]));
            _cam setPosASL _adjustedPos;  
            _cam setVectorDirAndUp [_eyeDir, [0,0,1]];  
            _cam camSetFov 0.85;  
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

    {
        _monitor = _x;
        _monitor setVariable ["operatorFeedActive", false, true];  
        private _cam = _monitor getVariable ["operatorCam", objNull];  
        if (!isNull _cam) then {  
            _cam cameraEffect ["terminate", "back"];  
            camDestroy _cam;  
        };  
        private _textureIndex = [_monitor] call ARTEK_fnc_getOperatorTextureIndex;  
        _monitor setObjectTextureGlobal [_textureIndex, "a3\data_f\black_sum.paa"];
        _monitor setVariable ["connectedOperator", objNull, true]; 
    } forEach ARTEK_OperatorCam_SyncConfig;
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
    };  
};  

ARTEK_fnc_initOperatorCam = {  
    params ["_monitor"];  
    removeAllActions _monitor;  
 
    private _renderIndex = ARTEK_OperatorCam_Index mod 4;  
    ARTEK_OperatorCam_Index = ARTEK_OperatorCam_Index + 1;  
    _monitor setVariable ["operatorRenderTarget", format["rendertarget%1", _renderIndex], true];  
    _monitor setVariable ["operatorFeedActive", false, true];  
 
    if (hasInterface) then {

        private _statement_selectOperator = {
            params ["_target", "_caller"]; 
            private _operators = call ARTEK_fnc_getOperatorsWithCamera; 
            if (count _operators == 0) exitWith { hintSilent "No operators with cameras available"; }; 
 
            private _operatorList = []; 
            {
				private _group = "";
				private _number = "";
				private _dist = "";

				if (missionNamespace getVariable ["ARTEK_allow_groupID",false]) then { 
					_group = groupId (group _x); 
					_group = format ["[%1] ", _group]; 
				};

				if (missionNamespace getVariable  ["ARTEK_allow_groupNumber",false]) then { 
					_number = ((units (group _x)) find _x)+1;
					_number = format ["[%1] ", _number];
				};

				if (missionNamespace getVariable  ["ARTEK_allow_distance",false]) then { 
					_dist = round (_caller distance _x);  
					_dist = format [" (%1m)", _dist]; 
				};
                
                private _color = if (side _x == civilian) then {[0.5, 0, 0.5, 1]} else {missionNamespace getVariable ["ARTEK_ui_color_list",[0, 0.42, 1, 1]]};
                _operatorList pushBack [format["%1%2%3%4", _group, _number, name _x, _dist], _color, _x];
            } forEach _operators; 
 
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

        private _condition_selectOperator = { !(_target getVariable ["operatorFeedActive",false]) };

        private _statement_changeOperator = { 
            params ["_target", "_caller"]; 
            private _operators = call ARTEK_fnc_getOperatorsWithCamera; 
            if (count _operators == 0) exitWith { hintSilent "No operators with cameras available"; }; 
 
            private _operatorList = []; 
            {
				private _group = "";
				private _number = "";
				private _dist = "";

				if (missionNamespace getVariable ["ARTEK_allow_groupID",false]) then { 
					_group = groupId (group _x); 
					_group = format ["[%1] ", _group]; 
				};

				if (missionNamespace getVariable  ["ARTEK_allow_groupNumber",false]) then { 
					_number = ((units (group _x)) find _x)+1;

					if (missionNamespace getVariable ["ARTEK_allow_groupID",false]) then {
						_number = format [" %1. ", _number]; 
					} else {
						_number = format ["%1. ", _number]; 
					};
				};

				if (missionNamespace getVariable  ["ARTEK_allow_distance",false]) then { 
					_dist = round (_caller distance _x);  
					_dist = format [" (%1m)", _dist]; 
				};
                
                private _color = if (side _x == civilian) then {[0.5, 0, 0.5, 1]} else {missionNamespace getVariable ["ARTEK_ui_color_list",[0, 0.42, 1, 1]]};
                _operatorList pushBack [format["%1%2%3%4", _group, _number, name _x, _dist], _color, _x];
            } forEach _operators; 
 
            [ 
                missionNamespace getVariable ["ARTEK_string_interactionMenu_select","Change Operator"], 
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

        private _condition_changeOperator = { _target getVariable ['operatorFeedActive',false] };

        private _statement_disconnect_cams = { 
            params ["_target"]; 
            [[_target], "ARTEK_fnc_stopOperatorFeed", true, false] call BIS_fnc_MP; 
        };

        private _condition_disconnect_cams = { _target getVariable ['operatorFeedActive',false] };

        if (missionNamespace getVariable ["ARTEK_use_ace_interaction", true]) then {
            private _actions = [];
            private _selectOperator = ["Select Operator", missionNamespace getVariable ["ARTEK_string_interactionMenu_select", "Select Operator"], "", _statement_selectOperator, _condition_selectOperator, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
            private _changeOperator = ["Change Operator", missionNamespace getVariable ["ARTEK_string_interactionMenu_change", "Change Operator"], "", _statement_changeOperator, _condition_changeOperator, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
            private _disconnectCams = ["Disconnect Camera", missionNamespace getVariable ["ARTEK_string_interactionMenu_disconnect","Disconnect Camera"], "", _statement_disconnect_cams, _condition_disconnect_cams, {}, [], [0, 0, 0], 3] call ace_interact_menu_fnc_createAction;
            [_monitor, 0, ["ACE_MainActions"], _selectOperator] call ace_interact_menu_fnc_addActionToObject;
            [_monitor, 0, ["ACE_MainActions"], _changeOperator] call ace_interact_menu_fnc_addActionToObject;
            [_monitor, 0, ["ACE_MainActions"], _disconnectCams] call ace_interact_menu_fnc_addActionToObject;
            
        } else {
            _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_select", "Select Operator"], _statement_selectOperator, nil, 1.5, true, true, "", str _condition_selectOperator];
            _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_change","Change Operator"], _statement_changeOperator, nil, 1.4, true, true, "", str _condition_changeOperator];
            _monitor addAction [missionNamespace getVariable ["ARTEK_string_interactionMenu_disconnect","Disconnect Camera"], _statement_disconnect_cams, nil, 1.3, true, true, "", str _condition_disconnect_cams];
        };
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