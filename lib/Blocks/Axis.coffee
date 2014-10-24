#@ifndef JS_BLOCK_AXIS_COFFEE_
#@define JS_BLOCK_AXIS_COFFEE_

#@include "SPoke.coffee"

#@define AS_STICK_VAL 1
#@define AS_BUTTON_VAL 2
#@define AS_COMBINED_VAL 3

#@define GRADATION 255

@GAMEPAD_AXIS_AS_STICK = AS_STICK_VAL
@GAMEPAD_AXIS_AS_BUTTON = AS_BUTTON_VAL
@GAMEPAD_AXIS_AS_COMBINED = AS_COMBINED_VAL

class Axis extends EventTargetEmiter

  _implements.call(@, SPoke)

  MODE: 1

  # axes: null

  pressed: false # redefine in constructor

  value: 0 # redefine in constructor

  _oldValue: 0

  _oldPressed: false

  constructor: (gamepad, num, mode, positive, triggerValue = 127) ->
    # @axes = gamepad.axes
    @MODE = mode
    r = Math.round

    if mode is AS_STICK_VAL
      super('change')
      _value = ->
        r gamepad.axes[num] * GRADATION

    else if mode is AS_BUTTON_VAL
      super('change', 'press', 'down', 'up') # analog keyboard => down, then up, then press
      _value = ->
        if positive then r(gamepad.axes[num] * GRADATION) > triggerValue else r(gamepad.axes[num] * GRADATION) < -triggerValue
      @_oldPressed = _value()

    else if mode is AS_COMBINED_VAL
      super('change', 'press', 'down', 'up')
      _value = (press) ->
        if press
          return if positive then (gamepad.axes[num] * GRADATION) > triggerValue else (gamepad.axes[num] * GRADATION) < -triggerValue
        r gamepad.axes[num] * GRADATION
      @_oldPressed = _value(true)

    else
      ERR "Axis mode not correct."

    @_oldValue = _value()

    Object.defineProperty @, 'value',
      get: ->
        _value()
      set: (v) =>
        @_oldValue = v
        return

    Object.defineProperty @, 'pressed',
      get: ->
        mode isnt AS_STICK_VAL and _value(true)
      set: (v) =>
        if mode isnt AS_STICK_VAL
          @_oldPressed = v
        return

    @reSubscribe = (gamepadNew) ->
      gamepad = gamepadNew
      return

  poke: ->
    if @_subscribe._length > 0
      if @s('change')
        if @_oldValue isnt v = @value
          @emet 'change', new CustomEvent 'change',
            detail:
              oldValue: @_oldValue
              newValue: v
      if @MODE is AS_BUTTON_VAL or @MODE is AS_COMBINED_VAL
        if @s('press') or @s('down') or @s('up')
          if (p = @pressed) isnt @_oldPressed
            if p
              @emet('down') if @s("down")
            else
              @emet("up") if @s("up")
              @emet('press') if @s("press")
            @pressed = p
      @_oldValue = v if v?
    return

  # declare interface. Init in constructor
  reSubscribe: (gamepadNew) -> return # init by constructor

#@endif
# end JS_BLOCK_AXIS_COFFEE_