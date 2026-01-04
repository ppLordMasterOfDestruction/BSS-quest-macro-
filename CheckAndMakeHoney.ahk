#NoEnv
SendMode Input
SetKeyDelay, -1, -1
SetWorkingDir %A_ScriptDir%

CheckAndMakeHoney()
{
    global macroRunning, settingsFile
    
    if (!macroRunning)
    {
        ToolTip, CheckAndMakeHoney cancelled - macro stopped
        Sleep, 500
        ToolTip
        Return
    }
    
    ToolTip, Checking if honey needs to be made...
    Sleep, 500
    
    ; E.png search area - 1440p coordinates
    ex1 := 1099
    ey1 := 58
    ex2 := 1171
    ey2 := 121
    
    searchTimeout := 2000
    searchStart := A_TickCount
    eFound := false
    
    while ((A_TickCount - searchStart) < searchTimeout && macroRunning && !eFound)
    {
        if (CheckForEImage(ex1, ey1, ex2, ey2))
        {
            eFound := true
            break
        }
        Sleep, 100
    }
    
    if (!eFound)
    {
        ToolTip, No honey to convert - continuing to next cycle
        Sleep, 800
        ToolTip
        
        ContinueGatherLoop()
        Return
    }
    
    ToolTip, E prompt found! Converting honey...
    Sleep, 500
    
    SetTimer, CheckSpeed, Off
    SendInput, e
    Sleep, 100
    SetTimer, CheckSpeed, 100
    
    ToolTip, Converting honey... waiting for completion
    Sleep, 3000
    
    conversionTimeout := 30000
    conversionStart := A_TickCount
    eStillPresent := true
    
    ToolTip, Monitoring conversion progress...
    
    while ((A_TickCount - conversionStart) < conversionTimeout && macroRunning && eStillPresent)
    {
        if (!CheckForEImage(ex1, ey1, ex2, ey2))
        {
            eStillPresent := false
            break
        }
        Sleep, 500
    }
    
    if (!eStillPresent)
    {
        ToolTip, Honey conversion complete!
        Sleep, 1000
        ToolTip
    }
    else
    {
        ToolTip, Conversion timeout - assuming complete
        Sleep, 1000
        ToolTip
    }
    
    ContinueGatherLoop()
}

;continue after 
ContinueGatherLoop()
{
    global macroRunning, chosenField, hiveConfirmed, running, speedReady
    
    if (!macroRunning)
    {
        ToolTip, Loop continuation cancelled - macro stopped
        Sleep, 500
        ToolTip
        Return
    }
    
    ToolTip, Continuing gathering loop...
    Sleep, 500
    ToolTip
    
    hiveConfirmed := true
    
    if (!running)
    {
        ToolTip, Restarting speed detection...
        Sleep, 300
        StartSpeedDetection()
        Sleep, 500
    }
    
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
}