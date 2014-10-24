linux:

  "045e028e": "XInputStyleGamepad"
  "045e028f": "XInputStyleGamepad"
  "046dc21d": "XInputStyleGamepad"
  "046dc21e": "XInputStyleGamepad"
  "046dc21f": "XInputStyleGamepad"
  "046dc216": "DirectInputStyle"
  "046dc218": "DirectInputStyle"
  "046dc219": "DirectInputStyle"

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
      start: button: 7
      home: button: 8
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
