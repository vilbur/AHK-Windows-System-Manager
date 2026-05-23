#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

; Declare all dynamic variables globally so they are accessible to the GUI
global ChkProg3DS, Edit3DS, Btn3DS, ChkStart3DS
global ChkProgTC, EditTC, BtnTC, ChkStartTC
global ChkProgPS, EditPS, BtnPS, ChkStartPS
global ChkProgZB, EditZB, BtnZB, ChkStartZB
global ChkProgNPP, EditNPP, BtnNPP, ChkStartNPP
global ChkProgGK, EditGK, BtnGK, ChkStartGK
global ChkCoreEnv, EditGDrive, ChkCoreAHK, EditAHK, ChkWinAdminAcc, ChkWinAdminPrompt
global ChkWinUAC, ChkWinGameDVR, ChkWinAds, ChkWinLockScreen, ChkWinNarrator
global ChkWinUSB, ChkWinTaskbar, ChkWinWidgets, ChkProgZBH, PresetCombo

global VarsList := "ChkCoreEnv,EditGDrive,ChkCoreAHK,EditAHK,ChkWinAdminAcc,ChkWinAdminPrompt,ChkWinUAC,ChkWinGameDVR,ChkWinAds,ChkWinLockScreen,ChkWinNarrator,ChkWinUSB,ChkWinTaskbar,ChkWinWidgets,ChkProg3DS,Edit3DS,ChkStart3DS,ChkProgTC,EditTC,ChkStartTC,ChkProgPS,EditPS,ChkStartPS,ChkProgZB,EditZB,ChkStartZB,ChkProgZBH,ChkProgNPP,EditNPP,ChkStartNPP,ChkProgGK,EditGK,ChkStartGK"
global dark_background := "1E1E1E"
global font_color := "D6D6D6"

OnMessage(0x0133, "OnCtlColor")
OnMessage(0x0138, "OnCtlColor")

Gui, +hwndhMainGui +LastFound
Gui, Color, %dark_background%, %dark_background%
Gui, Margin, 14, 14
Gui, Font, s10 c%font_color%, Segoe UI

DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hMainGui, "Int", 20, "Int*", true, "Int", 4)
DllCall("uxtheme\SetWindowTheme", "Ptr", hMainGui, "Str", "DarkMode_Explorer", "Ptr", 0)

Gui, Add, GroupBox, x20 y10 w400 h70 c%font_color%, Execution Mode
Gui, Add, Radio, vModeConfig x40 y40 Checked gModeSwitch BackgroundTrans, Config Mode
Gui, Add, Radio, vModeRestore x220 y40 gModeSwitch BackgroundTrans, Revert Mode

Gui, Add, GroupBox, x750 y10 w430 h70 c%font_color%, Presets
Gui, Add, Text, x770 y40 w60 c%font_color% BackgroundTrans, Preset:
Gui, Add, ComboBox, vPresetCombo x830 y36 w180 hwndhPresetCombo, Default
SetDarkControl(hPresetCombo)

Gui, Font, Bold cFFFFFF
Gui, Add, Button, x1030 y34 w60 h30 gSavePreset hwndhSavePreset, Save
Gui, Add, Button, x1100 y34 w60 h30 gLoadPreset hwndhLoadPreset, Load
Gui, Font, Norm c%font_color%

SetDarkButton(hSavePreset)
SetDarkButton(hLoadPreset)

Gui, Add, Tab3, vMainTab hwndhTab x20 y110 w1160 h650, CORE|WINDOWS|PROGRAMS
DllCall("uxtheme\SetWindowTheme", "Ptr", hTab, "Str", "DarkMode_Explorer", "Ptr", 0)
GuiControl, +cDDDDDD, MainTab

; CORE TAB
Gui, Tab, CORE
Gui, Add, CheckBox, vChkCoreEnv x40 y160 BackgroundTrans, Set %GoogleDrive% Environment Variable
Gui, Add, Edit, vEditGDrive x60 y190 w800 h25 hwndhEditGDrive, D:\GoogleDrive
Gui, Add, Button, vBtnGDrive gBrowseGDrive x880 y189 w100 h27 hwndhBtnGDrive, Browse
Gui, Add, CheckBox, vChkCoreAHK x40 y260 BackgroundTrans, Install AutoHotkey
Gui, Add, Edit, vEditAHK x60 y290 w800 h25 hwndhEditAHK, b:\Programs_install\Autohotkey\AutoHotkey_1.1.36.02_setup.exe
Gui, Add, Button, vBtnAHK gBrowseAHK x880 y289 w100 h27 hwndhBtnAHK, Browse

SetDarkEdit(hEditGDrive)
SetDarkEdit(hEditAHK)
SetDarkButton(hBtnGDrive)
SetDarkButton(hBtnAHK)

; WINDOWS TAB
Gui, Tab, WINDOWS
Gui, Add, CheckBox, vChkWinAdminAcc x40 y160 BackgroundTrans, Toggle Administrator Account
Gui, Add, CheckBox, vChkWinAdminPrompt x40 y200 BackgroundTrans, Toggle ConsentPromptBehaviorAdmin
Gui, Add, CheckBox, vChkWinUAC x40 y240 BackgroundTrans, Toggle UAC / Secure Desktop overrides
Gui, Add, CheckBox, vChkWinGameDVR x40 y280 BackgroundTrans, Disable GameDVR
Gui, Add, CheckBox, vChkWinAds x40 y320 BackgroundTrans, Disable Windows Advertising
Gui, Add, CheckBox, vChkWinLockScreen x40 y360 BackgroundTrans, Disable Lock Screen
Gui, Add, CheckBox, vChkWinNarrator x40 y400 BackgroundTrans, Disable Narrator
Gui, Add, CheckBox, vChkWinUSB x40 y440 BackgroundTrans, Disable USB Selective Suspend
Gui, Add, CheckBox, vChkWinTaskbar x40 y480 BackgroundTrans, Toggle Taskbar Icon Combine
Gui, Add, CheckBox, vChkWinWidgets x40 y520 BackgroundTrans, Disable Widgets

; PROGRAMS TAB
Gui, Tab, PROGRAMS
AddProgramRow("3D Studio Max", "Edit3DS", "Btn3DS", "ChkProg3DS", "ChkStart3DS", "C:\Program Files\Autodesk\3ds Max 2024\3dsmax.exe", 160)
AddProgramRow("Total Commander", "EditTC", "BtnTC", "ChkProgTC", "ChkStartTC", "C:\totalcmd\TOTALCMD64.EXE", 240)
AddProgramRow("Photoshop", "EditPS", "BtnPS", "ChkProgPS", "ChkStartPS", "C:\Program Files\Adobe\Adobe Photoshop 2024\Photoshop.exe", 320)
AddProgramRow("ZBrush", "EditZB", "BtnZB", "ChkProgZB", "ChkStartZB", "C:\Program Files\Pixologic\ZBrush 2023\ZBrush.exe", 400)
AddProgramRow("Notepad++", "EditNPP", "BtnNPP", "ChkProgNPP", "ChkStartNPP", "C:\Program Files\Notepad++\notepad++.exe", 505)
AddProgramRow("GitKraken", "EditGK", "BtnGK", "ChkProgGK", "ChkStartGK", "C:\Users\%A_UserName%\AppData\Local\gitkraken\app-9.0.0\gitkraken.exe", 585)
Gui, Add, CheckBox, vChkProgZBH x60 y465 BackgroundTrans, Create ZBrush Hardlinks

Gui, Tab
Gui, Font, s11 Bold cFFFFFF
Gui, Add, Button, x20 y775 w1160 h45 gExecuteCurrent hwndhApplyCurrent, APPLY CURRENT TAB
Gui, Add, Button, x20 y830 w1160 h55 gExecuteChanges hwndhApplyAll, APPLY SELECTED SETTINGS

SetDarkButton(hApplyCurrent)
SetDarkButton(hApplyAll)

GoSub, InitPresets
Gui, Show, w1200 h900, Windows 11 Wide Configurator
SetTimer, CheckPaths, 500
return

; ================= FUNCTIONS =================

AddProgramRow(label_text, edit_name, button_name, checkbox_name, startup_name, default_path, pos_y)
{
    global font_color
    ; No global declaration needed here anymore, as they are now defined at the top level
    
    Gui, Add, CheckBox, v%checkbox_name% x40 y%pos_y% BackgroundTrans, %label_text% (Run As Admin)
    next_y := pos_y + 30
    
    Gui, Add, Edit, v%edit_name% x60 y%next_y% w700 h25 hwndhEdit, %default_path%
    Gui, Add, Button, v%button_name% gBrowseProg x780 y%next_y% w100 h27 hwndhButton, Browse
    Gui, Add, CheckBox, v%startup_name% x920 y%next_y% BackgroundTrans, Run on Startup
    
    SetDarkEdit(hEdit)
    SetDarkButton(hButton)
}
SetDarkEdit(hwnd) {
    DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
}

SetDarkButton(hwnd) {
    DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
}

SetDarkControl(hwnd) {
    DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
}

OnCtlColor(w_param, l_param) {
    static dark_brush := DllCall("CreateSolidBrush", "UInt", 0x1E1E1E)
    DllCall("SetTextColor", "Ptr", w_param, "UInt", 0xD6D6D6)
    DllCall("SetBkColor", "Ptr", w_param, "UInt", 0x1E1E1E)
    return dark_brush
}

; ==========================================
;             INI PRESET LOGIC
; ==========================================
InitPresets:
    IniRead, pList, ConfigPresets.ini, PresetList
    outStr := ""
    if (pList != "ERROR" && pList != "") {
        Loop, Parse, pList, `n, `r
        {
            key := StrSplit(A_LoopField, "=")[1]
            if (key != "")
                outStr .= key . "|"
        }
    }
    if (outStr == "")
        outStr := "Default|"
        
    GuiControl,, PresetCombo, |%outStr%
    GuiControl, ChooseString, PresetCombo, Default
return

SavePreset:
    Gui, Submit, NoHide
    presetName := PresetCombo
    if (presetName == "")
        presetName := "Default"
        
    Loop, Parse, VarsList, `,
    {
        varName := A_LoopField
        val := %varName%
        IniWrite, %val%, ConfigPresets.ini, %presetName%, %varName%
    }
    IniWrite, 1, ConfigPresets.ini, PresetList, %presetName%
    GoSub, InitPresets
    GuiControl, ChooseString, PresetCombo, %presetName%
    MsgBox, 64, Saved, Preset "%presetName%" saved successfully!
return

LoadPreset:
    Gui, Submit, NoHide
    presetName := PresetCombo
    if (presetName == "")
        return
        
    Loop, Parse, VarsList, `,
    {
        varName := A_LoopField
        IniRead, val, ConfigPresets.ini, %presetName%, %varName%, %A_Space%
        if (val != "" && val != "ERROR")
            GuiControl,, %varName%, %val%
    }
    GoSub, ModeSwitch
    MsgBox, 64, Loaded, Preset "%presetName%" loaded!
return

; ==========================================
;           BROWSE & EXECUTION FUNCTIONS
; ==========================================
ModeSwitch:
    Gui, Submit, NoHide
    ; Add logic here to toggle visibility if needed
return

BrowseGDrive:
    FileSelectFolder, outFolder, *%EditGDrive%, 3, Select Google Drive Folder
    if (outFolder != "")
        GuiControl,, EditGDrive, %outFolder%
return

BrowseAHK:
    FileSelectFile, outFile, 3, %EditAHK%, Select AutoHotkey Installer, Executables (*.exe)
    if (outFile != "")
        GuiControl,, EditAHK, %outFile%
return

BrowseProg:
    ctrlMap := {"Btn3DS": "Edit3DS", "BtnTC": "EditTC", "BtnPS": "EditPS", "BtnZB": "EditZB", "BtnNPP": "EditNPP", "BtnGK": "EditGK"}
    editCtrl := ctrlMap[A_GuiControl]
    GuiControlGet, startPath,, %editCtrl%
    FileSelectFile, outFile, 3, %startPath%, Select Executable, Executables (*.exe)
    if (outFile != "")
        GuiControl,, %editCtrl%, %outFile%
return

ExecuteCurrent:
    MsgBox, 64, Info, Apply Current Tab logic placeholder.
return

ExecuteChanges:
    MsgBox, 64, Info, Apply Selected Settings logic placeholder.
return

CheckPaths:
return