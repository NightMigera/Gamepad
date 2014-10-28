linux:

  "045e028e": "XInputStyleGamepad" # Xbox 360
  "045e028f": "XInputStyleGamepad" # Xbox 360 wireless
  "046dc21d": "XInputStyleGamepad" # Logitech f310
  "046dc21e": "XInputStyleGamepad" # Logitech f510
  "046dc21f": "XInputStyleGamepad" # Logitech f710
  "23781008": "XInputStyleGamepad" # OnLive bluetooth
  "2378100a": "XInputStyleGamepad" # OnLive wire

  "046dc216": "DirectInputStyle" # Logitech f310 (DirectInput)
  "046dc218": "DirectInputStyle" # Logitech f510 (DirectInput)
  "046dc219": "DirectInputStyle" # Logitech f710 (DirectInput)

  "09250005": "LakeviewResearch" # SmartJoy PLUS Adapter
  "09258866": "LakeviewResearch" # WiseGroup MP-8866

  "054c0268": "PlaystationSixAxis" # PS 6 axis

  "054c05c4": "Dualshock4" # PS Dualshock 4

  "0e8f0003": "XGEAR" # XFXforce XGEAR PS2

  "00790006": "MapperDragonRiseGeneric" # DragonRise Generic

  "18d12c40": "ADT1" # ADT-1 strannage

  "XInputStyleGamepad":
    lrtb:
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
      back: button: 6
      start: null
      home: null
    axes:
      LSB: button: 9
      RSB: button: 10
      RSX:
        axis: 3
        mode: AS_STICK_VAL
      RSY:
        axis: 4
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

  "DirectInputStyle":
    face:
      PR: button: 1
      SC: button: 2
      TR: button: 0
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

  "LakeviewResearch":
    face:
      PR: button: 2
      TR: button: 3
      QT: button: 0
    lrtb:
      LB: button: 6
      RB: button: 7
      LT:
        button: 4
        asAxis: true
      RT:
        button: 5
        asAxis: true
    menu:
      back: button: 9
      start: button: 8
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

  "PlaystationSixAxis":
    face:
      PR: button: 14 # wow !
      SC: button: 13
      TR: button: 15
      QT: button: 12
    lrtb:
      LB: button: 10
      RB: button: 11
      LT:
        axis: 12
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
      RT:
        axis: 13
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
    menu:
      back: button: 0
      start: button: 3
      home: button: 16
    dpad:
      up:
        axis: 8
        positive: true
        mode: AS_BUTTON_VAL
        triggerValue: 0
      down:
        axis: 10
        positive: true
        mode: AS_BUTTON_VAL
        triggerValue: 0
      left: button: 7
      right:
        axis: 9
        positive: true
        mode: AS_BUTTON_VAL
        triggerValue: 0

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

  "XGEAR":
    face:
      PR: button: 2
      SC: button: 1
      TR: button: 3
      QT: button: 0
    lrtb: # as LeakviewResearch
      LB: button: 6
      RB: button: 7
      LT:
        button: 4
        asAxis: true
      RT:
        button: 5
        asAxis: true
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
      RSX:
        axis: 3
        mode: AS_STICK_VAL
      RSY:
        axis: 2
        mode: AS_STICK_VAL

  "DragonRiseGeneric":
    dpad:
      up:
        axis: 6
        positive: false
        mode: AS_BUTTON_VAL
      down:
        axis: 6
        positive: true
        mode: AS_BUTTON_VAL
      left:
        axis: 5
        positive: false
        mode: AS_BUTTON_VAL
      right:
        axis: 5
        positive: true
        mode: AS_BUTTON_VAL
    axes:
      RSX:
        axis: 3
        mode: AS_STICK_VAL
      RSY:
        axis: 4
        mode: AS_STICK_VAL

  "ADT1":
    lrtb:
      LT:
        axis: 5
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
      RT:
        axis: 4
        positive: true
        mode: AS_COMBINED_VAL
        triggerValue: 0
    menu:
      back: null
      start: null
      home: button: 6 # o__O back and start not exists but meta exist
    axes:
      LSB: button: 7
      RSB: button: 8
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
