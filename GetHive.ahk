#NoEnv
SendMode Input
SetKeyDelay, -1, -1
SetWorkingDir %A_ScriptDir%

; =========================
; GET HIVE - NAVIGATES TO SPECIFIC HIVE SLOT
; Called at the end of all Wf_ scripts
; =========================
GetHive()
{
    global macroRunning, settingsFile
    
    if (!macroRunning)
    {
        ToolTip, GetHive cancelled - macro stopped
        Sleep, 500
        ToolTip
        Return
    }
    
    ; Read hive slot from settings
    IniRead, hiveSlot, %settingsFile%, Settings, HiveSlot, 1
    
    ToolTip, Navigating to Hive Slot %hiveSlot%...
    Sleep, 300
    ToolTip
    
    ; Call the appropriate hive slot function
    if (hiveSlot = 1)
        GetHive1()
    else if (hiveSlot = 2)
        GetHive2()
    else if (hiveSlot = 3)
        GetHive3()
    else if (hiveSlot = 4)
        GetHive4()
    else if (hiveSlot = 5)
        GetHive5()
    else if (hiveSlot = 6)
        GetHive6()
    else
    {
        MsgBox, ERROR: Invalid hive slot %hiveSlot%. Using Hive 1 as default.
        GetHive1()
    }
}

; =========================
; HIVE SLOT 1
; =========================
GetHive1()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
    
    MoveKey("a", 300)
    
    CheckAndMakeHoney()
}

; =========================
; HIVE SLOT 2
; =========================
GetHive2()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
    
    MoveKey("a", 1300)  ; 

    
    CheckAndMakeHoney()
}

; =========================
; HIVE SLOT 3
; =========================
GetHive3()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
    
    MoveKey("a", 2200)  
    
    CheckAndMakeHoney()
}

; =========================
; HIVE SLOT 4
; =========================
GetHive4()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
    
    MoveKey("a", 3400)  
    
    
    CheckAndMakeHoney()
}

; =========================
; HIVE SLOT 5
; =========================
GetHive5()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
    
    MoveKey("a", 4300)  
  
    
    CheckAndMakeHoney()
}

; =========================
; HIVE SLOT 6
; =========================
GetHive6()
{
    global macroRunning
    
    if (!macroRunning)
        Return
    
   
    MoveKey("a", 5400)  
    
    
    CheckAndMakeHoney()
}