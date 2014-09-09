###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
# * @version 0.1.0
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'jquery'
    ], ($) ->
      factory $
  else
    root.Bumper ||= {}
    root.Bumper.Responsive ||= {}
    root.Bumper.Core = factory jQuery
) @, ($) ->

  # return the class so bumper modules can extend it
  #
  class BumperCore

    # remove empty values and create url paramaters
    #
    combineParams: (params...) ->
      paramArray = params.filter (p) -> !!p
      if paramArray.length then "?#{paramArray.join('&')}" else ''

    interpolateElementAttrs: (string) ->
      regex = /\{([^&]+)\}/g
      matches = string.match /\{([^&]+)\}/g
      return string unless matches

      for match in matches
        # extract each interpolation declaration
        splitArray = match.replace(/[{}]/g, '').split ':'

        # find element in dom
        element = $("##{splitArray[0]}")

        # extract comma separated method and arguments
        args = splitArray[1].split ','

        # use the first arg as the method
        method = args.shift()

        # convert special value types
        for arg, index in args
          newArg = switch arg
            when 'true' then true
            when 'false' then false
            else arg
          args[index] = newArg

        string = string.replace match, element[method](args...)

      string
