###
# * bumper | dom | jquery
# * https://github.com/brewster1134/bumper
# *
# * @version 2.0.3
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
    factory jQuery
) @, ($) ->

  class BumperDom
    # Find an element on the page to use it's attributes as responsive data
    #
    interpolateElementAttrs: (string, rootEl) ->
      $rootEl = $(rootEl)
      regex = /\{([^&]+)\}/g
      matches = string.match /\{([^&]+)\}/g
      return string unless matches

      for match in matches
        # extract each interpolation declaration
        splitArray = match.replace(/[{}]/g, '').split ':'

        # find match within element's parent chain
        $element = $rootEl.closest("#{splitArray[0]}")

        # find first matching elemnt anywhere in the dom
        $element = $("#{splitArray[0]}").first() unless $element.length

        # use the direct parent
        $element = $rootEl.parent() unless $element.length

        throw "No element for `#{splitArray[0]}` found." unless $element.length

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

        string = string.replace match, $element[method](args...)

      string

  window.Bumper ||= {}
  if window.Bumper.Dom
    console.warn 'There is already a dom handler loaded', window.Bumper.Dom
    console.warn 'It will be replaced by the jQuery handler.'
  window.Bumper.Dom = new BumperDom