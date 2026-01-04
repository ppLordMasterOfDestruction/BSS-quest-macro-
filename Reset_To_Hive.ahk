#NoEnv
SendMode Input
SetKeyDelay, -1, -1
SetWorkingDir %A_ScriptDir%
#Include CheckAndMakeHoney.ahk


SmoothMouseMove(targetX, targetY, speed := 50)
{
    MouseGetPos, startX, startY
    
    deltaX := targetX - startX
    deltaY := targetY - startY
    distance := Sqrt(deltaX**2 + deltaY**2)
    
    steps := Ceil(distance / speed)
    if (steps < 1)
        steps := 1
    
    Loop, %steps%
    {
        progress := A_Index / steps
        currentX := startX + (deltaX * progress)
        currentY := startY + (deltaY * progress)
        MouseMove, %currentX%, %currentY%, 0
        Sleep, 2
    }
    
    MouseMove, %targetX%, %targetY%, 0
}

; =========================
; RESET TO HIVE FUNCTION
; =========================
ResetToHive()
{
    global macroRunning, settingsFile, speedReady, detectedSpeed, pToken, sprinklerActive
    
    sprinklerActive := false
    
    ; Shift lock check - 1440p coordinates
    shiftLockImagePath := A_ScriptDir "\Images\ShiftLock.png"
    
    if (FileExist(shiftLockImagePath))
    {
        CheckShiftLock(10, 1388, 41, 1421, shiftLockImagePath, 5)
    }

    if (!macroRunning)
    {
        ToolTip, Macro stopped
        Sleep, 100
        ToolTip
        Return
    }

    global hiveConfirmed := false

    IfWinExist, Roblox
    {
        WinActivate, Roblox
        WinWaitActive, Roblox, , 2
        Sleep, 200
    }
    else
    {
        MsgBox, Roblox window not found
        Return
    }

    if (!macroRunning)
        Return

    ; Menu icon checks - 1440p coordinates
    SettingsIconPath := A_ScriptDir "\Images\SettingsIcon.png"
    
    menuIcons := []
    menuIcons.Push({x1: 243, y1: 135, x2: 256, y2: 143, name: "MenuIcon1"})
    menuIcons.Push({x1: 315, y1: 129, x2: 326, y2: 137, name: "MenuIcon2"})
    menuIcons.Push({x1: 177, y1: 116, x2: 202, y2: 136, name: "BadgeIcon"})
    menuIcons.Push({x1: 89, y1: 132, x2: 103, y2: 137, name: "QuestMenuIcon"})
    menuIcons.Push({x1: 29, y1: 121, x2: 37, y2: 130, name: "ItemMenuIcon"})
    menuIcons.Push({x1: 150, y1: 138, x2: 159, y2: 145, name: "BeeIcon"})

    CheckAndCloseMenus(menuIcons, SettingsIconPath)

    SendInput, {Escape}
    Sleep, 300

    SendInput, r
    Sleep, 300

    SendInput, {Enter}
    Sleep, 3000

    if (!macroRunning)
        Return

    Loop, 4
    {
        SendInput, `,
        Sleep, 10
    }

    Sleep, 10

    imageDir := A_ScriptDir "\Images"
    referenceImages := [imageDir "\Hive.png"]

    ; Hive search area - 1440p coordinates (specific Hive.png location)
    x1 := 1694
    y1 := 1357
    x2 := 1757
    y2 := 1379

    matchFound := false
    matchedImage := ""
    foundX := 0
    foundY := 0

    toleranceLevels := [150, 120, 100]

    for tolIndex, tolerance in toleranceLevels
    {
        if (matchFound)
            break

        ToolTip, Searching hive (specific location) - tolerance *%tolerance%

        for index, imagePath in referenceImages
        {
            if (!macroRunning)
                Return

            if (!FileExist(imagePath))
            {
                ToolTip, Warning: %imagePath% not found, skipping
                Sleep, 500
                continue
            }

            ImageSearch, foundX, foundY, %x1%, %y1%, %x2%, %y2%, *%tolerance% %imagePath%

            if (ErrorLevel = 0)
            {
                matchFound := true
                SplitPath, imagePath, matchedImage
                ToolTip, Match found with *%tolerance%: %matchedImage% at X:%foundX% Y:%foundY%
                Sleep, 50
                break 2
            }
        }

        Sleep, 45
    }

    ToolTip

    if (!macroRunning)
        Return

    if (matchFound)
    {
        ToolTip, Hive confirmed! Sprinkler reset. Continuing...
        Sleep, 1
        ToolTip

        Loop, 4
        {
            SendInput, `,
            Sleep, 10
        }

        Sleep, 800

        Loop, 5
        {
            if (!macroRunning)
                Return
            SendInput, o
            Sleep, 100
        }

        CheckAndMakeHoney()
        
        global hiveConfirmed := true
    }
    else
    {
        ToolTip, No Hive.png detected - checking for LessBeesHive...
        Sleep, 100
        
        ; Page down twice to navigate hive list
        SendInput, {PgDn}
        Sleep, 1
        SendInput, {PgDn}
        Sleep, 1
        
        ; Search for LessBeesHive.png
        lessBeesImagePath := imageDir "\LessBeesHive.png"
        lessBeesFound := false
        
        ; LessBeesHive search area coordinates
        lbx1 := 1129
        lby1 := 154
        lbx2 := 1190
        lby2 := 181
        
        if (FileExist(lessBeesImagePath))
        {
            for tolIndex, tolerance in toleranceLevels
            {
                if (lessBeesFound)
                    break
                    
                ToolTip, Searching LessBeesHive - tolerance *%tolerance%
                
                ImageSearch, lbFoundX, lbFoundY, %lbx1%, %lby1%, %lbx2%, %lby2%, *%tolerance% %lessBeesImagePath%
                
                if (ErrorLevel = 0)
                {
                    lessBeesFound := true
                    ToolTip, LessBeesHive found at X:%lbFoundX% Y:%lbFoundY%
                    Sleep, 50
                    break
                }
                
                Sleep, 45
            }
        }
        
        ToolTip
        
        if (!macroRunning)
            Return
        
        if (lessBeesFound)
        {
            ToolTip, LessBeesHive confirmed! Navigating back...
            Sleep, 100
            
            ; Page up twice to go back
            SendInput, {PgUp}
            Sleep, 1
            SendInput, {PgUp}
            Sleep, 1
            
            ; Press comma 4 times fast
            Loop, 4
            {
                SendInput, `,
                Sleep, 1
            }
            
            Sleep, 800
            
            Loop, 5
            {
                if (!macroRunning)
                    Return
                SendInput, o
                Sleep, 100
            }
            
            CheckAndMakeHoney()
            
            global hiveConfirmed := true
        }
        else
        {
            ToolTip, Neither Hive.png nor LessBeesHive.png detected - restarting reset...
            Sleep, 1000
            ToolTip
            
            ; Navigate back first
            SendInput, {PgUp}
            Sleep, 1
            SendInput, {PgUp}
            Sleep, 1
            
            if (macroRunning)
            {
                ResetToHive()
            }
        }
    }
}

CheckAndCloseMenus(menuIcons, iconPath)
{
    global macroRunning
    
    if (!FileExist(iconPath))
    {
        ToolTip, Settings icon image not found!
        Sleep, 500
        ToolTip
        Return false
    }
    
    tolerance := 1
    menuFound := false
    
    ToolTip, Checking for open menus...
    Sleep, 200
    
    for index, icon in menuIcons
    {
        if (!macroRunning)
        {
            ToolTip, Macro stopped during menu check
            Sleep, 200
            ToolTip
            Return false
        }
            
        iconX1 := icon.x1
        iconY1 := icon.y1
        iconX2 := icon.x2
        iconY2 := icon.y2
        iconName := icon.name
        
        ImageSearch, foundX, foundY, %iconX1%, %iconY1%, %iconX2%, %iconY2%, *%tolerance% %iconPath%

        if (ErrorLevel = 0)
        {
            ToolTip, Menu detected at %iconName% (X:%foundX% Y:%foundY%) - closing it
            Sleep, 500
            
            SmoothMouseMove(foundX, foundY, 25)
            Sleep, 100
            
            adjustedY := foundY + 3
            MouseMove, %foundX%, %adjustedY%, 0
            Sleep, 50
            
            ToolTip, Clicking %iconName%...
            Click, %foundX%, %adjustedY%
            Sleep, 200
            
            ToolTip, Menu closed
            Sleep, 200
            ToolTip
            
            menuFound := true
            break
        }
    }
    
    if (!menuFound)
    {
        ToolTip, No menus detected
        Sleep, 300
        ToolTip
    }
    
    Return menuFound
}

CaptureHiveSearchArea()
{
    x1 := 1694
    y1 := 1357
    x2 := 1757
    y2 := 1379
    
    w := x2 - x1
    h := y2 - y1
    
    timestamp := A_Now
    filename := A_ScriptDir "\DEBUG_HiveSearchArea_" timestamp ".png"
    
    ScreenCapture(x1, y1, w, h, filename)
    
    MsgBox, Debug capture saved to:`n%filename%`n`nSearch area: X=%x1% to %x2%, Y=%y1% to %y2%
}

F9::CaptureHiveSearchArea()

ScreenCapture(x, y, w, h, filename)
{
    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
    if (pBitmap)
    {
        Gdip_SaveBitmapToFile(pBitmap, filename)
        Gdip_DisposeImage(pBitmap)
    }
}