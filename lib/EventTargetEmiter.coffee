class EventTargetEmiter # implements EventTarget

  _subscribe: null

  _checkValues: (type, listener) ->
    unless isString type
      ERR "type not string"
      return false
    unless isFunction listener
      ERR "listener is not a function"
      return false
    true

  constructor: (list...) ->
    @_subscribe =
      _length: 0
    for e in list
      @_subscribe[e] = []
      @['on' + e] = null

  addEventListener: (type, listener, useCapture = false) ->
    unless @_checkValues(type, listener)
      return
    useCapture = not not useCapture
    @_subscribe[type].push [listener, useCapture]
    @_subscribe._length++
    return

  removeEventListener: (type, listener, useCapture = false) ->
    unless @_checkValues(type, listener)
      return
    useCapture = not not useCapture
    return unless @_subscribe[type]?
    for fn, i in @_subscribe[type]
      if fn[0] is listener and fn[1] is useCapture
        @_subscribe[type].splice i, 1
        @_subscribe._length--
        return
    return

  dispatchEvent: (evt) ->
    unless evt instanceof Event
      ERR "evt is not event."
      return false
    t = evt.type
    unless @_subscribe[t]?
      throw new EventException "UNSPECIFIED_EVENT_TYPE_ERR"
      return false
    emet t, evt

  on: @::addEventListener

  off: @::removeEventListener

  emet: (name, evt = null) ->
    # run handled-style listeners
    r = @['on' + name](evt) if isFunction @['on' + name]
    return false if r is false
    # run other
    for fn in @_subscribe[name]
      try r = fn[0](evt)
      break if fn[1] is true or r is false
    if evt? then not evt.defaultPrevented else true
