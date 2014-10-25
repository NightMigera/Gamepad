translateRegEx = /\stranslate\(-?\d+,\s*-?\d+\)/
stickMax = 18
activeColor = '#399B4F'

elements =
  LS: ['path3210', 'text3866-4-3-4-56']
  RS: ['path3293', 'text3866-4-3-4-5']
  UP: ['path3273', 'text3866-4-3-4-8']
  DOWN: ['path3295', 'text3866-4-3-4-8-0']
  LEFT: ['path3305', 'text3866-4-3-4-8-0-6']
  RIGHT: ['path3303', 'text3866-4-3-4-8-0-6-3']
  BACK: ['rect3236', 'text3866-4-3-3']
  START: ['rect3236-7', 'text3866-4-3-3-4']
  HOME: ['path3242', 'text3866-4-3-3-4-7']
  PR: ['path3246', 'text3866']
  SC: ['path3248', 'text3866-8']
  TR: ['path3250', 'text3866-2']
  QT: ['path3244', 'text3866-2-4']
  LB: ['path3234-9', 'text3866-4']
  RB: ['path3234-9-9', 'text3866-4-4']
  LT: ['path3234', 'text3866-4-3']
  RT: ['path3234-1', 'text3866-4-3-8']

prepareElements = (els) ->
  for own name, arr of els
    els[name] = [document.getElementById(arr[0]), document.getElementById(arr[1])]
  els

prepareElements(elements);

movePathTo = (el, x, y) ->
  transform = el.getAttribute('transform')
  unless transform
    transform = ""
  if translateRegEx.test transform
    el.setAttribute 'transform', transform.replace translateRegEx, " translate(#{x}, #{y})"
  else
    el.setAttribute 'transform', transform + " translate(#{x}, #{y})"
  el

down = (el, text) ->
  el.oldFill = el.style.fill
  el.style.fill = activeColor
  text.setAttribute 'class', 'active'

up = (el, text) ->
  el.style.fill = el.oldFill
  text.setAttribute 'class', ''

button = (blockElement, name) ->
  return unless blockElement?
  blockElement.on "down", ->
    down elements[name][0], elements[name][1]
  blockElement.on "up", ->
    up elements[name][0], elements[name][1]
  return

inited = false

@gs = gs = new Gamepads()
gs.detect()

gs.addEventListener 'add', (e) ->
  console.log "Gamepad add", e.detail
  return
gs.addEventListener 'on', (e) ->
  console.log "Gamepad on", e.detail
  return
gs.addEventListener 'off', (e) ->
  console.log "Gamepad off", e.detail
  return


gs.on "on", (e) ->
  if inited
    return
  pad = e.detail

  button pad.menu.back, "BACK"
  button pad.menu.start, "START"
  try button pad.menu.home, "HOME"

  button pad.dpad.up, "UP"
  button pad.dpad.down, "DOWN"
  button pad.dpad.left, "LEFT"
  button pad.dpad.right, "RIGHT"

  button pad.face.PR, "PR"
  button pad.face.SC, "SC"
  button pad.face.TR, "TR"
  button pad.face.QT, "QT"

  button pad.lrtb.LB, "LB"
  button pad.lrtb.RB, "RB"
  button pad.lrtb.LT, "LT"
  button pad.lrtb.RT, "RT"

  button pad.axes.LSB, "LS"
  button pad.axes.RSB, "RS"

  LSX = 0
  LSY = 0
  pad.axes.LSX.on "change", (e) ->
    LSX = e.detail.newValue
    x = Math.round(stickMax * LSX / 255)
    y = Math.round(stickMax * LSY / 255)
    movePathTo elements.LS[0], x, y
    movePathTo elements.LS[1], x, y
    return
  pad.axes.LSY.on "change", (e) ->
    LSY = e.detail.newValue
    x = Math.round(stickMax * LSX / 255)
    y = Math.round(stickMax * LSY / 255)
    movePathTo elements.LS[0], x, y
    movePathTo elements.LS[1], x, y
    return

  RSX = 0
  RSY = 0
  pad.axes.RSX.on "change", (e) ->
    RSX = e.detail.newValue
    x = Math.round(stickMax * RSX / 255)
    y = Math.round(stickMax * RSY / 255)
    movePathTo elements.RS[0], x, y
    movePathTo elements.RS[1], x, y
    return
  pad.axes.RSY.on "change", (e) ->
    RSY = e.detail.newValue
    x = Math.round(stickMax * RSX / 255)
    y = Math.round(stickMax * RSY / 255)
    movePathTo elements.RS[0], x, y
    movePathTo elements.RS[1], x, y
    return

  inited = true
  return
