/* -------------------------
    System Configurator v0.51
    Dark UI Add buttons & Link layout fixed
-------------------------
*/ 

#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

global g_ini_file        := A_ScriptDir "\System-Config.ini"
global g_tab_names       := []
global g_tab_data        := {}
global g_current_tab     := 1
global g_current_mode    := "Config"
global g_tab_menu        := "TabMenu"

global dark_background := "1E1E1E"
global font_color := "D6D6D6"

global g_win_vars := ["chk_win_admin", "chk_win_prompt", "chk_win_uac", "chk_win_game_dvr", "chk_win_ads", "chk_win_lock_screen", "chk_win_narrator", "chk_win_usb", "chk_win_taskbar", "chk_win_widgets"]

; Right Click event for Tab Menu
OnMessage(0x204, "WM_RBUTTONDOWN") 

; ==========================================
;         INIT & DATA LOADING
; ==========================================
loadState()

Menu, %g_tab_menu%, Add, Add New Program Tab, onAddProgram
Menu, %g_tab_menu%, Add, Rename Current Tab, onRenameTab
Menu, %g_tab_menu%, Add, Delete Current Tab, onDeleteTab

; ==========================================
;         GUI CONSTRUCTION
; ==========================================
Gui, +hwndh_main_gui +LastFound
Gui, Color, %dark_background%, %dark_background%
Gui, Margin, 14, 14
Gui, Font, s10 c%font_color%, Segoe UI

DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", h_main_gui, "Int", 20, "Int*", true, "Int", 4)

; Mode Selection Button
Gui, Add, GroupBox, x20 y10 w1160 h80 c%font_color%, Execution Mode
Gui, Font, s12 Bold
Gui, Add, Button, vmode_btn gtoggleMode x40 y35 w250 h40 hwndh_mode, MODE: %g_current_mode%
setDarkControl(h_mode)
Gui, Font, s10 Norm

tab_str := ""
For tab_idx, tab_name in g_tab_names
    tab_str .= tab_name "|"

Gui, Add, Tab3, vmain_tab gonTabChanged x20 y110 w1160 h650 hwndh_tab AltSubmit Choose%g_current_tab%, %tab_str%
DllCall("uxtheme\SetWindowTheme", "Ptr", h_tab, "Str", "DarkMode_Explorer", "Ptr", 0)
GuiControl, +cDDDDDD, main_tab

For tab_idx, tab_name in g_tab_names 
{
    Gui, Tab, %tab_idx% 
    if (tab_idx == 1) {
        Gui, Font, s12 Bold c5599FF
        Gui, Add, Text, x40 y150, SYSTEM REGISTRY MODIFICATIONS
        Gui, Font, s12 Norm c%font_color%
        
        Gui, Add, CheckBox, vchk_win_admin Checked%chk_win_admin% x40 y190 BackgroundTrans, Toggle Administrator Account
        Gui, Add, CheckBox, vchk_win_prompt Checked%chk_win_prompt% x40 y230 BackgroundTrans, Toggle ConsentPromptBehaviorAdmin
        Gui, Add, CheckBox, vchk_win_uac Checked%chk_win_uac% x40 y270 BackgroundTrans, Toggle UAC / Secure Desktop overrides
        Gui, Add, CheckBox, vchk_win_game_dvr Checked%chk_win_game_dvr% x40 y310 BackgroundTrans, Disable GameDVR
        Gui, Add, CheckBox, vchk_win_ads Checked%chk_win_ads% x40 y350 BackgroundTrans, Disable Windows Advertising
        Gui, Add, CheckBox, vchk_win_lock_screen Checked%chk_win_lock_screen% x40 y390 BackgroundTrans, Disable Lock Screen
        Gui, Add, CheckBox, vchk_win_narrator Checked%chk_win_narrator% x40 y430 BackgroundTrans, Disable Narrator
        Gui, Add, CheckBox, vchk_win_usb Checked%chk_win_usb% x40 y470 BackgroundTrans, Disable USB Selective Suspend
        Gui, Add, CheckBox, vchk_win_taskbar Checked%chk_win_taskbar% x40 y510 BackgroundTrans, Toggle Taskbar Icon Combine
        Gui, Add, CheckBox, vchk_win_widgets Checked%chk_win_widgets% x40 y550 BackgroundTrans, Disable Widgets

    } else {
        data := g_tab_data[tab_name]
        y_pos := 150
        
        ; 1. PATHS
        Gui, Font, Bold c5599FF
        Gui, Add, Text, x40 y%y_pos%, 1. Main Executable Paths
        Gui, Font, Norm c%font_color%
        y_pos += 25
        For i, p in data.paths {
            var_d := "btn_path_d_" tab_idx "_" i
            var_f := "btn_path_f_" tab_idx "_" i
            var_edit := "edit_path_" tab_idx "_" i
            var_del := "btn_del_path_" tab_idx "_" i
            
            Gui, Add, Edit, v%var_edit% x40 y%y_pos% w750 h25, %p%
            Gui, Add, Button, v%var_d% gonBrowsePathDir hwndh_d x800 y%y_pos% w30 h25, D
            Gui, Add, Button, v%var_f% gonBrowsePathFile hwndh_f x835 y%y_pos% w30 h25, F
            
            if (i > 1) {
                Gui, Add, Button, v%var_del% gonDeletePath hwndh_del x875 y%y_pos% w30 h25, X
                setDarkControl(h_del)
            }
            setDarkControl(h_d), setDarkControl(h_f)
            y_pos += 30
        }
        Gui, Add, Button, hwndh_addp gonAddPath x40 y%y_pos% w100 h25, + Add Path
        setDarkControl(h_addp)
        y_pos += 45
        
        ; 2. ENVS
        Gui, Font, Bold c5599FF
        Gui, Add, Text, x40 y%y_pos%, 2. Environment Variables
        Gui, Font, Norm c%font_color%
        y_pos += 25
        For i, e in data.envs {
            var_name := "edit_env_name_" tab_idx "_" i
            var_d := "btn_env_d_" tab_idx "_" i
            var_f := "btn_env_f_" tab_idx "_" i
            var_val := "edit_env_val_" tab_idx "_" i
            var_del := "btn_del_env_" tab_idx "_" i
            
            Gui, Add, Edit, v%var_name% x40 y%y_pos% w200 h25, % e.name
            Gui, Add, Edit, v%var_val% x250 y%y_pos% w500 h25, % e.val
            Gui, Add, Button, v%var_d% gonBrowseEnvDir hwndh_d x760 y%y_pos% w30 h25, D
            Gui, Add, Button, v%var_f% gonBrowseEnvFile hwndh_f x795 y%y_pos% w30 h25, F
            
            if (i > 0) { 
                Gui, Add, Button, v%var_del% gonDeleteEnv hwndh_del x835 y%y_pos% w30 h25, X
                setDarkControl(h_del)
            }
            setDarkControl(h_d), setDarkControl(h_f)
            y_pos += 30
        }
        Gui, Add, Button, hwndh_adde gonAddEnv x40 y%y_pos% w100 h25, + Add Env
        setDarkControl(h_adde)
        y_pos += 45
        
        ; 3. EXECS
        Gui, Font, Bold c5599FF
        Gui, Add, Text, x40 y%y_pos%, 3. Configuration Executables
        Gui, Font, Norm c%font_color%
        y_pos += 25
        For i, x in data.execs {
            var_d := "btn_exec_d_" tab_idx "_" i
            var_f := "btn_exec_f_" tab_idx "_" i
            var_edit := "edit_exec_" tab_idx "_" i
            var_del := "btn_del_exec_" tab_idx "_" i
        
            Gui, Add, Edit, v%var_edit% x40 y%y_pos% w750 h25, %x%
            Gui, Add, Button, v%var_d% gonBrowseExecDir hwndh_d x800 y%y_pos% w30 h25, D
            Gui, Add, Button, v%var_f% gonBrowseExecFile hwndh_f x835 y%y_pos% w30 h25, F
            
            if (i > 0) {
                Gui, Add, Button, v%var_del% gonDeleteExec hwndh_del x875 y%y_pos% w30 h25, X
                setDarkControl(h_del)
            }
            setDarkControl(h_d), setDarkControl(h_f)
            y_pos += 30
        }
        Gui, Add, Button, hwndh_addx gonAddExec x40 y%y_pos% w100 h25, + Add Exec
        setDarkControl(h_addx)
        y_pos += 45
        
        ; 4. LINKS
        Gui, Font, Bold c5599FF
        Gui, Add, Text, x40 y%y_pos%, 4. Links (Symbolic/Hard)
        
        Gui, Font, Norm s9 c888888
        label_y := y_pos + 20
        Gui, Add, Text, x40 y%label_y%, Source Path
        Gui, Add, Text, x400 y%label_y%, Target Path
        Gui, Font, s10 c%font_color%
        
        y_pos += 40
        For i, l in data.links {
            var_d_src := "btn_link_d_src_" tab_idx "_" i
            var_f_src := "btn_link_f_src_" tab_idx "_" i
            var_edit_src := "edit_link_src_" tab_idx "_" i
            var_edit_tgt := "edit_link_tgt_" tab_idx "_" i
            var_del := "btn_del_link_" tab_idx "_" i
        
            Gui, Add, Edit, v%var_edit_src% x40 y%y_pos% w340 h25, % l.src
            Gui, Add, Edit, v%var_edit_tgt% x400 y%y_pos% w340 h25, % l.tgt
            
            Gui, Add, Button, v%var_d_src% gonBrowseLinkSrcDir hwndh_d_src x760 y%y_pos% w30 h25, D
            Gui, Add, Button, v%var_f_src% gonBrowseLinkSrcFile hwndh_f_src x795 y%y_pos% w30 h25, F
            
            if (i > 0) {
                Gui, Add, Button, v%var_del% gonDeleteLink hwndh_del x835 y%y_pos% w30 h25, X
                setDarkControl(h_del)
            }
            setDarkControl(h_d_src), setDarkControl(h_f_src)
            y_pos += 30
        }
        Gui, Add, Button, hwndh_addl gonAddLink x40 y%y_pos% w100 h25, + Add Link
        setDarkControl(h_addl)
    }
}
Gui, Tab 
Gui, Font, s12 Bold cFFFFFF
Gui, Add, Button, x20 y775 w250 h55 gonManualSave hwndh_save, SAVE STATE
Gui, Add, Button, x280 y775 w900 h55 gonApplyConfigs hwndh_apply, APPLY
setDarkControl(h_save), setDarkControl(h_apply)
Gui, Show, w1200 h850, System-Config v0.51

SetTimer, pathTimer, 500
return

; ==========================================
;         RIGHT-CLICK & TAB MENU LOGIC
; ==========================================
WM_RBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global h_tab, g_tab_menu
    if (hwnd == h_tab) {
        Menu, %g_tab_menu%, Show
    }
}

onTabChanged:
    Gui, Submit, NoHide
    g_current_tab := main_tab
    saveState()
return

toggleMode:
    Gui, Submit, NoHide
    g_current_mode := (g_current_mode == "Config") ? "Restore" : "Config"
    GuiControl,, mode_btn, MODE: %g_current_mode%
    IniWrite, %g_current_mode%, %g_ini_file%, Settings, Mode
return

onAddProgram:
    FileSelectFile, exe_path, 3,, Browse for Main Executable (Sets Tab Name), Executables (*.exe)
    if (exe_path == "")
        return
        
    captureCurrentTabRows()
        
    SplitPath, exe_path, out_file_name, out_dir, out_ext, out_name_no_ext
    SplitPath, out_dir, out_folder_name
    tab_name := out_folder_name
    if (tab_name == "")
        tab_name := out_name_no_ext 
        
    Loop {
        is_dup := false
        For k, v in g_tab_names {
            if (v == tab_name) {
                is_dup := true
                tab_name := tab_name "_2"
                break
            }
        }
        if (!is_dup)
            break
    }
    
    g_tab_names.Push(tab_name)
    g_tab_data[tab_name] := {"paths": [exe_path], "envs": [], "execs": [], "links": []}
    g_current_tab := g_tab_names.Length() 
    
    saveState()
    Reload
return

onRenameTab:
    if (g_current_tab == 1) {
        MsgBox, 48, Denied, The WINDOWS tab cannot be renamed.
        return
    }
    old_name := g_tab_names[g_current_tab]
    InputBox, new_name, Rename Tab, Enter new name for tab "%old_name%":,, 300, 150
    if (ErrorLevel || new_name == "" || new_name == old_name)
        return
        
    g_tab_names[g_current_tab] := new_name
    g_tab_data[new_name] := g_tab_data[old_name]
    g_tab_data.Delete(old_name)
    
    captureCurrentTabRows()
    saveState()
    Reload
return

onDeleteTab:
    if (g_current_tab == 1) {
        MsgBox, 48, Denied, The WINDOWS tab cannot be deleted.
        return
    }
    target_name := g_tab_names[g_current_tab]
    MsgBox, 52, Confirm Delete, Are you sure you want to completely delete "%target_name%"?
    IfMsgBox, No
        return
        
    g_tab_data.Delete(target_name)
    g_tab_names.RemoveAt(g_current_tab)
    g_current_tab := 1 
    
    saveState()
    Reload
return


; ==========================================
;         ROW ADD/DELETE/BROWSE EVENTS
; ==========================================
onAddPath:
    captureCurrentTabRows()
    if (!IsObject(g_tab_data[g_tab_names[g_current_tab]].paths))
        g_tab_data[g_tab_names[g_current_tab]].paths := []
    g_tab_data[g_tab_names[g_current_tab]].paths.Push("")
    saveState()
    Reload
return

onAddEnv:
    captureCurrentTabRows()
    if (!IsObject(g_tab_data[g_tab_names[g_current_tab]].envs))
        g_tab_data[g_tab_names[g_current_tab]].envs := []
    g_tab_data[g_tab_names[g_current_tab]].envs.Push({"name":"", "val":""})
    saveState()
    Reload
return

onAddExec:
    captureCurrentTabRows()
    if (!IsObject(g_tab_data[g_tab_names[g_current_tab]].execs))
        g_tab_data[g_tab_names[g_current_tab]].execs := []
    g_tab_data[g_tab_names[g_current_tab]].execs.Push("")
    saveState()
    Reload
return

onAddLink:
    captureCurrentTabRows()
    if (!IsObject(g_tab_data[g_tab_names[g_current_tab]].links))
        g_tab_data[g_tab_names[g_current_tab]].links := []
    g_tab_data[g_tab_names[g_current_tab]].links.Push({"src":"", "tgt":""})
    saveState()
    Reload
return

onDeletePath:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    captureCurrentTabRows()
    g_tab_data[g_tab_names[tab_idx]].paths.RemoveAt(row_idx)
    saveState()
    Reload
return

onDeleteEnv:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    captureCurrentTabRows()
    g_tab_data[g_tab_names[tab_idx]].envs.RemoveAt(row_idx)
    saveState()
    Reload
return

onDeleteExec:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    captureCurrentTabRows()
    g_tab_data[g_tab_names[tab_idx]].execs.RemoveAt(row_idx)
    saveState()
    Reload
return

onDeleteLink:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    captureCurrentTabRows()
    g_tab_data[g_tab_names[tab_idx]].links.RemoveAt(row_idx)
    saveState()
    Reload
return

; --- BROWSE DIRECTORIES ---
onBrowsePathDir:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_path_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFolder, selected, *%current_val%, 3, Select Folder
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseExecDir:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_exec_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFolder, selected, *%current_val%, 3, Select Folder
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseEnvDir:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_env_val_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFolder, selected, *%current_val%, 3, Select Folder
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseLinkSrcDir:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[5], row_idx := parts[6]
    var_edit := "edit_link_src_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFolder, selected, *%current_val%, 3, Select Source Folder
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

; --- BROWSE FILES ---
onBrowsePathFile:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_path_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFile, selected, 3, %current_val%, Select File
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseExecFile:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_exec_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFile, selected, 3, %current_val%, Select File, Executables (*.exe)
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseEnvFile:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[4], row_idx := parts[5]
    var_edit := "edit_env_val_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFile, selected, 3, %current_val%, Select File
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return

onBrowseLinkSrcFile:
    parts := StrSplit(A_GuiControl, "_")
    tab_idx := parts[5], row_idx := parts[6]
    var_edit := "edit_link_src_" tab_idx "_" row_idx
    GuiControlGet, current_val,, %var_edit%
    FileSelectFile, selected, 3, %current_val%, Select Source File
    if (selected != "")
        GuiControl,, %var_edit%, %selected%
return


; ==========================================
;         LIVE PATH VERIFICATION
; ==========================================
pathTimer:
    checkPaths()
return

checkPaths() {
    global g_current_tab, g_tab_names
    if (g_current_tab == 1)
        return
        
    ; Scan paths block
    Loop, 50 {
        edit_var := "edit_path_" g_current_tab "_" A_Index
        GuiControlGet, path_val,, %edit_var%
        if (ErrorLevel) 
            break
        if (path_val != "") {
            if FileExist(path_val)
                GuiControl, +c55FF55, %edit_var%
            else
                GuiControl, +cFF4444, %edit_var%
        } else {
            GuiControl, +cD6D6D6, %edit_var%
        }
    }
    
    ; Scan execs block
    Loop, 50 {
        edit_var := "edit_exec_" g_current_tab "_" A_Index
        GuiControlGet, path_val,, %edit_var%
        if (ErrorLevel) 
            break
        if (path_val != "") {
            if FileExist(path_val)
                GuiControl, +c55FF55, %edit_var%
            else
                GuiControl, +cFF4444, %edit_var%
        } else {
            GuiControl, +cD6D6D6, %edit_var%
        }
    }
    
    ; Scan env val block
    Loop, 50 {
        edit_var := "edit_env_val_" g_current_tab "_" A_Index
        GuiControlGet, path_val,, %edit_var%
        if (ErrorLevel) 
            break
        if (path_val != "" && (InStr(path_val, ":\") || InStr(path_val, "\\"))) {
            if FileExist(path_val)
                GuiControl, +c55FF55, %edit_var%
            else
                GuiControl, +cFF4444, %edit_var%
        } else {
            GuiControl, +cD6D6D6, %edit_var%
        }
    }
    
    ; Scan links block
    Loop, 50 {
        edit_src := "edit_link_src_" g_current_tab "_" A_Index
        edit_tgt := "edit_link_tgt_" g_current_tab "_" A_Index
        GuiControlGet, src_val,, %edit_src%
        if (ErrorLevel) 
            break
            
        if (src_val != "") {
            if FileExist(src_val)
                GuiControl, +c55FF55, %edit_src%
            else
                GuiControl, +cFF4444, %edit_src%
        } else {
            GuiControl, +cD6D6D6, %edit_src%
        }
        
        GuiControlGet, tgt_val,, %edit_tgt%
        if (tgt_val != "") {
            if FileExist(tgt_val)
                GuiControl, +c55FF55, %edit_tgt%
            else
                GuiControl, +cFF4444, %edit_tgt%
        } else {
            GuiControl, +cD6D6D6, %edit_tgt%
        }
    }
}


; ==========================================
;         STATE MANAGEMENT CORE
; ==========================================
onManualSave:
    captureCurrentTabRows()
    saveState()
    MsgBox, 64, Saved, All dynamic configurations have been written to System-Config.ini.
return

onApplyConfigs:
    captureCurrentTabRows()
    saveState()
    MsgBox, 64, Apply, Executing %g_current_mode% operations based on loaded configurations. (Placeholder)
return

GuiClose:
    captureCurrentTabRows()
    saveState()
ExitApp

captureCurrentTabRows() {
    global
    Gui, Submit, NoHide
    
    For tab_idx, tab_name in g_tab_names {
        if (tab_idx == 1)
            continue
            
        data := g_tab_data[tab_name]
        
        For i, p in data.paths {
            var_edit := "edit_path_" tab_idx "_" i
            data.paths[i] := %var_edit%
        }
        For i, e in data.envs {
            var_name := "edit_env_name_" tab_idx "_" i
            var_val := "edit_env_val_" tab_idx "_" i
            data.envs[i].name := %var_name%
            data.envs[i].val := %var_val%
        }
        For i, x in data.execs {
            var_edit := "edit_exec_" tab_idx "_" i
            data.execs[i] := %var_edit%
        }
        For i, l in data.links {
            var_src := "edit_link_src_" tab_idx "_" i
            var_tgt := "edit_link_tgt_" tab_idx "_" i
            data.links[i].src := %var_src%
            data.links[i].tgt := %var_tgt%
        }
    }
}

saveState() {
    global
    FileDelete, %g_ini_file% 
    
    tab_str := ""
    For k, v in g_tab_names
        tab_str .= (A_Index=1 ? "" : "|") . v
        
    IniWrite, %tab_str%, %g_ini_file%, Settings, Tabs
    IniWrite, %g_current_tab%, %g_ini_file%, Settings, ActiveTab
    IniWrite, %g_current_mode%, %g_ini_file%, Settings, Mode
    
    For k, v in g_win_vars {
        val := %v%
        IniWrite, %val%, %g_ini_file%, Windows, %v%
    }
    
    For k, tab_name in g_tab_names {
        if (k == 1)
            continue
        
        data := g_tab_data[tab_name]
        
        For i, p in data.paths
            IniWrite, %p%, %g_ini_file%, %tab_name%_Paths, %i%
            
        For i, e in data.envs {
            IniWrite, % e.name, %g_ini_file%, %tab_name%_Envs, %i%_Name
            IniWrite, % e.val,  %g_ini_file%, %tab_name%_Envs, %i%_Val
        }
        
        For i, x in data.execs
            IniWrite, %x%, %g_ini_file%, %tab_name%_Execs, %i%
            
        For i, l in data.links {
            IniWrite, % l.src, %g_ini_file%, %tab_name%_Links, %i%_Src
            IniWrite, % l.tgt, %g_ini_file%, %tab_name%_Links, %i%_Tgt
        }
    }
}

loadState() {
    global
    if !FileExist(g_ini_file) {
        g_tab_names := ["WINDOWS"]
        g_tab_data := {}
        g_current_tab := 1
        g_current_mode := "Config"
        For k, v in g_win_vars
            %v% := 0
        return
    }
    
    IniRead, tabs, %g_ini_file%, Settings, Tabs, WINDOWS
    g_tab_names := StrSplit(tabs, "|")
    IniRead, g_current_tab, %g_ini_file%, Settings, ActiveTab, 1
    IniRead, g_current_mode, %g_ini_file%, Settings, Mode, Config
    
    For k, v in g_win_vars {
        IniRead, val, %g_ini_file%, Windows, %v%, 0
        %v% := val
    }
    
    For k, tab_name in g_tab_names {
        if (k == 1)
            continue
            
        g_tab_data[tab_name] := {"paths":[], "envs":[], "execs":[], "links":[]}
        
        Loop {
            IniRead, val, %g_ini_file%, %tab_name%_Paths, %A_Index%, ||END||
            if (val == "||END||")
                break
            g_tab_data[tab_name].paths.Push(val)
        }
        if (g_tab_data[tab_name].paths.Length() == 0)
            g_tab_data[tab_name].paths.Push("")
            
        Loop {
            IniRead, n, %g_ini_file%, %tab_name%_Envs, %A_Index%_Name, ||END||
            if (n == "||END||")
                break
            IniRead, v, %g_ini_file%, %tab_name%_Envs, %A_Index%_Val, %A_Space%
            g_tab_data[tab_name].envs.Push({"name": n, "val": v})
        }
        
        Loop {
            IniRead, x, %g_ini_file%, %tab_name%_Execs, %A_Index%, ||END||
            if (x == "||END||")
                break
            g_tab_data[tab_name].execs.Push(x)
        }
        
        Loop {
            ; Try reading the new format first (Src/Tgt)
            IniRead, src, %g_ini_file%, %tab_name%_Links, %A_Index%_Src, ||END||
            if (src == "||END||") {
                ; Backwards compatibility fallback if it's an old string link
                IniRead, l, %g_ini_file%, %tab_name%_Links, %A_Index%, ||END||
                if (l == "||END||")
                    break
                g_tab_data[tab_name].links.Push({"src": l, "tgt": ""})
            } else {
                IniRead, tgt, %g_ini_file%, %tab_name%_Links, %A_Index%_Tgt, %A_Space%
                g_tab_data[tab_name].links.Push({"src": src, "tgt": tgt})
            }
        }
    }
}

; ==========================================
;         THEMING UTILITIES
; ==========================================
setDarkControl(hwnd) {
    DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
}
