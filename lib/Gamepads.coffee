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

top = @

class Gamepads extends EventedArray

  _support = false
  _webkitStyle = false
  _reQueue = []

  constructor: (gamepads...) ->
    unless navigator?
      ERR "Navigator not exists! Browser strange."
      return
    if (not navigator.getGamepads?) and (not navigator.webkitGetGamepads?)
      ERR "Gamepad API not yet."
      return

    EventTargetEmiter.call @, 'on', 'off', 'add'
    # @splice 0, 0, items...
    #todo register items

    if navigator.getGamepads?
      top.addEventListener 'gamepadconnected', (e) =>
        r = @_addGamepad(e.gamepad)
        if r is -1
          r = @registred[e.gamepad.id]
          unless r?
            ERR "Gamepad not added!"
            return
        @_createEvent 'on', @[r]
        return
      top.addEventListener 'gamepaddisconnected', (e) =>
        @_gamepadDisconnect e.gamepad
    else
      _webkitStyle = true
      _registered = [] # wrong! it's local registered, not global!
      _getPad = (gamepad) =>
        for pad in @registred[gamepad.id]
          return pad if gamepad is pad.gamepad
        return null
      ###_webkitStyle.detail =
        instance: @
        registered: _registered###

      _reQueue.push =>
        # detect connect gamepad and disconnect
        for gamepad in navigator.webkitGetGamepads()
          continue unless gamepad
          unless gamepad in _registered
            _registered.push gamepad
            r2 = @_addGamepad gamepad
            unless gamepad.hasOwnProperty('connected')
              gamepad.connected = false
              gamepad.timechange = NOW - MAX_INACTIVE
            else
              if gamepad.connected is true
                @[r2].connect()
                @_createEvent 'on', @[r2]
        return

      _reQueue.push =>
        for gamepad in _registered
          if gamepad.connected
            if NOW - gamepad.timechange > MAX_INACTIVE
              gamepad.connected = false
              @_gamepadDisconnect gamepad
          else if NOW - gamepad.timechange < MAX_INACTIVE
            gamepad.connected = true
            pad3 = _getPad gamepad
            unless pad3
              ERR "Logic: gamepad registered not created or replaced"
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

    @_startShedule()

    @registred = {}

    _support = true

  registred: null

  detect: ->
    return false unless _support
    for gamepad in navigator.getGamepads()
      @_addGamepad(gamepad)
    true

  _createEvent: (name, gamepad) ->
    return null unless isString name
    return null unless gamepad
    @emet name, new CustomEvent name, detail: gamepad

  _addGamepad: (gamepad) ->
    return -2 unless gamepad?
    add = =>
      pad2 = new Gamepad2 gamepad
      pad2.on "change", ->
        gamepad.timechange = NOW
      @push pad2
      @registred[gamepad.id] = [pad2]
      @_createEvent 'add', pad2
      if gamepad.connected
        pad2.connect()
      else
        gamepad.connected = false
      return @length - 1
    unless gamepad.id of @registred # if gamepad with this id not regitred
      return add()
    else # if gamepad can be registered
      for pad in @registred[gamepad.id]
        if pad.gamepad.connected is false
          pad.gamepad = gamepad
          pad.connect() if gamepad.connected
          return @indexOf pad
      return add()
    return -1

  _gamepadDisconnect: (gamepad) ->
    ids = @registred[gamepad.id]
    unless ids
      ERR "Disconect unregistered gamepad. After init should be call `detect` method."
      return
    for pad in ids
      if pad.gamepad is gamepad
        pad2 = pad
        break
    unless pad2?
      ERR "Critical: registred and not created gamepad!"
      return
    pad2.disconnect()
    @_createEvent 'off', pad2
    return

  _startShedule: ->
    requestAnimationFrame = top.requestAnimationFrame or top.mozRequestAnimationFrame or top.webkitRequestAnimationFrame
    requestAnimationFrame =>
      t = null
      if _webkitStyle
        t2 = null
      p = @
      startTimers = ->
        t is null and t = tick 17, -> # interval 21 is 1000/60
          for pad in p
            pad.poke() if pad.connected # к чему тревожить мертвецов?
          return
        if _webkitStyle and t2 is null
          t2 = tick 100, ->
            for fn in _reQueue
              fn()
            return
        return
      stopTimers = ->
        if t isnt null
          stopTick(t)
          t = null
        if t2 isnt null and _webkitStyle
          stopTick(t2)
          t2 = null
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
  @getInfo = (type) ->
    if type?
      if messages[type]?
        return messages[type]
      WARN "Gamepads: type message not exists: #{type}"
    return messages
#@endif


#@endif
#end JS_GAMEPADS_COFFEE_