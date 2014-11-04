#@ifndef JS_EVENTED_ARRAY_COFFEE_
#@define JS_EVENTED_ARRAY_COFFEE_

#@include "EventTargetEmiter.coffee"

#@include "sys.coffee"
###*
 * Массив с возможностью создания и получения событий.
 * @class EventedArray
 * @extends Array
 * @implements EventTargetEmiter
###
class EventedArray extends Array # implements EventTarget

  _implements.call(@, EventTargetEmiter) # implement mechanizm

	###*
	 * @constructor
	 * @param items array-style constructor without single item as length.
	###
  constructor: (items...) ->
    @splice 0, 0, items...

#@endif
#end JS_EVENTED_ARRAY_COFFEE_