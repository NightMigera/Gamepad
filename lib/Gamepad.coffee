#@ifndef JS_GAMEPAD_COFFEE_
#@define JS_GAMEPAD_COFFEE_

#@include "EventTargetEmiter.coffee"

#@include "SPoke.coffee"

#@include "Blocks/Block.coffee"

#@include "Map/GamepadMap.coffee"

#@define INPUT_NAME_SHORT_VAL 0b01

#@define INPUT_NAME_FULL_VAL 0b10

@GAMEPAD_NAME_FULL = INPUT_NAME_FULL_VAL

@GAMEPAD_NAME_SHORT = INPUT_NAME_SHORT_VAL

class Gamepad2 extends EventTargetEmiter

  connected: false

  gamepad: null

  map: null

  axes: null

  dpad: null

  face: null

  lrtb: null

  menu: null

  config: null

  defaultConfig =
    naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT # mask use long names of button and block and short names
    maps: null # advanced map or array map (map instance of GamepadMap)
    allowCustomBlockName: false # allow custom block name, (ex: 'center' for axes and menu)
    trusted: false # trusted config, set Gamepads when create gamepad.

  constructor: (gamepad, config = {}) ->

    config = overlay defaultConfig, config
    @config = parseConfig config

    super 'change', 'on', 'off'

    @gamepad = gamepad

    if config.maps?
      vp = parseId gamepad.id
      vp[0] = GamepadMap.platformDetect()
      for map in config.maps
        if map.platform is vp[0] and map.vendor.toLowerCase() is vp[1] and map.product.toLowerCase() is vp[2]
          @map = map
          break
      unless @map?
        INFO "Gamepad2: manual map not find allowed. Use default mapper"

    unless @map?
      if gamepad.axes.length is 4 # mapped by browser to default
        @map = new GamepadMap "0000", "0000"
      else
        @getMap gamepad.id

  getMap: (id) ->
    parsed = parseId id
    @map = new GamepadMap parsed[1], parsed[2]

  reMap: (map) ->
    unless map instanceof GamepadMap
      ERR "Gamepad2: reMap: map must be instance of GamepadMap"
      return
    @map = map
    for own blockName, block of map.activeMap
      if (blockName of @) or @config.allowCustomBlockName is true
        if @[blockName] is null
          associate @, @config.naming, blockName, block
        else
          @[blockName].reSubscribe @gamepad

  connect: ->
    @reMap @map
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

  parseConfig = (config) ->
    unless config
      ERR "Gamepad2: config: config is empty. Merging fail."
      return
    unless typeof config is "object"
      ERR "Gamepad2: config: config not object."
      return

    # don't check if trusted. Trusted set Gamepads.
    if config.trusted is true
      return config

    warn = (warntext) ->
      WARN "Gamepads: config: #{warntext}. Set default"

    booleanTest = (name, warntext) ->
      if config[name] isnt not not config[name]
        warn warntext
        config[name] = defaultConfig[name]
        false
      true

    maskTest = (name, maxMask, notMask, notAllowedMask) ->
      v = config[name]
      unless ((+v)|0) is v
        warn notMask
      else if v > maxMask
        warn notAllowedMask
      else
        return true
      config[name] = defaultConfig[name]
      false

    maskTest 'naming', GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT, "naming must be bitmask", "not allowed values for naming bitmask"

    booleanTest "allowCustomBlockName", "allowCustomBlockName must be boolean"

    if config.map?
      if config.map instanceof GamepadMap
        config.map = [config.map]
      unless config.map instanceof Array
        warn "map must be array of gamepadMap instance or gamepadMap instance"
        config.map = null
      wrongMap = []
      for map, index in config.map
        unless map instanceof GamepadMap
          warn "map #{index} not instance of GamepadMap. Use constructor for create map"
          wrongMap.push index
      for index in wrongMap by -1
        config.map.splice index, 1
      if config.map.length is 0
        config.map = null

    return config

  parseId = (id) ->
    moz = /([0-9a-f]{4})\-([0-9a-f]{4})\-[\s\w]+/
    webkit = /Vendor: ([0-9a-f]{4}) Product: ([0-9a-f]{4})/
    other = /\b([0-9a-f]{4})\b.+\b([0-9a-f]{4})\b/
    if moz.test id
      id.match moz
    else if webkit.test id
      id.match webkit
    else if other.test id
      id.match other
    else
      [null, "0000", "0000"]

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

  associate = (pad, mode, blockName, mapBlock) ->
    find = (name) ->
      for syn in _synonyms
        if syn[0] is name or syn[1] is name
          return syn
      return [name, name]
    blockNames = find blockName
    for own name, val of mapBlock
      names = find name
      delete mapBlock[name]
      if mode & INPUT_NAME_SHORT_VAL
        mapBlock[names[0]] = val
      if mode & INPUT_NAME_FULL_VAL
        mapBlock[names[1]] = val
    if mode & INPUT_NAME_SHORT_VAL
      pad[blockNames[0]] = new Block mapBlock, pad.gamepad
      if mode & INPUT_NAME_FULL_VAL
        pad[blockNames[1]] = pad[blockNames[0]]
    else if mode & INPUT_NAME_FULL_VAL
      pad[blockNames[1]] = new Block mapBlock, pad.gamepad
    return



#@endif
# end JS_GAMEPAD_COFFEE_