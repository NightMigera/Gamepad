#@ifndef JS_MAP_GAMEPAD_MAP_COFFEE_
#@define JS_MAP_GAMEPAD_MAP_COFFEE_

#@include "../sys.coffee"

class GamepadMap
  vendor: ""
  product: ""
  platform: "linux"
  activeMap: null

  @platformDetect = ->
    isLinux = /linux/i
    isMac = /mac/i
    isWindows = /window/i
    platform = navigator.platform
    if isLinux.test platform
      "linux"
    else if isMac.test platform
      "mac"
    else if isWindows.test platform
      "windows"
    else
      WARN "Mobile or other not supported platform"
      "other"

  constructor: (vendor, product, platform, overideMap = null) ->
    unless isString(vendor) and vendor.length is 4 and /[a-f0-9]/i.test(vendor)
      ERR "GamepadMap: vendor incorrect: #{vendor}"
      return
    unless isString(product) and product.length is 4 and /[a-f0-9]/i.test(product)
      ERR "GamepadMap: product incorrect: #{product}"
      return
    @vendor = vendor.toLowerCase()
    @product = product.toLowerCase()
    @platform = platform or GamepadMap.platformDetect()
    @activeMap = @loadMap()
    if overideMap?
      merge @activeMap, overideMap

  loadMap: ->
    index = @vendor + @product
    unless isString(index) and index.length is 8 and /[a-f0-9]/.test(index)
      ERR "GamepadMap: in map changed vendor or product and he incorrect"
      return

    defaultMap = @other["00000000"]
    return defaultMap if index is "00000000"

    mapsByPlatform = @[@platform]
    unless mapsByPlatform?
      WARN "GamepadMap: platform #{@platform} not supported. Use default map."
      return defaultMap

    unless mapsByPlatform.hasOwnProperty(index)
      WARN "GamepadMap: vendor #{@vendor} or product #{@product} not supported. Use default map."
      return defaultMap

    map = mapsByPlatform[index]
    if isString map
      if mapsByPlatform.hasOwnProperty map
        return overlay defaultMap, mapsByPlatform[map]
      WARN "GamepadMap: index #{index} of map not avialable."
      return defaultMap

    return overlay(defaultMap, map) or defaultMap

  #@include "linux.coffee"

  other:
    "example": # example only
      blockName: # name block of gamepad from based: dpad, lrtb, menu, axes, face.
        buttonName: # maybe any name
          button: 0 # num button in array
          asAxis: false # if value is float and need evented it, must be true
          axis: null # optional, if by default buttonName is axis, but need button (LSX, LSY, RSX, RSY only)
        axisName:
          axis: 0 # num of axis in array
          # GAMEPAD_AXIS_AS_STICK -- only stick width change event,
          # GAMEPAD_AXIS_AS_BUTTON -- only button events,
          # GAMEPAD_AXIS_AS_COMBINED -- dual mode: change deect change value, other: button pressed
          mode: GAMEPAD_AXIS_AS_COMBINED # mode detect and work axis.
          # Detect button press when value great then triggerValue, or less then?
          positive: true # need not AS_STICK mode. Optional. Default = true.
          triggerValue: 127 # need not AS_STICK mode. Optional. Default 127.
    # base default config
    "00000000":
      face:
        PR: button: 0 # primary
        SC: button: 1 # secondary
        TR: button: 2 # tertiary
        QT: button: 3 # quaternary
      lrtb: # shouldersTriggers
        LB: button: 4 # leftShoulder  # L1
        RB: button: 5 # rightShoulder # R1
        LT:
          button: 6 # leftTrigger   # L2
          asAxis: true
        RT:
          button: 7 # rightTrigger  # R2
          asAxis: true
      menu:
        back: button: 8 # select
        start: button: 9 # forvard
        home: button: 16 # meta
      axes:
        LSB: button: 10 # leftStickButton
        LSX:
          axis: 0
          mode: AS_STICK_VAL
        LSY:
          axis: 1
          mode: AS_STICK_VAL
        RSB: button: 11 # rightStickButton
        RSX:
          axis: 2
          mode: AS_STICK_VAL
        RSY:
          axis: 3
          mode: AS_STICK_VAL
      dpad: # dPad
        up: button: 12
        down: button: 13
        left: button: 14
        right: button: 15

#@endif
# end JS_MAP_GAMEPAD_MAP_COFFEE_