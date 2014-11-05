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

###*
 * Interface for gamepad. Button have events press, up and down, sticks have method change.
 * Buttons and sticks apportioned by logical blocks:
 * `dpad` -- left + buttons
 * `lrtb` -- left/right tob/button buttons (triggers and shoulders)
 * `menu` -- central buttons back/select  start/forward and meta/home
 * `axes` -- stcks and stick buttons
 * `face` -- right 4 action-buttons
 *
 * config:
 * Mode of `naming` declare name of blocks and buttons. Recommend use short naming.
 * `maps` is array of `GamepadMap` -- modifed, corrected or new mapping for gamepads. 
 * Map have vendor, product and platform id, and apply only on this. 
 * If custom map have custom block name, you need set `allowCustomBlockNaming` else throw
 * error.
 * To skip config check set `trusted` is true.
 *
 * Основной интерфейс для джойстика. У кнопок есть события нажатия, а у стиков -- изменения
 * Кнопки и блоки разнесены по логическим блокам:
 * `dpad` -- крестовина
 * `lrtb` -- верхние тригерр и бампер (R1 L1 R2 L2 в нотации PS)
 * `menu` -- кнопки меню в центре
 * `axes` -- стики и кнопки стиков
 * `face` -- кнопки справа
 *
 * конфигурация (по умолчанию транслируется из Gamepads)
 * Параметр `naming`определяет режим названия блоков и кнопок. Если маска содержит 
 * `GAMEPAD_NAME_FULL`, то названия некоторых блоков и кнопок альтернативные указанным.
 * `maps` если не `null` является массивом объектов `GamepadMap, в который указаны vendor,
 * prodict и platform, которые определяют применимость карты только при полном совпадении. 
 * Если блок имеет имя отлично от вышеописанных, то следует указать `allowCustomBlockName`
 * в противном случае будет брошена ошибка.
 * Чтобы не проверять правильность конфигурации, следует установить `trusted`
 *
 * @class Gamepad2
 * @extends EventTargetEmiter
 * @implements SPoke
###
class Gamepad2 extends EventTargetEmiter

	_implements.call(@, SPoke)

	###*
	 * Статус джойстика
	 * @public
	 * @type Boolean
	###
  connected: false

	###*
	 * Ссылка на базовый джойстик
	 * @public
	 * @type Gamepad
	###
  gamepad: null

	###*
	 * Текущая карта кнопоки осей
	 * @public
	 * @type GamepadMap
	###
  map: null

	###*
	 * Блок стиков
	 * @public
	 * @type Block
	###
  axes: null

	###*
	 * Блок крестовины
	 * @public
	 * @type Block
	###
  dpad: null

	###*
	 * Блок кнопок справа
	 * @public
	 * @type Block
	###
  face: null

	###*
	 * Блок верхних кнопок (тригер, бампер)
	 * @public
	 * @type Block
	###
  lrtb: null

	###*
	 * Блок кнопок взаимодействия с меню
	 * @public
	 * @type Block
	###
  menu: null

	###*
	 * Конфигурация текущая
	 * @public
	 * @type Object
	###
  config: null

	###*
	 * Конфигурация по-умолчанию
	 * @private
	 * @type Object
	###
  defaultConfig =
    naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT # mask use long names of button and block and short names
    maps: null # advanced map or array map (map instance of GamepadMap)
    allowCustomBlockName: false # allow custom block name, (ex: 'center' for axes and menu)
    trusted: false # trusted config, set Gamepads when create gamepad.

	###*
	 * Создаёт на основе `gamepad` с учётом `config` экземпляр класса.
	 * @constructor
	 * @param Gamepad gamepad
	 * @param Object config = {}
	###
  constructor: (gamepad, config = {}) ->

    config = overlay defaultConfig, config
    @config = parseConfig config

    super 'change', 'on', 'off'

    @gamepad = gamepad

    mapCandidat = null

    if gamepad.axes.length is 4 # mapped by browser to default
      @map = new GamepadMap "0000", "0000"
    else
      if config.maps?
        vp = parseId gamepad.id
        vp[0] = GamepadMap.platformDetect()
        for map in config.maps
          if map.platform is vp[0] and map.vendor.toLowerCase() is vp[1] and map.product.toLowerCase() is vp[2]
            mapCandidat = map
            break
        unless mapCandidat?
          INFO "Gamepad2: manual map not find allowed. Use default mapper"
      if mapCandidat?
        @map = mapCandidat
      else
        @getMap gamepad.id

	###*
	 * Устанавливает текущую карту кнопок по `id` из `gamepad.id`
	 * @public
	 * @method getMap
	 * @param String id
	 * @return GamepadMap
	###
  getMap: (id) ->
    parsed = parseId id
    @map = new GamepadMap parsed[1], parsed[2]

	###*
	 * Переопределяет текущую карту кнопок на новую из `map` принудительно.
	 * @public
	 * @method reMap
	 * @param GamepadMap map
	 * @return void
	###
  reMap: (map) ->
    unless map instanceof GamepadMap
      ERR "Gamepad2: reMap: map must be instance of GamepadMap"
      return
    @map = map
    for own blockName, block of map.activeMap
      if (blockName of @) or @config.allowCustomBlockName is true
        unless @[blockName]?
          associate @, @config.naming, blockName, block
        else
          @[blockName].reSubscribe @gamepad
      else
        delete map.activeMap[blockName]
    return

	###*
	 * Метод, вызываемый при подключении джойстика
	 * @public
	 * @method connect
	 * @return void
	###
  connect: ->
    @reMap @map
    @connected = true
    @emet "on"
    return

	###*
	 * Метод, вызываемый при отключении джойстика
	 * @public
	 * @method disconnect
	 * @return void
	###
  disconnect: ->
    @connected = false
    @emet "off"
    return

	###*
	 * @public
	 * @method poke
	 * @implements SPoke
	 * @return void
	###
  poke: ->
    return unless @connected
    for own block of @map.activeMap
      @[block].poke()
    return

	###*
	 * Анализирует конфигураци, в случае ошибочности, берёт значения по-умолчанию
	 * @private
	 * @method parseConfig
	 * @param Object config
	 * @return void
	###
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

	###*
	 * Преобразует `id` в значения vendor, product
	 * @private
	 * @method parseId
	 * @param String id
	 * return Array [*, String(4) vendorId, String(4) productId]
	###
  parseId = (id) ->
    moz = /([0-9a-f]{1,4})\-([0-9a-f]{1,4})\-[\s\w]+/
    webkit = /Vendor: ([0-9a-f]{1,4}) Product: ([0-9a-f]{1,4})/
    other = /\b([0-9a-f]{4})\b.+\b([0-9a-f]{4})\b/
    if moz.test id
      vp = id.match moz
    else if webkit.test id
      vp = id.match webkit
    else if other.test id
      vp = id.match other
    else
      vp = [null, "0000", "0000"]
    vp[1] = zeroFill vp[1], 4
    vp[2] = zeroFill vp[2], 4
    vp

	###*
	 * Синонимы коротких и длинных названий кнопок и блоков.
	 * @private
	 * @type Array
	###
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

	###*
	 * Функция твечающая за конечное именования блока и кнопок в зависимости от конфигурации
	 * @private
	 * @method associate
	 * @param Gamepad2 pad usualy for this
	 * @param Number|MASK mode
	 * @param String blockName
	 * @paeam Object mapBlock detail of GamepadMap
	 * @return void
	###
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