#@ifndef JS_EVENTED_ARRAY_COFFEE_
#@define JS_EVENTED_ARRAY_COFFEE_

#@include "EventTargetEmiter.coffee"

#@include "sys.coffee"

class EventedArray extends Array # implements EventTarget

  _implements.call(@, EventTargetEmiter) # implement mechanizm

  constructor: (items...) ->
    @splice 0, 0, items...

#@endif
#end JS_EVENTED_ARRAY_COFFEE_