#@ifndef JS_EVENT_TARGET_EMITER_COFFEE_
#@define JS_EVENT_TARGET_EMITER_COFFEE_

###*
 * EventTargetEmmiter emulate EventTarget interface width Emiter methods on, off, emet, parent
 * Интерфейс EventTarget полностью воплощён в соответствии со стандартом w3c:
 * http://www.w3.org/TR/domcore/#interface-eventtarget
 * @class EventTargetEmiter
###
class EventTargetEmiter # implements EventTarget

  ###*
   * Список подпсок на события по названию в виде массива.
   * @protected
   * @type Object
  ###
  _subscribe: null

  ###*
   * Ссылка на родительский элемент
   * @public
   * @type EventTargetEmiter
  ###
  parent: null

  ###*
   * Проверяет правильность создаваемого обработчика события.
   * @protected
   * @method _checkValues
   * @param String|* type имя события
   * @param Handler|* listener  функция-обработчик
  ###
  _checkValues: (type, listener) ->
    unless isString type
      ERR "type not string"
      return false
    unless isFunction listener
      ERR "listener is not a function"
      return false
    true

  ###*
   * Перечисленные в `list` события декларируют события и создат традиционные 
   * handler-обработчики
   * @constructor
   * @param Array list названия событий
  ###
  constructor: (list...) ->
    @_subscribe =
      _length: 0
    for e in list
      @_subscribe[e] = []
      @['on' + e] = null

  ###*
   * Add function `listener` by `type` with `useCapture`
   * @public
   * @method addEventListener
   * @param String type
   * @param Handler listener
   * @param Boolean useCapture = false
   * @return void
  ###
  addEventListener: (type, listener, useCapture = false) ->
    unless @_checkValues(type, listener)
      return
    useCapture = not not useCapture
    @_subscribe[type].push [listener, useCapture]
    @_subscribe._length++
    return

  ###*
   * Remove function `listener` by `type` with `useCapture`
   * @public
   * @method removeEventListener
   * @param String type 
   * @param Handler listener
   * @param Boolean useCapture = false
  ###
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

  ###*
   * Burn, baby, burn!
   * @public
   * @method dispatchEvent
   * @param Event evt
   * @return Boolean
  ###
  dispatchEvent: (evt) ->
    unless evt instanceof Event
      ERR "evt is not event."
      return false
    t = evt.type
    unless @_subscribe[t]?
      throw new EventException "UNSPECIFIED_EVENT_TYPE_ERR"
      return false
    @emet t, evt

  ###*
   * Alias for addEventListener
   * @public
   * @method on
   * @param String type
   * @param Handler listener
   * @param Boolean useCapture
   * @return void
  ###
  on: (args...) -> @addEventListener args...

  ###*
   * Alias for removeEventListener
   * @public
   * @method off
   * @param String type
   * @param Handler listener
   * @param Boolean useCapture
   * @return void
  ###
  off: (args...) -> @removeEventListener args...

  ###*
   * Emiter event by `name` and create event or use `evt` if exist
   * @param String name
   * @param Event|null evt
   * @return Boolean
  ###
  emet: (name, evt = null) ->
    # run handled-style listeners
    r = @['on' + name](evt) if isFunction @['on' + name]
    return false if r is false
    # run other
    for fn in @_subscribe[name]
      try r = fn[0](evt)
      break if fn[1] is true or r is false
    if evt.bubbles is true
      try @parent.emet name, evt
    if evt? then not evt.defaultPrevented else true

#@endif
#end JS_EVENT_TARGET_EMITER_COFFEE_