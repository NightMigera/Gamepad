#@ifndef JS_SPOKE_COFFEE_
#@define JS_SPOKE_COFFEE_

class SPoke
  # subscribed method?
  s: (action) ->
    @_subscribe.hasOwnProperty(action) and @_subscribe[action].length > 0
  # дёргаем товарища
  poke: ->
    return


#@endif
# end JS_SPOKE_COFFEE_