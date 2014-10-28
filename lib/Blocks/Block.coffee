#@ifndef JS_BLOCKS_BLOCK_COFFEE_
#@define JS_BLOCKS_BLOCK_COFFEE_

#@include "EventedArray.coffee"

#@include "SPoke.coffee"

#@include "Axis.coffee"

#@include "Button.coffee"

class Block extends EventedArray

  _implements.call(@, SPoke)

  gamepad: null

  map: null

  constructor: (map, gamepad) ->
    EventTargetEmiter.call @, 'change'
    @gamepad = gamepad
    @_mapParse(map)

  _mapParse: (map) ->
    @map = map
    for own name, val of map
      if val.hasOwnProperty('axis') and val.axis?
        axis = new Axis(@gamepad, val.axis, val.mode or AS_STICK, Boolean(val.positive), val.triggerValue or 0)
        if 'onchange' of axis
          @[name] = axis
        else
          delete map[name]
          continue
      else if val.hasOwnProperty('button') and val.button?
        button = new Button(@gamepad, val.button, val.asAxis)
        if 'onchange' of button
          @[name] = button
        else
          delete map[name]
          continue
      else
        ERR "Value #{name} of MAP incorrect!"
        return
      @[name].on 'change', (e) =>
        @emet 'change', e
        return
    return

  addEventListener: (type) ->
    if type is 'change' and not @s('change')
      for own name of @map
        @[name].on 'change', (e) =>
          @emet 'change', e
          return
    super

  # TODO: removeEventListener correct for remove listener from childrens

  reSubscribe: (gamepad) ->
    @gamepad = gamepad
    for own name, val of @map
      continue unless @[name]?
      if val.hasOwnProperty('axis')
        @[name].reSubscribe(gamepad)
      else if val.hasOwnProperty('button')
        @[name].reSubscribe(gamepad)
      else
        ERR "Map was be changed or crashed"
    return

  poke: ->
    for own name of @map
      @[name].poke()
    return


#@endif
# end JS_BLOCKS_BLOCK_COFFEE_