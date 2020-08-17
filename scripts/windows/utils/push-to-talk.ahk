#NoEnv
#SingleInstance force

SendMode Input

*LAlt::
  Unmute()
  KeyWait, LAlt
  Sleep, 200
  Mute()
  Return

SetIsMicrophoneMuted(isMuted)
{
  ; Change the last argument with the correct mixer id which can be found
  ; out using soundcard-analysis.ahk
  SoundSet isMuted, Master, Mute, 7
}

Mute()
{
  SetIsMicrophoneMuted(1)
}

Unmute()
{
  SetIsMicrophoneMuted(0)
}

; Mute at start and unmute on exit
Mute()
OnExit("Unmute")
