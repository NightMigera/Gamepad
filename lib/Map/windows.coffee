windows:

  "045e028e": "XInputStyleGamepad" # Xbox 360
  "045e028f": "XInputStyleGamepad" # Xbox 360 wireless
  "046dc21d": "XInputStyleGamepad" # Logitech f310
  "046dc21e": "XInputStyleGamepad" # Logitech f510
  "046dc21f": "XInputStyleGamepad" # Logitech f710

  "23781008": "OnLiveWireless" # OnLive bluetooth
  "2378100a": "OnLiveWireless" # OnLive wire

  "046dc216": "DirectInputStyle" # Logitech f310 (DirectInput)
  "046dc218": "DirectInputStyle" # Logitech f510 (DirectInput)
  "046dc219": "DirectInputStyle" # Logitech f710 (DirectInput)

  "054c05c4": "Dualshock4" # PS Dualshock 4

  "18d12c40": "ADT1" # ADT-1 strannage

  "XInputStyleGamepad": # crazy gamepads
    lrtb:
      LT:
        axis: 4
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 127
      RT:
        axis: 4
        positive: false
        mode: AS_COMBINED_VAL
        triggerValue: 127
    menu:
      back: button: 6
      start: button: 7
      home: null
    axes:
      LSB: button: 8
      RSB: button: 9
      LSX:
        axis: 1
        mode: AS_STICK_VAL
      LSY:
        axis: 0
        mode: AS_STICK_VAL
      RSX:
        axis: 3
        mode: AS_STICK_VAL
      RSY:
        axis: 2
        mode: AS_STICK_VAL
    dpad:
      up:
        axis: 5
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 5
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 6
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 6
        positive: true
        mode: AS_BUTTON_VAL

  "DirectInputStyle":
    face:
      PR: button: 1
      SC: button: 2
      TR: button: 0
    menu: home: null
    dpad:
      up:
        axis: 5
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 5
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 4
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 4
        positive: true
        mode: AS_BUTTON_VAL
    axes:
      LSX:
        axis: 3
        mode: AS_STICK_VAL
      LSY:
        axis: 2
        mode: AS_STICK_VAL
      RSX:
        axis: 1
        mode: AS_STICK_VAL
      RSY:
        axis: 0
        mode: AS_STICK_VAL

  "Dualshock4":
    face:
      PR: button: 1
      SC: button: 2
      TR: button: 0
      QT: button: 3
    lrtb:
      LT:
        axis: 3
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
      RT:
        axis: 4
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
    menu:
      home: button: 12
      touch: button: 13
    axes:
      RSY:
        axis: 5
        mode: AS_STICK_VAL
    dpad:
      up:
        axis: 7
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 7
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 6
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 6
        positive: true
        mode: AS_BUTTON_VAL

  "OnLiveWireless":
    face:
      TR: button: 3
      QT: button: 4
    lrtb:
      LB: button: 6
      RB: button: 7
      LT:
        axis: 2
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
      RT:
        axis: 5
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
    menu:
      back: button: 10
      start: button: 11
      home: button: 12
    dpad: # теоретически
      up:
        axis: 7
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 7
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 6
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 6
        positive: true
        mode: AS_BUTTON_VAL
    axes:
      LSB: button: 13
      RSB: button: 14
      RSX:
        axis: 3
        mode: AS_STICK_VAL
      RSY:
        axis: 4
        mode: AS_STICK_VAL

  "ADT1":
    face:
      TR: button: 3
      QT: button: 4
    lrtb:
      lrtb:
        LB: button: 6
        RB: button: 7
      LT:
        axis: 4
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
      RT:
        axis: 3
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
    menu:
      back: null
      start: null
      home: button: 6 # o__O back and start not exists but meta exist
    axes:
      LSB: button: 13
      RSB: button: 14
      RSY:
        axis: 5
        mode: AS_STICK_VAL
    dpad: # as dualshock 4
      up:
        axis: 7
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 7
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 6
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 6
        positive: true
        mode: AS_BUTTON_VAL
