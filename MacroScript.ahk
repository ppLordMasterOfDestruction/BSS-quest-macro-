#NoEnv
SendMode Input
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
#Include Gdip.ahk

; =========================
; GLOBAL VARIABLES
; =========================
global detectedSpeed := 0
global speedReady := false
global running := false
global pToken := 0
global hasScrolled := false
global baseSpeed := 29

; =========================
; TOOLTIP DISPLAY FUNCTION
; =========================
ShowSpeedTooltip()
{
    global detectedSpeed, speedReady
    
    if (speedReady && detectedSpeed > 0)
        ToolTip, Speed: %detectedSpeed%
    else
        ToolTip, Speed: Not Detected
}

; =========================
; KEY PRESS FUNCTIONS - NO SPEED CORRECTION
; =========================

TapKey(key)
{
    SendInput, {%key% down}
    Sleep, 50
    SendInput, {%key% up}
}

SendKey(key)
{
    SendInput, {%key%}
}

; =========================
; MOVEMENT FUNCTIONS - WITH SPEED CORRECTION
; =========================

MoveKey(key, baseDuration)
{
    global detectedSpeed, speedReady, baseSpeed
    
    ShowSpeedTooltip()
    
    if (speedReady && detectedSpeed > 0)
        correctedDuration := (baseSpeed * baseDuration) / detectedSpeed
    else
        correctedDuration := baseDuration
    
    SendInput, {%key% down}
    Sleep, correctedDuration
    SendInput, {%key% up}
}

HoldKey(key, baseDuration)
{
    global detectedSpeed, speedReady, baseSpeed
    
    ShowSpeedTooltip()
    
    if (speedReady && detectedSpeed > 0)
        correctedDuration := (baseSpeed * baseDuration) / detectedSpeed
    else
        correctedDuration := baseDuration
    
    SendInput, {%key% down}
    Sleep, correctedDuration
    SendInput, {%key% up}
}

MoveKeys(keys, baseDuration)
{
    global detectedSpeed, speedReady, baseSpeed
    
    ShowSpeedTooltip()
    
    if (speedReady && detectedSpeed > 0)
        correctedDuration := (baseSpeed * baseDuration) / detectedSpeed
    else
        correctedDuration := baseDuration
    
    keysArray := StrSplit(keys, ",")
    
    for index, key in keysArray
    {
        key := Trim(key)
        SendInput, {%key% down}
    }
    
    Sleep, correctedDuration
    
    for index, key in keysArray
    {
        key := Trim(key)
        SendInput, {%key% up}
    }
}

; =========================
; UTILITY FUNCTIONS
; =========================

GetCorrectedDuration(baseDuration)
{
    global detectedSpeed, speedReady, baseSpeed
    
    if (speedReady && detectedSpeed > 0)
        return (baseSpeed * baseDuration) / detectedSpeed
    else
        return baseDuration
}

SetBaseSpeed(speed)
{
    global baseSpeed := speed
}

IsSpeedReady()
{
    global speedReady
    return speedReady
}

GetSpeed()
{
    global detectedSpeed, speedReady
    if (speedReady)
        return detectedSpeed
    else
        return 0
}

; =========================
; START DETECTION FUNCTION
; =========================
StartSpeedDetection()
{
    global running, pToken
    
    if (running)
        Return
    
    running := true
    
    pToken := Gdip_Startup()
    if (!pToken)
    {
        MsgBox, 16, Error, Failed to start GDI+
        Return
    }
    
    SetTimer, CheckSpeed, 100
}

; =========================
; STOP DETECTION FUNCTION
; =========================
StopSpeedDetection()
{
    global running, pToken
    
    running := false
    SetTimer, CheckSpeed, Off
    
    if (pToken)
    {
        Gdip_Shutdown(pToken)
        pToken := 0
    }
}

; =========================
; SPEED CHECK TIMER - 1440p COORDINATES
; =========================
CheckSpeed:
    if (!running)
    {
        SetTimer, CheckSpeed, Off
        Return
    }
    
    ; 1440p coordinates
    x1 := 81
    y1 := 181
    x2 := 223
    y2 := 208
    w := x2 - x1
    h := y2 - y1
    
    cx1 := 240
    cy1 := 109
    cx2 := 261
    cy2 := 131
    clickX := cx1 + ((cx2 - cx1) // 2)
    clickY := cy1 + ((cy2 - cy1) // 2)
    
    numX := 1
    numY := 410
    numW := 305
    numH := 26
    
    ; Tesseract path
    global tessPath := A_ScriptDir "\Tesseract-OCR\tesseract.exe"
    global hasScrolled
    
    if (!FileExist(tessPath))
    {
        MsgBox, 16, Error, Tesseract not found!`n`nExpected location: %tessPath%`n`nPlease ensure Tesseract-OCR folder is in the same directory as the macro.
        running := false
        SetTimer, CheckSpeed, Off
        Return
    }
    
    IfWinExist, Roblox
    {
        WinGet, activeID, ID, A
        WinGet, robloxID, ID, Roblox
        if (activeID != robloxID)
            WinActivate, ahk_id %robloxID%
    }
    else
    {
        Return
    }
    
    if (hasScrolled)
    {
        pBitmap := Gdip_BitmapFromScreen(numX "|" numY "|" numW "|" numH)
        imgNum := A_ScriptDir "\ocr_numbers.png"
        outNum := A_ScriptDir "\ocr_numbers_out"
        Gdip_SaveBitmapToFile(pBitmap, imgNum)
        Gdip_DisposeImage(pBitmap)
        
        RunWait, %ComSpec% /c ""%tessPath%" "%imgNum%" "%outNum%" -l eng --psm 7 -c tessedit_char_whitelist=0123456789.", , Hide
        FileRead, numbers, % outNum ".txt"
        numbers := Trim(numbers)
        numbers := RegExReplace(numbers, "[^\d.]", "")
        
        if (numbers != "")
        {
            global detectedSpeed := numbers + 0
            global speedReady := true
        }
        else
        {
            hasScrolled := false
        }
        
        Return
    }
    
    rect := x1 "|" y1 "|" w "|" h
    pBitmap := Gdip_BitmapFromScreen(rect)
    imgFile := A_ScriptDir "\ocr.png"
    outBase := A_ScriptDir "\ocr_out"
    Gdip_SaveBitmapToFile(pBitmap, imgFile)
    Gdip_DisposeImage(pBitmap)
    
    RunWait, %ComSpec% /c ""%tessPath%" "%imgFile%" "%outBase%" -l eng", , Hide
    FileRead, text, % outBase ".txt"
    text := Trim(text)
    
    if (text != "")
    {
        moveX := x1 + (w // 2)
        moveY := y1 + (h // 2)
        
        MouseGetPos, currentX, currentY
        
        deltaX := moveX - currentX
        deltaY := moveY - currentY
        steps := 20
        
        Loop, %steps%
        {
            progress := A_Index / steps
            newX := currentX + (deltaX * progress)
            newY := currentY + (deltaY * progress)
            MouseMove, %newX%, %newY%, 0
            Sleep, 10
        }
        
        Sleep, 100
        
        Loop, 20
        {
            Send, {WheelDown 3}
            Sleep, 50
        }
        
        Sleep, 100
        hasScrolled := true
    }
    else
    {
        MouseGetPos, currentX, currentY
        
        deltaX := clickX - currentX
        deltaY := clickY - currentY
        steps := 15
        
        Loop, %steps%
        {
            progress := A_Index / steps
            newX := currentX + (deltaX * progress)
            newY := currentY + (deltaY * progress)
            MouseMove, %newX%, %newY%, 0
            Sleep, 8
        }
        
        Sleep, 200
        
        Loop, 3
        {
            MouseMove, 0, 1, 0, R
            Sleep, 10
        }
        
        Sleep, 100
        
        Click
        Sleep, 300
    }
Return