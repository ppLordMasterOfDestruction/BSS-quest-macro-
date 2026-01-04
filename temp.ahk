#NoEnv
#SingleInstance Force
SendMode Input
CoordMode, Mouse, Screen

#Include Gdip.ahk

global clickCount := 0
global x1 := 0, y1 := 0, x2 := 0, y2 := 0

; Start GDI+
if !pToken := Gdip_Startup()
{
    MsgBox, Failed to start GDI+
    ExitApp
}

; Ctrl + Left Click to capture points
^LButton::
    MouseGetPos, mx, my
    clickCount++

    if (clickCount = 1)
    {
        x1 := mx
        y1 := my
        ToolTip, First point set:`nX: %x1%  Y: %y1%
        Sleep, 800
        ToolTip
    }
    else if (clickCount = 2)
    {
        x2 := mx
        y2 := my

        ; Normalize coordinates
        left   := (x1 < x2) ? x1 : x2
        right  := (x1 > x2) ? x1 : x2
        top    := (y1 < y2) ? y1 : y2
        bottom := (y1 > y2) ? y1 : y2

        width  := right - left
        height := bottom - top

        ; Clipboard text
        clipboardText =
        (
left := %left%
top := %top%
right := %right%
bottom := %bottom%
width := %width%
height := %height%
        )

        Clipboard := clipboardText
        ClipWait, 1

        ; =========================
        ; SCREENSHOT CAPTURE
        ; =========================
        pBitmap := Gdip_BitmapFromScreen(left "|" top "|" width "|" height)

        FormatTime, timestamp,, yyyy-MM-dd_HH-mm-ss
        filePath := A_ScriptDir "\Capture_" timestamp ".png"

        Gdip_SaveBitmapToFile(pBitmap, filePath)
        Gdip_DisposeImage(pBitmap)

        MsgBox, 64, Area Captured,
        (
Top-Left:     X=%left%  Y=%top%
Bottom-Right: X=%right% Y=%bottom%

Width:  %width%
Height: %height%

Screenshot saved:
%filePath%

Copied to clipboard ✔
        )

        clickCount := 0
    }
return

; ESC to exit cleanly
Esc::
    Gdip_Shutdown(pToken)
    ExitApp
