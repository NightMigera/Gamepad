#@ifndef JS_GAMEPAD_COFFEE_
#@define JS_GAMEPAD_COFFEE_

#@include "EventTargetEmiter.coffee"

#@include "SPoke.coffee"

#@include "Blocks/Block.coffee"

#@include "Map/GamepadMap.coffee"

#@define INPUT_NAME_SHORT_VAL 0b01
#@define INPUT_NAME_FULL_VAL 0b10

class Gamepad2 extends EventTargetEmiter

  connected: false

  gamepad: null

  map: null

  axes: null

  dpad: null

  face: null

  lrtb: null

  menu: null

  constructor: (gamepad, map = null) ->
    EventTargetEmiter.call @, 'change', 'on', 'off'
    @gamepad = gamepad

    if map?
      @map = map
    else if gamepad.axes.length is 4 # mapped by browser to default
      @map = new GamepadMap "0000", "0000"
    else
      @getMap gamepad.id

    @axes = null
    @dpad = null
    @menu = null
    @face = null
    @lrtb = null

  getMap: (id) ->
    moz = /([0-9a-f]{4})\-([0-9a-f]{4})\-[\s\w]+/
    webkit = /Vendor: ([0-9a-f]{4}) Product: ([0-9a-f]{4})/
    other = /\b([0-9a-f]{4})\b.+\b([0-9a-f]{4})\b/
    if moz.test id
      match = id.match moz
    else if webkit.test id
      match = id.match webkit
    else if other.test id
      match = id.match other
    else
      match = [null, "0000", "0000"]
    @map = new GamepadMap match[1], match[2]

  connect: ->
    aMap = @map.activeMap
    for own blockName, block of aMap
      if @hasOwnProperty(blockName)
        if @[blockName] is null
          @[blockName] = new Block block, @gamepad
        else
          @[blockName].reSubscribe @gamepad
    @connected = true
    @emet "on"
    return

  disconnect: ->
    @connected = false
    @emet "off"
    return

  poke: ->
    return unless @connected
    for own block of @map.activeMap
      @[block].poke()
    return

  _synonyms = [
    ["PR",    "primary"]
    ["SC",    "secondary"]
    ["TR",    "tertiary"]
    ["QT",    "quaternary"]
    #--
    ["lrtb",  "shouldersTriggers"]
    ["dpad",  "dPad"]
    #--
    ["LB", "leftShoulder"]
    ["RB", "rightShoulder"]
    ["LT", "leftTrigger"]
    ["RT", "rightTrigger"]
    ["LSB", "leftStickButton"]
    ["RSB", "rightStickButton"]
  ]
    
    
#@endif
# end JS_GAMEPAD_COFFEE_