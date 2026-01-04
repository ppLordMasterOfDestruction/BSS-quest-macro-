#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; =========================
; INCLUDE RESOLUTION HELPER FIRST
; =========================
#Include ResolutionHelper.ahk

; =========================
; INITIALIZE GDI+ FOR SHIFTLOCK CHECK
; =========================
global pToken := Gdip_Startup()

; =========================
; GLOBAL SETTINGS
; =========================
global baseSpeed := 29
global hiveSlot := 1
global chosenField := "PineTree"
global settingsFile := A_ScriptDir "\MacroSettings.ini"
global macroRunning := false
global cannonConfirmed := false
global sprinklerActive := false

; =========================
; LOAD SETTINGS ON STARTUP
; =========================
LoadSettings()

; =========================
; CREATE GUI
; =========================
Gui, Font, s10
Gui, Add, Text, x20 y20 w150, Base Move Speed:
Gui, Add, Edit, x180 y17 w100 vBaseSpeedInput, %baseSpeed%

Gui, Add, Text, x20 y60 w150, Hive Slot (1-6):
Gui, Add, Edit, x180 y57 w100 vHiveSlotInput, %hiveSlot%

Gui, Add, Text, x20 y100 w150, Gather Field:
Gui, Add, DropDownList, x180 y97 w100 vGatherFieldInput Choose1, PineTree

Gui, Add, Button, x20 y140 w120 h30 gSaveSettings, Save Settings
Gui, Add, Button, x150 y140 w120 h30 gStartMacroButton, Start Macro (F1)

Gui, Add, Text, x20 y185 w260 cGray, Current Settings will be used by all scripts

Gui, Add, Text, x20 y210 w260 cBlue, Resolution: 1440p at 100`% scaling

Gui, Show, w300 h250, BSS Quest Macro
Return

; =========================
; SAVE SETTINGS
; =========================
SaveSettings:
    Gui, Submit, NoHide
    
    if (BaseSpeedInput <= 0)
    {
        MsgBox, 16, Error, Base Move Speed must be greater than 0
        Return
    }
    
    if (HiveSlotInput < 1 || HiveSlotInput > 6)
    {
        MsgBox, 16, Error, Hive Slot must be between 1 and 6
        Return
    }
    
    baseSpeed := BaseSpeedInput
    hiveSlot := HiveSlotInput
    chosenField := GatherFieldInput
    
    IniWrite, %baseSpeed%, %settingsFile%, Settings, BaseSpeed
    IniWrite, %hiveSlot%, %settingsFile%, Settings, HiveSlot
    IniWrite, %chosenField%, %settingsFile%, Settings, ChosenField
    
    MsgBox, 64, Success, Settings saved!
Return

; =========================
; LOAD SETTINGS FUNCTION
; =========================
LoadSettings()
{
    global baseSpeed, hiveSlot, chosenField, settingsFile
    
    IniRead, loadedSpeed, %settingsFile%, Settings, BaseSpeed, 29
    IniRead, loadedSlot, %settingsFile%, Settings, HiveSlot, 1
    IniRead, loadedField, %settingsFile%, Settings, ChosenField, PineTree
    
    baseSpeed := loadedSpeed
    hiveSlot := loadedSlot
    chosenField := loadedField
}

; =========================
; GET FUNCTIONS FOR OTHER SCRIPTS
; =========================
GetBaseSpeed()
{
    global baseSpeed
    return baseSpeed
}

GetHiveSlot()
{
    global hiveSlot
    return hiveSlot
}

GetChosenField()
{
    global chosenField
    return chosenField
}

GetHiveWalkTime(currentSpeed)
{
    global baseSpeed, hiveSlot
    
    baseWalkTime := 6000 - ((6 - hiveSlot) * 1000)
    
    if (currentSpeed > 0)
        adjustedTime := (baseSpeed * baseWalkTime) / currentSpeed
    else
        adjustedTime := baseWalkTime
    
    return adjustedTime
}

; =========================
; SPEED CORRECTION HELPER FUNCTION
; =========================
GetCorrectedTime(baseTime, currentSpeed, baseSpeed)
{
    if (currentSpeed > 0)
        return (baseSpeed * baseTime) / currentSpeed
    else
        return baseTime
}

; =========================
; INCLUDE OTHER SCRIPTS
; =========================
#Include Gdip.ahk
#Include ShiftLockFind.ahk
#Include MacroScript.ahk
#Include Reset_to_Hive.ahk
#Include Walk_To_Red.ahk
#Include FieldPath\gt_PineTree.ahk
#Include FieldPatterns\PineGather.ahk
#Include WalkFromFieldPaths\Wf_Pine.ahk
#Include GetHive.ahk
; =========================
; HOTKEYS
; =========================
StartMacroButton:
F1::
    Gui, Submit, NoHide
    
    if (macroRunning)
    {
        ToolTip, Macro is already running!
        Sleep, 1000
        ToolTip
        Return
    }
    
    global macroRunning := true
    global cannonConfirmed := false
    global sprinklerActive := false
    
    IfWinExist, Roblox
    {
        WinGet, activeID, ID, A
        WinGet, robloxID, ID, Roblox
        
        if (activeID != robloxID)
        {
            WinActivate, ahk_id %robloxID%
            WinWaitActive, ahk_id %robloxID%, , 2
        }
    }
    
    if (macroRunning)
        ResetToHive()
    
    if (macroRunning && hiveConfirmed)
        StartSpeedDetection()
    
    if (macroRunning)
        WalkToRed()
    
    if (macroRunning && cannonConfirmed)
    {
        if (chosenField = "PineTree")
        {
            GoToPineTree()
            
            if (macroRunning)
                PineGather()
        }
    }
Return

F3::
    global macroRunning := false
    global cannonConfirmed := false
    global sprinklerActive := false
    StopSpeedDetection()
    
    if (pToken)
        Gdip_Shutdown(pToken)
    
    SendInput, {w up}{a up}{s up}{d up}
    
    ToolTip, Terminating all AHK scripts...
    Sleep, 500
    
    Loop, Files, %A_ScriptDir%\*.ahk
    {
        SplitPath, A_LoopFileFullPath, scriptName
        DetectHiddenWindows, On
        SetTitleMatchMode, 2
        
        WinClose, %scriptName% ahk_class AutoHotkey
    }
    
    Sleep, 500
    
    Run, taskkill /F /IM AutoHotkey.exe, , Hide
    
    ExitApp
Return

GuiClose:
    if (pToken)
        Gdip_Shutdown(pToken)
    ExitApp