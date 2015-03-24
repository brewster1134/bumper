###
# * bumper | responsive | breakpoint
# * https://github.com/brewster1134/bumper
# *
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
  else if typeof exports != 'undefined'
    module.exports = factory()
  else
    factory()
) @, ->

  class BumperResponsiveBreakpoint extends window.Bumper.Core.Module
    events: ->
      # check for breakpoint changes on window resize
      window.addEventListener 'resize', => @checkBreakpointChange()

      return @

    # Sets the breakpoints
    #
    setBreakpoints: (breakpoints) ->
      # validate object and breakpoint data
      throw new Error 'breakpoints must be an object' unless typeof breakpoints == 'object'
      for name, data of breakpoints
        throw new Error "breakpoint #{name} must have a min value" if data.min == undefined
        throw new Error "breakpoint #{name} must have a max value" if data.max == undefined

      @list = breakpoints

    # Get the current breakpoint
    #
    getCurrent: ->
      width = window.innerWidth

      for name, data of @list
        if width >= data.min && width <= data.max
          return @current = name

      return @current

    # Instead of using setBreakpoints, you can provide a custom method to return a breakpoint value
    # Can be helpful if you are using jRespond or something similar
    #
    setCurrentFunction: (func) ->
      throw new Error 'Must be a function!' unless typeof func == 'function'
      @getCurrent = func

    checkBreakpointChange: ->
      # return false if the breakpoint hasn't changed
      previousBp = @current
      return false if @getCurrent() == previousBp

      # create a small object with breakpoint data
      bp = {}
      bp[@current] = @list[@current]

      # trigger breakpoint change event
      changeEvent = new CustomEvent 'bumper-responsive-breakpoint-change',
        detail: bp
      window.dispatchEvent changeEvent

      # trigger breakpoint change increase event
      if @list[previousBp].min < @list[@current].min
        changeIncreaseEvent = new CustomEvent 'bumper-responsive-breakpoint-change-increase',
          detail: bp
        window.dispatchEvent changeIncreaseEvent

      # trigger breakpoint change decrease event
      else
        changeDecreaseEvent = new CustomEvent 'bumper-responsive-breakpoint-change-decrease',
          detail: bp
        window.dispatchEvent changeDecreaseEvent

      return bp

  window.Bumper ||= {}
  window.Bumper.Responsive ||= {}
  window.Bumper.Responsive.Breakpoint ||= new BumperResponsiveBreakpoint
