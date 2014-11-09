#@ifndef JS_SPOKE_COFFEE_
#@define JS_SPOKE_COFFEE_

###*
 * Класс отвечает за получение есть ли подписки на событие и интерфейс опроса
 * @class SPoke 
###
class SPoke
  ###*
   * subscribed by `action` name or not? If `listen` not null, set listener or unset
   * @public
   * @method s
   * @param String action
   * @param Boolean|Null listen
   * @return Boolean
  ###
  s: (action, listen = null) ->
    unless listen?
      (action of @_subscribe and (@_subscribe[action].listen is true or @_subscribe[action].length > 0)) or @["on#{action}"]?
    else
      if action of @_subscribe
        @_subscribe[action].listen = listen
      else
        false
  
  ###*
   * Interface for children. This method request for emet events
   * @public
   * @method poke
   * @return void
  ###
  poke: ->
    return


#@endif
# end JS_SPOKE_COFFEE_