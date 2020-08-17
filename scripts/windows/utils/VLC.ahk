#NoEnv
#SingleInstance force
#Persistent

/*
WinSet_Click_Through - Makes a window unclickable. Written by Wicked & SKAN.
I - ID of the window to set as unclickable.
T - The transparency to set the window. Leaving it blank will set it to 254. It can also be set On or Off. Any numbers lower then 0 or greater then 254 will simply be changed to 254.
If the window ID doesn't exist, it returns 0.
*/

WinSet_Click_Through(I, T="254") {
   IfWinExist, % "ahk_id " I
   {
      If (T == "Off")
      {
         WinSet, AlwaysOnTop, Off, % "ahk_id " I
         WinSet, Transparent, Off, % "ahk_id " I
         WinSet, ExStyle, -0x20, % "ahk_id " I
      }
      Else
      {
         WinSet, AlwaysOnTop, On, % "ahk_id " I
         If(T < 0 || T > 254 || T == "On")
            T := 254
         WinSet, Transparent, % T, % "ahk_id " I
         WinSet, ExStyle, +0x20, % "ahk_id " I
      }
   }
   Else
      Return 0
}

;app code starts here
;get window ID for a VLC instance
SetTitleMatchMode, 2
ID := WinExist("VLC media player")

;set it to 75% transparent and unclickable
WinSet_Click_Through(ID, 0.75 * 255)

;wait until the user quits, then show window again
OnExit, AppEnd
Return

AppEnd:
;set it back to clickable
WinSet_Click_Through(ID, "Off")
ExitApp
