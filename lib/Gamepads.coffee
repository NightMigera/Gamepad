#@ifndef JS_GAMEPADS_COFFEE_
#@define JS_GAMEPADS_COFFEE_

###
  naming variables:
  gamepad and gamepadX instance of Gamepad (by browser)
  pad and padX instance of Gamepad2 (local)
###

#@include "sys.coffee"

#@include "EventedArray.coffee"

#@include "Gamepad.coffee"

#@define MAX_INACTIVE 15*60000

# window object, or other global top this
top = @

###*
 * Массив джойстиков с возможностью отслеживания их подключения, отключения.
 * @class Gamepads
 * @extends EventedArray
###
class Gamepads extends EventedArray
  ###*
   * Поддерживается ли интерфейс в принципе.
   * @private
   * @type Boolean
  ###
  _support = false
  
  ###*
   * Реализация только в стиле webkit? В противном случае полная реализация.
   * @private
   * @type Boolean
  ###
  _webkitStyle = false
  
  ###*
   * Ссылк на таймер.
   * @private
   * @type shedullerId|Number
  ###
  _webkitPoolSheduller = null
  
  ###*
   * Массив заданий для webkit
   * @private
   * @type Array
  ###
  _reQueue = []
  
  ###*
   * Config by default.
   * @private
   * @type Object
  ###
  defaultConfig =
    silent: true # errors and warnings not print to console (if compiled not debug mode). Allowed for all instance!
    autoDetect: true # detect all gamepads on constructor
    frequencyUpdate: 60 # frequency update statement in Hz
    webkitFrequencyUpdate: 10 # frequency update gamepads work in webkit
    webkitInactiveDisconnect: MAX_INACTIVE # After how many milliseconds considered disabled
    naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT # mask use long names of button and block and short names
    maps: null # advanced map or array map (map instance of GamepadMap)
    allowCustomBlockName: false # allow custom block name, (ex: 'center' for axes and menu)

  ###*
   * Анализирает и проверяет конфигурацию.
   * Если параметр ошибочен, то пишется предупреждение и выставляется значение по умолчанию
   * @private
   * @method parseConfig
   * @param Object config
   * @return Object
  ###
  parseConfig = (config) ->
    unless config
      ERR "Gamepads: config: config is empty. Merging fail."
      return
    unless typeof config is "object"
      ERR "Gamepads: config: config not object."
      return

    warn = (warntext) ->
      WARN "Gamepads: config: #{warntext}. Set default"

    booleanTest = (name, warntext) ->
      if config[name] isnt not not config[name]
        warn warntext
        config[name] = defaultConfig[name]
        false
      true

    positiveNumberTest = (name, noNumber, signedNumber) ->
      unless isFinite config[name]
        warn noNumber
      else if (config.frequencyUpdate|0) <= 0
        warn signedNumber
      else
        config[name] = config[name]|0
        return true
      config[name] = defaultConfig[name]
      false

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

    booleanTest 'silent', "fail silent format"

    silent = config.silent

    positiveNumberTest 'frequencyUpdate', "frequency update is not number", "frequency must be great then 0"

    positiveNumberTest 'webkitFrequencyUpdate', "webkit frequency is not number", "webkit frequency must be great then 0"

    positiveNumberTest 'webkitInactiveDisconnect', "time must be number", "time must be great then 0"

    maskTest 'naming', GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT, "naming must be bitmask", "not allowed values for naming bitmask"

    booleanTest "allowCustomBlockName", "allowCustomBlockName must be boolean"

    if config.maps?
      if config.maps instanceof GamepadMap
        config.maps = [config.maps]
      unless config.maps instanceof Array
        warn "map must be array of gamepadMap instance or gamepadMap instance"
        config.maps = null
      wrongMap = []
      for map, index in config.maps
        unless map instanceof GamepadMap
          warn "map #{index} not instance of GamepadMap. Use constructor for create map"
          wrongMap.push index
      for index in wrongMap by -1
        config.maps.splice index, 1
      if config.maps.length is 0
        config.maps = null

    return config

  ###*
   * Инициаизвция по конфигурации. Конфигурация и значения описаны выше в `defaultConfig`
   * @constructor
   * @param Object config
  ###
  constructor: (config = {}) ->
    unless navigator?
      ERR "Gamepads: navigator not exists! Browser strange."
      return
    if (not navigator.getGamepads?) and (not navigator.webkitGetGamepads?)
      ERR "Gamepads: Gamepad API not yet."
      return

    config = overlay defaultConfig, config
    @config = parseConfig config
    
    # add and declare event listener handlers
    EventTargetEmiter.call @, 'on', 'off', 'add'

      # in method getGamepads exist then must be full realisation of GamepadAPI
    if navigator.getGamepads?
      top.addEventListener 'gamepadconnected', (e) =>
        r = @_addGamepad(e.gamepad)
        if r is -1
          r = @registred[e.gamepad.id]
          unless r?
            ERR "Gamepads: gamepad not added!"
            return
          @_createEvent 'on', @[r]
        return
      top.addEventListener 'gamepaddisconnected', (e) =>
        @_gamepadDisconnect e.gamepad
    else # without if becouse checked before
      _webkitStyle = true
      _registered = [] # wrong! it's local registered, not global!
      _getPad = (gamepad) =>
        for pad in @registred[gamepad.id]
          return pad if gamepad is pad.gamepad
        return null
      ###_webkitStyle.detail =
        instance: @
        registered: _registered###
      _webkitMaxInactive = config.webkitInactiveDisconnect
      # check add gamepads. If time recheck too big then connect detect very slow.
      _reQueue.push =>
        # detect connect gamepad and disconnect
        for gamepad in navigator.webkitGetGamepads()
          continue unless gamepad
          unless gamepad in _registered
            _registered.push gamepad
            r2 = @_addGamepad gamepad
            unless gamepad.hasOwnProperty('connected')
              gamepad.connected = false
              gamepad.timechange = NOW - _webkitMaxInactive
            else
              if gamepad.connected is true
                @[r2].connect()
                @_createEvent 'on', @[r2]
        return
      # request all gamepads in _registered for connect or disconnect
      _reQueue.push =>
        for gamepad in _registered
          if gamepad.connected
            if NOW - gamepad.timechange > _webkitMaxInactive #todo: not work, remount
              gamepad.connected = false
              @_gamepadDisconnect gamepad
          else if NOW - gamepad.timechange < _webkitMaxInactive
            gamepad.connected = true
            pad3 = _getPad gamepad
            unless pad3
              ERR "Gamepads: gamepad registered not created or replaced"
              return
            pad3.connect()
            @_createEvent 'on', pad3
          else
            pressedButton = false
            for button in gamepad.buttons
              if button
                pressedButton = true
                break
            if pressedButton
              gamepad.timechange = NOW
        return

    navigator.getGamepads = navigator.getGamepads or navigator.webkitGetGamepads

    @_startShedule(config.frequencyUpdate, config.webkitFrequencyUpdate)

    @registred = {}

    _support = true

    if config.autoDetect
      @detect()

  ###*
   * Зарегестрированые джойстики по их ID в виде массива.
   * @example registered['026d12ad'] = [pad1, pad2, ...]
   * @public
   * @type Object
  ###
  registred: null

  ###*
   * Current config. Must be read only, if change effect not garanted.
   * Текущая конфигурация. Изменения папрямую приведут к неизвестному результату.
   * @public
   * @type Object|Dict
  ###
  config: null

  ###*
   * Detect exists gamepads. Can be run manual, can be run automatic if `config.autoDetect`
   * If api not supported, then return false, else return true. 
   * Add only not added gamepads. May be run safely.
   * Определяет и добавляет джойстики из системы. Можно вызвать вручную, а можно
   * автоматически, если `config.autoDetect`. Возвращает true, если интерфейс подерживается
   * и false, еси нет. Может быть безопасно вызвана несколько раз, добавлятся только те
   * джойстики, что не добавлены уже. Может быть использована дляопределения поддержки
   * интерфейса системой. 
   * @public
   * @return Boolean
  ###
  detect: ->
    return false unless _support
    for gamepad in navigator.getGamepads()
      @_addGamepad(gamepad)
    true

  ###*
   * Упрощённое создание события.
   * @protected
   * @param String     name название события
   * @param Gamepad2  pad экземпляр, вызвавший событие
   * @return Boolean было ли перехвачено событие
  ###
  _createEvent: (name, pad) ->
    return null unless isString name
    return null unless pad
    @emet name, new CustomEvent name, detail: pad

  ###*
   * Добавляет или переподключает джойстик.
   * @protected
   * @param Gamepad gamepad браузерный экземпляр.
   * @return Number id new Gamepad2 or -1 if not added
  ###
  _addGamepad: (gamepad) ->
    return -2 unless gamepad?
    add = =>
      pad2 = new Gamepad2 gamepad,
        naming: @config.naming
        maps: @config.maps
        allowCustomBlockName: @config.allowCustomBlockName
        trusted: true
      if _webkitStyle
        pad2.on "change", ->
          gamepad.timechange = NOW
      @push pad2
      @registred[gamepad.id] = [pad2]
      @_createEvent 'add', pad2
      if gamepad.connected
        wait 0, -> pad2.connect()
        wait 1, => @_createEvent 'on', pad2
      else
        gamepad.connected = false
      return @length - 1
    unless gamepad.id of @registred # if gamepad with this id not regitred
      return add()
    else # if gamepad can be registered
      for pad in @registred[gamepad.id]
        if pad.gamepad.connected is false
          pad.gamepad = gamepad
          if gamepad.connected
            wait 0, -> pad.connect()
            wait 1, => @_createEvent 'on', pad
          return @indexOf pad
      return add()
    return -1

  ###*
   * Механизм отключения джойстика.
   * @protected
   * @param Gamepad gamepad
   * @return void
  ###
  _gamepadDisconnect: (gamepad) ->
    ids = @registred[gamepad.id]
    unless ids
      ERR "Gamepads: Disconect unregistered gamepad. After init should be call `detect` method."
      return
    for pad in ids
      if pad.gamepad is gamepad
        pad2 = pad
        break
    unless pad2?
      ERR "Gamepads: Critical: registred and not created gamepad!"
      return
    pad2.disconnect()
    @_createEvent 'off', pad2
    return

  ###*
   * Запуск механизмаопроса состояний джойстиков.
   * @protected
   * @param Number Hz частота обновлений состояний
   * @param Number wHz частота опроса заданий webkit
   * @return void
  ###
  _startShedule: (Hz = 60, wHz = 10) ->
    requestAnimationFrame = top.requestAnimationFrame or top.mozRequestAnimationFrame or top.webkitRequestAnimationFrame
    requestAnimationFrame =>
      t = null
      p = @
      ws = _webkitStyle # it's need
      startTimers = ->
        t is null and t = tick (1000 / Hz |0), -> # interval 21 is 1000/60
          # fucking webkit need requrst for all gamepads statements every fucking time!
          navigator.webkitGetGamepads() if 'webkitGetGamepads' of navigator
          for pad in p
            pad.poke() if pad.connected # к чему тревожить мертвецов?
          return
        if ws and _webkitPoolSheduller is null
          _webkitPoolSheduller = tick (1000 / wHz |0), ->
            for fn in _reQueue
              fn()
            return
        return
      stopTimers = ->
        if t isnt null
          stopTick(t)
          t = null
        if _webkitPoolSheduller isnt null and ws
          stopTick(_webkitPoolSheduller)
          _webkitPoolSheduller = null
        return
      top.addEventListener 'focus', ->
        startTimers()
      top.addEventListener 'blur', ->
        stopTimers()
      startTimers()
      return
    return

#@ifdef DEBUG
  @getInfo = (type) ->
    unless type?
      return info: ["Gamepads: look at console logs!"]
    return ["Gamepads: look at console logs!"]
#@else
  ###*
   * Получаем сообщения системы.
   * @param String type
   * @return Array messages
  ###
  @getInfo = (type) ->
    if type?
      if messages[type]?
        return messages[type]
      WARN "Gamepads: type message not exists: #{type}"
    return messages
#@endif


#@endif
#end JS_GAMEPADS_COFFEE_