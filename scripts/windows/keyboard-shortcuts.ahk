#NoEnv

SendMode Input
SetWorkingDir %A_ScriptDir%

^!Left::Send   {Media_Prev}
^!Down::Send   {Media_Play_Pause}
^!Right::Send  {Media_Next}
