#@ifndef JS_MAP_GAMEPAD_MAP_COFFEE_
#@define JS_MAP_GAMEPAD_MAP_COFFEE_

#@include "../sys.coffee"

class GamepadMap
  @vendor: ""
  @product: ""
  @platform: "linux"
  @activeMap: null

  constructor: (vendor, product) ->
    unless isString(vendor) and vendor.length is 4 and /[a-f0-9]/i.test(vendor)
      ERR "GamepadMap: vendor incorrect: #{vendor}"
      return
    unless isString(product) and product.length is 4 and /[a-f0-9]/i.test(product)
      ERR "GamepadMap: product incorrect: #{product}"
      return
    @vendor = vendor.toLowerCase()
    @product = product.toLowerCase()

    isLinux = /linux/i
    isMac = /mac/i
    isWindows = /window/i
    platform = navigator.platform
    if isLinux.test platform
      @platform = "linux"
    else if isMac.test platform
      @platform = "mac"
    else if isWindows.test platform
      @platform = "windows"
    else
      WARN "Mobile or other not supported platform"
      @platform = "other"
    @activeMap = @loadMap()

  loadMap: ->
    index = @vendor + @product
    unless isString(index) and index.length is 8 and /[a-f0-9]/.test(index)
      ERR "GamepadMap: in map changed vendor or product on incorrect"
      return

    defaultMap = @other["00000000"]
    return defaultMap if index is "00000000"

    mapsByPlatform = @[@platform]
    unless mapsByPlatform?
      WARN "GamepadMap: platform not supported. Use default map."
      return defaultMap

    unless mapsByPlatform.hasOwnProperty(index)
      WARN "GamepadMap: vendor or product not supported. Use default map."
      return defaultMap

    map = mapsByPlatform[index]
    if isString map
      if mapsByPlatform.hasOwnProperty map
        return overlay defaultMap, mapsByPlatform[map]
      WARN "GamepadMap: index of map not avialable."
      return defaultMap

    return overlay(defaultMap, map) or defaultMap

  #@include "linux.coffee"

  other:
    "00000000":
      face:
        PR: button: 0 # primary
        SC: button: 1 # secondary
        TR: button: 2 # tertiary
        QT: button: 3 # quaternary
      lrtb: # shouldersTriggers
        LB: button: 4 # leftShoulder  # L1
        RB: button: 5 # rightShoulder # R1
        LT: button: 6 # leftTrigger   # L2
        RT: button: 7 # rightTrigger  # R2
      menu:
        back: button: 8 # select
        start: button: 9
        home: button: 16
        caca: button: 17
      axes:
        LSB: button: 10 # leftStickButton
        LSX:
          axis: 0
          mode: AS_STICK
        LSY:
          axis: 1
          mode: AS_STICK
        RSB: button: 11 # rightStickButton
        RSX:
          axis: 2
          mode: AS_STICK
        RSY:
          axis: 3
          mode: AS_STICK
      dpad: # dPad
        up: button: 12
        down: button: 13
        left: button: 14
        right: button: 15

#@endif
# end JS_MAP_GAMEPAD_MAP_COFFEE_