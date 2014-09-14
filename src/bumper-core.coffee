###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
# * @version 1.0.2
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

    interpolateElementAttrs: (string, $rootEl) ->
      regex = /\{([^&]+)\}/g
      matches = string.match /\{([^&]+)\}/g
      return string unless matches

      for match in matches
        # extract each interpolation declaration
        splitArray = match.replace(/[{}]/g, '').split ':'

        # find first match within elements parents
        $elements = if $rootEl then $rootEl.closest("#{splitArray[0]}") else $()

        # add any matching elements anywhere on the dom
        $elements = $elements.add("#{splitArray[0]}")

        unless $elements.length
          console.warn "No element for `#{splitArray[0]}` found."
          return

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

        string = string.replace match, $elements.first()[method](args...)

      string
