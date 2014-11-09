#@ifndef JS_BLOCKS_BUTTON_COFFEE_
#@define JS_BLOCKS_BUTTON_COFFEE_

#@include "SPoke.coffee"

#@include "Axis.coffee"

class Button extends EventTargetEmiter

  MODE: AS_BUTTON_VAL

  _implements.call(@, SPoke)

  pressed: false

  name: ""

  _oldPressed: false

  constructor: (gamepad, num, @name, asAxis = false) ->
    # check values
    if typeof gamepad isnt "object"
      ERR "gamepad is not Gamepad"
      return
    unless isFinite num
      ERR "num of button not number"
      return
    num = num|0
    if num < 0
      ERR "Index button less than 0"
      return
    unless gamepad.buttons[num]?
      ERR "Button: button #{num} not exists"
      return

    super('change', 'press', 'down', 'up')
    # create get value functions
    if _webkit = isFinite gamepad.buttons[0]
      _value = ->
        gamepad.buttons[num] > 0.5
    else
      # standart supported
      _value = ->
        gamepad.buttons[num].pressed

    # redeclare pressed property
    Object.defineProperty @, 'pressed',
      get: ->
        _value()
      set: (v) =>
        @_oldPressed = v
        return

    # asAxis convert value to -255..255 range
    if asAxis
      @MODE = AS_COMBINED_VAL
      @_oldValue = -255
      if _webkit
        Object.defineProperty @, 'value',
          get: ->
            (2 * gamepad.buttons[num] - 1) * GRADATION
          set: (v) ->
            @_oldValue = v
            return
      else
        Object.defineProperty @, 'value',
          get: ->
            (2 * gamepad.buttons[num].value - 1) * GRADATION
          set: (v) ->
            @_oldValue = v
            return

    @reSubscribe = (gamepadNew) -> gamepad = gamepadNew

  poke: ->
    if @_subscribe._length > 0
      if @s('change')
        if @MODE & AS_STICK_VAL # if as axis
          if @_oldValue isnt v = @value
            @emet 'change', createEvent 'change',
              target: @
              oldValue: @_oldValue
              newValue: v
        else
          if @_oldPressed isnt p = @pressed
            @emet "change", createEvent 'change',
              target: @
              oldValue: !p
              newValue: p
      if @_oldPressed isnt p = @pressed
        if p # new value is press
          @emet("down") if @s("down")
        else # button up
          @emet("up") if @s("up")
          @emet("press") if @s("press")
        @pressed = p

  # declare interface. Init in constructor
  reSubscribe: (gamepadNew) -> return


#@endif
# end JS_BLOCKS_BUTTON_COFFEE_