#NoEnv
#SingleInstance force

#InstallKeybdHook
#InstallMouseHook

SendMode Event
SetKeyDelay 100

;; Game Configuration

jaWindow := "OpenJK (MP)"

; Make sure you don't map any keys in-game to Alt or [.

bind_toggle := "Alt"

bind_attack := "LButton"
bind_block := "RButton"
bind_walk := "Shift" ; Make sure "Always Run" is set to "Yes" inside the game.

;; Main Logic

isDuelMode := false

~*Ctrl::Suspend

; Hotkey, *%bind_toggle%, label_toggle

; Hotkey %bind_attack%, label_attack
; Hotkey %bind_block%, label_block
; Hotkey %bind_walk%, label_moveBack

; Hotkey %bind_attack% Up, label_attack_release
; Hotkey, %bind_block% Up, label_block_release
; Hotkey %bind_walk% Up, label_walk_release

Attack() {
  global bind_attack
  Send, {%bind_attack% DownTemp}
  Send, {%bind_attack% Up}
}

Guard() {
  global bind_block
  Send, {%bind_block% Down}
}

DropGuard() {
  global bind_block
  Send, {%bind_block% Up}
}

Walk() {
  global bind_walk
  Send, {%bind_walk% Down}
}

CancelWalk() {
  global bind_walk
  Send, {%bind_walk% Up}
}

~*Alt::
  ;if (!WinActive(jaWindow))
  ;  return
  isDuelMode := !isDuelMode
  if (!isDuelMode) {
    DropGuard()
    CancelWalk()
  } else {
    Guard()
    Walk()
  }
  return

; Swing-block with one key.
; TODO: Swing-block combo while held.
~*[::
  if (!isDuelMode)
    return
  DropGuard()
  Sleep, 50
  Attack()
  Sleep, 50
  Guard()
  return

; Always block in duel mode.
; TODO: Get this dynamically from bind_block
~*RButton Up::
  if (!isDuelMode)
    return
  Sleep, 100
  Guard()
  return
  
; Always walk in duel mode.
; TODO: Get this dynamically from bind_walk
~*Shift Up::
  if (!isDuelMode)
    return
  Sleep, 100
  Walk()
  return
  
OnExit:
  DropGuard()
  CancelWalk()
  return
