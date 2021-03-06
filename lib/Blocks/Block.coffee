#@ifndef JS_BLOCKS_BLOCK_COFFEE_
#@define JS_BLOCKS_BLOCK_COFFEE_

#@include "EventedArray.coffee"

#@include "SPoke.coffee"

#@include "Axis.coffee"

#@include "Button.coffee"

###*
 * Logical block width axes, buttons and collect events
 * Лоический блок, объеденяющий оси и кнопки по некоторому принаку
 * @class Block
 * @extends EventedArray //зачем массив? Иначально нужен был массив,но потом передумал
 * @implements SPoke
###
class Block extends EventedArray

  _implements.call(@, SPoke)

  ###*
   * ссылка на оригиналный джойстик
   * @public
   * @type Gamepad
  ###
  gamepad: null

  ###*
   * Карта кнопок для блока
   * @public
   * @type Object
  ###
  map: null

  ###*
  ###
  name: ""

  ###*
   * На основе карты `map` из `gamepad` создаём `Block`
   * @constructor
   * @param Object map GamepadMapBlock
   * @param Gamepad gamepad
  ###
  constructor: (map, gamepad, @name) ->
    EventTargetEmiter.call @, 'change'
    @gamepad = gamepad
    @_mapParse(map)

  ###*
   * Анализирует карту и создаёт элементы блока на её основе.
   * @protected
   * @method _mapParse
   * @param Object map GamepadMapBlock
   * @return void
  ###
  _mapParse: (map) ->
    @map = map
    for own name, val of map
      unless val?
        delete map[name]
        continue
      if val.hasOwnProperty('axis') and val.axis?
        axis = new Axis(@gamepad, val.axis, val.mode or AS_STICK, name, Boolean(val.positive), val.triggerValue or 0)
        if 'onchange' of axis
          @[name] = axis
          axis.parent = @
        else
          delete map[name]
          continue
      else if val.hasOwnProperty('button') and val.button?
        button = new Button(@gamepad, val.button, name, val.asAxis)
        if 'onchange' of button
          @[name] = button
          button.parent = @
        else
          delete map[name]
          continue
      else
        ERR "Value #{name} of MAP incorrect!"
        return
    return

  ###*
   * Добавляет обработчики к элементам при подписке на изменения
   * @public
   * @implements EventTargetEmiter
   * @param String type
   * @return void
  ###
  addEventListener: (type) ->
    if type is 'change' and not @s('change')
      for own name of @map
        @[name].s 'change', true
    super

  ###*
   * Если больше обработчиков нет, то убирает подписывание с событий
   * @public
   * @implements EventTargetEmiter
   * @param String type
   * @return void
  ###
  removeEventListener: (type) ->
    super
    if type is 'change' and @_subscribe.change.length is 0
      for own name of @map
        @[name].s 'change', false
    return

  ###*
   * Переподписывает блок на новый экемпляр `gamepad`
   * @public
   * @method reSubscribe
   * @param Gamepad gamepad
   * @return void
  ###
  reSubscribe: (gamepad) ->
    @gamepad = gamepad
    for own name, val of @map
      continue unless @[name]?
      if val.hasOwnProperty('axis')
        @[name].reSubscribe(gamepad)
      else if val.hasOwnProperty('button')
        @[name].reSubscribe(gamepad)
      else
        ERR "Map was be wrong changed or crashed"
    return

  ###*
   * Дёргает дочерние объекты
   * @public
   * @implements SPoke
   * @method poke
   * @return void
  ###
  poke: ->
    for own name of @map
      @[name].poke()
    return


#@endif
# end JS_BLOCKS_BLOCK_COFFEE_