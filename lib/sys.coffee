#@ifndef JS_SYS_COFFEE_
#@define JS_SYS_COFFEE_

#@ifdef EXTENDS
_extends = (child, parent) ->
  ctor = ->
    @constructor = child
    return
  for key of parent
    child[key] = parent[key]  if parent.hasOwnProperty(key)
  ctor:: = parent::
  child:: = new ctor()
  child.__super__ = parent::
  child
#@endif

_implements = (mixins...) ->
  for mixin in mixins
    @::[key] = value for key, value of mixin::
  @

###*
  * накладывает объект `from` на объект `to`<br />
  * если нужно создать третий объект (не трогать `to`) из двух надо использовать `merge(merge({}, to), from)` <br />
  * (!) Нет защиты от дурака. Если аргументы не объекты, то результат не предсказуем и может быть ошибка.
  *
  * @method merge
  * @param {Object|Array} to модифицируемый объект
  * @param {Object|Array} from модифицирующий объект
  * @return {Object} изменённый `to`
###
merge = (to, from) ->
  for own p of from
    try
    # Property in destination object set; update its value.
      if typeof from[p] is 'object'
        to[p] = merge(to[p], from[p])
      else
        to[p] = from[p]
    catch e
    # Property in destination object not set; create it and set its value.
      to[p] = merge {}, from[p]
  to

###*
  * merge under with upper, but create new object, don't touch under or upper.
  *
  * @method overlay
  * @param {Object|Array} under basic object
  * @param {Object|Array} upper object width modification
  * @return {Object} new object
###
overlay = (under, upper) ->
  merge merge({}, under), upper

#@define NOW Date.now()

silent = true

#@ifdef DEBUG

  #@define ERR throw new Error
  #@define WARN console.warn
  #@define INFO console.info

#@else
  #@define ERR  throwError
  #@define WARN throwWarn
  #@define INFO throwInfo

messages =
  error: []
  warn: []
  info: []
start = NOW
throwError = (errors...) ->
  out = [NOW - start]
  out.push errors...
  messages.error.push out
  console.error errors... unless silent
  return
throwWarn = (warn...) ->
  out = [NOW - start]
  out.push warn...
  messages.warn.push out
  console.warn warn... unless silent
  return
throwInfo = (info...) ->
  out = [NOW - start]
  out.push info...
  messages.info.push out
  console.info info... unless silent
  return

#@endif
# DEBUG

isFunction = (functionToCheck) ->
  getType = {}
  functionToCheck and getType.toString.call(functionToCheck) is "[object Function]"

isString = (string) ->
  string + '' is string

# синтаксический сахар для привычных функций
wait = (time, fn) ->
  setTimeout fn, time

skip = (waitId) ->
  clearTimeout waitId

tick = (time, fn) ->
  setInterval fn, time

stopTick = (tickId) ->
  clearInterval tickId

#@endif
#end JS_SYS_COFFEE_
