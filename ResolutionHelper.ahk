#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; =========================
; RESOLUTION DETECTION - 1440p ONLY
; =========================
global is1440p := false

DetectResolution()
{
    global is1440p
    
    SysGet, screenWidth, 78   ; Primary monitor width
    SysGet, screenHeight, 79  ; Primary monitor height
    
    ; Check Windows scaling
    RegRead, scalingValue, HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics, AppliedDPI
    if (ErrorLevel)
        scalingValue := 96  ; Default to 100% if can't read
    
    scalingPercent := Round((scalingValue / 96) * 100)
    
    ; Check for 1440p (2560x1440)
    if (screenWidth = 2560 && screenHeight = 1440)
    {
        if (scalingPercent != 100)
        {
            MsgBox, 16, ERROR: Windows Scaling Not 100`%, Your display scaling is set to %scalingPercent%`%.`n`nThis macro requires 100`% scaling to work properly.`n`nPlease change your Windows display settings:`n1. Right-click Desktop → Display Settings`n2. Set "Scale" to 100`%`n3. Restart the macro`n`nCurrent Resolution: %screenWidth%x%screenHeight%
            ExitApp
        }
        is1440p := true
        Return "1440p"
    }
    else
    {
        ; Not 1440p
        MsgBox, 16, ERROR: Unsupported Resolution, This macro currently only supports 2560x1440 (1440p) resolution at 100`% scaling.`n`nYour current settings:`n- Resolution: %screenWidth%x%screenHeight%`n- Scaling: %scalingPercent%`%`n`nPlease change your Windows display settings to:`n- 2560x1440 resolution`n- 100`% scaling`n`nThen restart the macro.`n`n(1080p support coming in future update)
        ExitApp
    }
}

; Initialize resolution detection on script start
detectedRes := DetectResolution()
ToolTip, Resolution confirmed: %detectedRes% at 100`% scaling
Sleep, 1
ToolTip