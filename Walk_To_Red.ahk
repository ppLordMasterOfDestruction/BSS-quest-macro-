#NoEnv
SendMode Input
SetKeyDelay, -1, -1
SetWorkingDir %A_ScriptDir%
#Include Gdip.ahk

;Global variables for E search
global pEBitmap := 0
global eImageLoaded := false
global pToken := 0

; load E
LoadEImage()
{
    global pEBitmap, eImageLoaded, pToken
    
    if (!pToken)
        pToken := Gdip_Startup()
    
    eImagePath := A_ScriptDir "\Images\E.png"
    
    if (!FileExist(eImagePath))
    {
        MsgBox, ERROR: E.png not found at %eImagePath%
        Return false
    }
    
    pEBitmap := Gdip_CreateBitmapFromFile(eImagePath)
    
    if (!pEBitmap)
    {
        MsgBox, ERROR: Failed to load E.png as bitmap
        Return false
    }
    
    eImageLoaded := true
    Return true
}

CleanupEImage()
{
    global pEBitmap, eImageLoaded
    
    if (pEBitmap)
    {
        Gdip_DisposeImage(pEBitmap)
        pEBitmap := 0
    }
    eImageLoaded := false
}

CheckForEImage(x1, y1, x2, y2)
{
    global pEBitmap, eImageLoaded
    
    if (!eImageLoaded || !pEBitmap)
        Return false
    
    w := x2 - x1
    h := y2 - y1
    pScreenBitmap := Gdip_BitmapFromScreen(x1 "|" y1 "|" w "|" h)
    
    if (!pScreenBitmap)
        Return false
    
    screenW := Gdip_GetImageWidth(pScreenBitmap)
    screenH := Gdip_GetImageHeight(pScreenBitmap)
    eW := Gdip_GetImageWidth(pEBitmap)
    eH := Gdip_GetImageHeight(pEBitmap)
    
    if (eW > screenW || eH > screenH)
    {
        Gdip_DisposeImage(pScreenBitmap)
        Return false
    }
    
    tolerance := 45
    sampleRate := 4
    foundMatch := false
    
    Loop, % (screenH - eH + 1)
    {
        offsetY := A_Index - 1
        if (Mod(offsetY, 3) != 0)
            continue
            
        Loop, % (screenW - eW + 1)
        {
            offsetX := A_Index - 1
            if (Mod(offsetX, 3) != 0)
                continue
            
            matchingPixels := 0
            totalSamples := 0
            
            Loop, % eH
            {
                y := A_Index - 1
                if (Mod(y, sampleRate) != 0)
                    continue
                
                Loop, % eW
                {
                    x := A_Index - 1
                    if (Mod(x, sampleRate) != 0)
                        continue
                    
                    totalSamples++
                    
                    screenColor := Gdip_GetPixel(pScreenBitmap, offsetX + x, offsetY + y)
                    eColor := Gdip_GetPixel(pEBitmap, x, y)
                    
                    sr := (screenColor >> 16) & 0xFF
                    sg := (screenColor >> 8) & 0xFF
                    sb := screenColor & 0xFF
                    
                    er := (eColor >> 16) & 0xFF
                    eg := (eColor >> 8) & 0xFF
                    eb := eColor & 0xFF
                    
                    diff := Abs(sr - er) + Abs(sg - eg) + Abs(sb - eb)
                    
                    if (diff <= tolerance)
                        matchingPixels++
                }
            }
            
            if (totalSamples > 0)
            {
                matchPercent := (matchingPixels / totalSamples) * 100
                if (matchPercent >= 68)
                {
                    foundMatch := true
                    break 2
                }
            }
        }
    }
    
    Gdip_DisposeImage(pScreenBitmap)
    Return foundMatch
}

;walks to red cannon from hive
WalkToRed()
{
    global hiveConfirmed, running, speedReady, detectedSpeed, macroRunning, settingsFile, eImageLoaded, pEBitmap
    
    if (!eImageLoaded || !pEBitmap)
    {
        ToolTip, Reloading E.png bitmap...
        Sleep, 300
        if (!LoadEImage())
        {
            MsgBox, ERROR: Could not load E.png. Aborting.
            Return
        }
        ToolTip
    }
    
    if (!hiveConfirmed)
    {
        MsgBox, ERROR: Hive not confirmed before walking
        Return
    }
    
    ToolTip, At hive! Starting speed detection...
    Sleep, 500
    
    IniRead, baseSpeed, %settingsFile%, Settings, BaseSpeed, 29
    IniRead, hiveSlot, %settingsFile%, Settings, HiveSlot, 1
    
    ToolTip, Waiting for speed detection...
    speedTimeout := A_TickCount + 30000
    
    while (!speedReady && A_TickCount < speedTimeout && macroRunning)
    {
        Sleep, 100
    }
    
    if (!speedReady)
    {
        MsgBox, ERROR: Speed detection timeout. Using base speed.
        currentSpeed := baseSpeed
    }
    else
    {
        currentSpeed := detectedSpeed
        ToolTip, Speed detected: %currentSpeed%
        Sleep, 500
    }
    
    IfWinExist, Roblox
    {
        WinActivate, Roblox
        WinWaitActive, Roblox, , 2
        Sleep, 200
    }
    else
    {
        MsgBox, Roblox window not found
        ToolTip
        Return
    }
    
    baseWTime := 1000
    wTime := GetCorrectedTime(baseWTime, currentSpeed, baseSpeed)
    ToolTip, Walking W for alignment: %wTime%ms
    
    SendInput, {w down}
    Sleep, wTime
    SendInput, {w up}
    Sleep, 100
    
    
    slotDifference := 6 - hiveSlot
    slotAdjustment := slotDifference * 1000
    baseDTime := 6400 - slotAdjustment
    
    if (speedReady)
        currentSpeed := detectedSpeed
    
    effectiveSpeed := currentSpeed
    if (currentSpeed > 70)
    {
        effectiveSpeed := currentSpeed * 2.5
        ToolTip, HASTE DETECTED! Speed %currentSpeed% -> Effective %effectiveSpeed%
        Sleep, 200
    }
    
    speedRatio := baseSpeed / effectiveSpeed
    totalDTime := speedRatio * baseDTime
    
    ToolTip, Walking D to red cannon: %totalDTime%ms at speed %currentSpeed%
    
    SendInput, {d down}
    
    startTime := A_TickCount
    lastSpeedCheck := A_TickCount
    speedCheckInterval := 200
    
    while ((A_TickCount - startTime) < totalDTime && macroRunning)
    {
        if ((A_TickCount - lastSpeedCheck) >= speedCheckInterval)
        {
            if (speedReady)
            {
                newSpeed := detectedSpeed
                newEffectiveSpeed := newSpeed
                if (newSpeed > 70)
                    newEffectiveSpeed := newSpeed * 2.5
                
                if (Abs(newEffectiveSpeed - effectiveSpeed) > 2)
                {
                    elapsedTime := A_TickCount - startTime
                    remainingBaseTime := totalDTime - elapsedTime
                    
                    newSpeedRatio := baseSpeed / newEffectiveSpeed
                    oldSpeedRatio := baseSpeed / effectiveSpeed
                    speedChange := newSpeedRatio / oldSpeedRatio
                    
                    newRemainingTime := remainingBaseTime * speedChange
                    totalDTime := elapsedTime + newRemainingTime
                    
                    currentSpeed := newSpeed
                    effectiveSpeed := newEffectiveSpeed
                    
                    ToolTip, Speed changed to %currentSpeed%! Adjusting walk time...
                }
            }
            
            lastSpeedCheck := A_TickCount
        }
        
        Sleep, 50
    }
    
    SendInput, {d up}

    SendInput, {space down}
    Sleep, 1
    SendInput, {space up}

    SendInput, {w down}
    SendInput, {d down}
    Sleep, 50
    SendInput, {d up}
    SendInput, {w up}
    
    
    baseFinalDTime := 775
    
    if (speedReady)
        currentSpeed := detectedSpeed
    else
        currentSpeed := baseSpeed
    
    effectiveSpeed := currentSpeed
    if (currentSpeed > 70)
    {
        effectiveSpeed := currentSpeed * 2.5
        ToolTip, HASTE! Final D: Speed %currentSpeed% -> Effective %effectiveSpeed%
        Sleep, 200
    }
    
    speedRatio := baseSpeed / effectiveSpeed
    totalFinalDTime := Round(speedRatio * baseFinalDTime)
    
    ToolTip, Final D hold: %totalFinalDTime%ms at speed %currentSpeed%
    
    SendInput, {d down}
    
    startTime := A_TickCount
    lastSpeedCheck := A_TickCount
    speedCheckInterval := 50
    
    while ((A_TickCount - startTime) < totalFinalDTime && macroRunning)
    {
        if ((A_TickCount - lastSpeedCheck) >= speedCheckInterval)
        {
            if (speedReady)
            {
                newSpeed := detectedSpeed
                newEffectiveSpeed := newSpeed
                if (newSpeed > 70)
                    newEffectiveSpeed := newSpeed * 2.5
                
                if (newEffectiveSpeed != effectiveSpeed)
                {
                    elapsedTime := A_TickCount - startTime
                    progressRatio := elapsedTime / totalFinalDTime
                    baseTimeRemaining := baseFinalDTime * (1 - progressRatio)
                    
                    newSpeedRatio := baseSpeed / newEffectiveSpeed
                    newRemainingTime := Round(newSpeedRatio * baseTimeRemaining)
                    
                    totalFinalDTime := elapsedTime + newRemainingTime
                    currentSpeed := newSpeed
                    effectiveSpeed := newEffectiveSpeed
                    
                    ToolTip, Speed changed to %currentSpeed%! Final D adjusted: %totalFinalDTime%ms
                }
            }
            
            lastSpeedCheck := A_TickCount
        }
        
        Sleep, 10
    }
    
    SendInput, {d up}
    Sleep, 500
    
    ; E prompt search (1440p cuh)
    ex1 := 1099
    ey1 := 58
    ex2 := 1171
    ey2 := 121
    
    searchStart := A_TickCount
    searchTimeout := 3000
    imageFound := false
    checkAttempts := 0
    
    ToolTip, Looking for E prompt at cannon...
    
    while ((A_TickCount - searchStart) < searchTimeout && macroRunning && !imageFound)
    {
        checkAttempts++
        
        if (CheckForEImage(ex1, ey1, ex2, ey2))
        {
            imageFound := true
            ToolTip, E prompt found! (Attempt %checkAttempts%)
            Sleep, 200
            break
        }
        Sleep, 200
    }
    
    ToolTip
    
    if (imageFound)
    {
        ToolTip, Successfully positioned at red cannon!
        Sleep, 100
        ToolTip
        global cannonConfirmed := true
    }
    else
    {
        ToolTip, E prompt not found after 3 seconds. Restarting from hive...
        Sleep, 700
        ToolTip
        
        StopSpeedDetection()
        Sleep, 200
        
        if (macroRunning)
        {
            ResetToHive()
            
            if (!hiveConfirmed)
            {
                ToolTip, Hive reset failed. Stopping.
                Sleep, 1000
                ToolTip
                Return
            }
            
            if (macroRunning && hiveConfirmed)
            {
                Sleep, 250
                StartSpeedDetection()
            }
            
            if (macroRunning)
            {
                Sleep, 500
                WalkToRed()
            }
        }
        
        Return
    }
}