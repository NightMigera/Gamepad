#@ifndef JS_SYS_COFFEE_
#@define JS_SYS_COFFEE_

#@ifdef EXTENDS
###*
  Наследует класс child из класса parent.
  @param class child дочерний класс
  @param class parent родительский класс
  @return class результат наследованияъ
###
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
  * @param {Object|Array} to модифицируемый объект
  * @param {Object|Array} from модифицирующий объект
  * @return {Object} изменённый `to`
###
merge = (to, from) ->
  unless to? or typeof to isnt 'object'
    return from
  for own p of from
    try
    # Property in destination object set; update its value.
      if from[p]? and typeof from[p] is 'object'
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
###*
  Режим без вывода ошибок, предупреждений и сообщений в консоль. Учитывается без DEBUG,
  определяется в конструкторе Gamepads.
  @type Boolean
###
silent = true

#@ifdef DEBUG

  #@define ERR throw new Error
  #@define WARN console.warn
  #@define INFO console.info

#@else
  #@define ERR  throwError
  #@define WARN throwWarn
  #@define INFO throwInfo
# все сообщения всех экземпляров Gamepads попадают в messages в обычном режиме.
messages =
  error: []
  warn: []
  info: []
###*
  константа для меток времени относительно старта скрипта в массиве сообщений
  @type Timestamp
###
start = NOW

###* 
  Добавляет сообщения в массив, прикрепляя метку времени. 
  Если не тихий режим, выводит в консоль.
  @param * errors ошибки
###
throwError = (errors...) ->
  out = [NOW - start]
  out.push errors...
  messages.error.push out
  console.error errors... unless silent
  return
###*
  @param * warn предупреждения
###
throwWarn = (warn...) ->
  out = [NOW - start]
  out.push warn...
  messages.warn.push out
  console.warn warn... unless silent
  return
###*
  @param * info сообщения
###
throwInfo = (info...) ->
  out = [NOW - start]
  out.push info...
  messages.info.push out
  console.info info... unless silent
  return

#@endif
# DEBUG

###*
  Check `functionToCheck` function handle or not?
  @param handle|* functionToCheck
  @retoorn Boolean
###
isFunction = (functionToCheck) ->
  getType = {}
  functionToCheck and getType.toString.call(functionToCheck) is "[object Function]"

###*
  Check `string` is string.
  @param String|* string
  @retoorn Boolean
### 
isString = (string) ->
  string + '' is string

###*
  Create from `number` string length `width` width '0' before `number`.
  If `number` length above than `width`, return `number` as string.
  @param String|Number number
  @param Number width
  @return String
###
zeroFill = (number, width) ->
  width -= number.toString().length
  return new Array(width + 1).join("0") + number  if width > 0
  number + "" # always return a string

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
