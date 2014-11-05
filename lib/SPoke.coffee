#@ifndef JS_SPOKE_COFFEE_
#@define JS_SPOKE_COFFEE_

###*
 * Класс отвечает за получение есть ли подписки на событие и интерфейс опроса
 * @class SPoke 
###
class SPoke
  ###*
   * subscribed by `action` name or not?
   * @public
   * @method s
   * @param String action
   * @return Boolean
  ###
  s: (action) ->
    @_subscribe.hasOwnProperty(action) and @_subscribe[action].length > 0
  
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