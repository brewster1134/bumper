###
# * bumper | responsive | breakpoint
# * https://github.com/brewster1134/bumper
# *
# * @version 2.0.0
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'bumper-core'
    ], ->
      factory()
  else
    factory()
) @, ->

  class BumperResponsiveBreakpoint

    # Sets the breakpoints.
    #
    setBreakpoints: (breakpoints) ->
      # validate object
      throw 'breakpoints must be an object' unless typeof breakpoints == 'object'

      # validate breakpoint data
      for name, data of breakpoints
        throw "breakpoint #{name} must have a min value" if data.min == undefined
        throw "breakpoint #{name} must have a max value" if data.max == undefined

      @list = breakpoints

    # Get the current breakpoint
    #
    getCurrent: ->
      width = window.innerWidth

      for name, data of @list
        if width >= data.min && width <= data.max
          return @current = name

    # Instead of using setBreakpoints, you can provide a custom method to return a breakpoint value
    # Can be helpful if you are using jRespond or something similar
    #
    setCurrentFunction: (func) ->
      throw 'Must be a function!' unless typeof func == 'function'
      @getCurrent = func

    checkBreakpointChange: ->
      currentBp = @current
      return false if @getCurrent() == currentBp

      # trigger event
      bp = {}
      bp[@current] = @list[@current]
      event = new CustomEvent 'bumper-responsive-breakpoint-change',
        detail: bp
      window.dispatchEvent event

  window.Bumper ||= {}
  window.Bumper.Responsive ||= {}
  window.Bumper.Responsive.Breakpoint ||= new BumperResponsiveBreakpoint
