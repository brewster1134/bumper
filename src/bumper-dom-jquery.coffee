###
# * bumper | dom | jquery
# * https://github.com/brewster1134/bumper
# *
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
  else if typeof exports != 'undefined'
    module.exports = factory jQuery
  else
    factory jQuery
) @, ($) ->

  class BumperDom extends window.Bumper.Core.Module
    # default options
    options:
      parents: false  # when set to true, searching for elements will be restricted to the parent chain of a root element

    # Get data associated with an element given the string interpolation syntax
    # {selector:method,arg:option=value,foo=bar}
    #
    # @param string [String]
    #   A string that may contain the above interpolation syntax
    # @param rootEl [String/jQuery] (optional)
    #   A jQuery object or a css selector for a root element to search from
    #
    #
    getElementData: (string, rootEl) ->
      $rootEl = $(rootEl)

      # regex to match the convention:
      regex = /\{([^&]+)\}/g

      # extract matches from string
      matches = string.match regex

      # return original string if no interpolation is found
      return string unless matches

      # in case there are multiple matches to interpolate, process each one individually
      for match in matches
        # extract data from string
        stringArray = match.replace(/[{}]/g, '').split ':'
        stringSelector = stringArray[0]
        stringMethodArgs = stringArray[1]
        stringOptions = stringArray[2]

        # extract options into js object
        stringOptionsObject = {}
        if stringOptions
          for option in stringOptions.split(',')
            keyValue = option.split('=')
            key = keyValue[0].trim()
            value = keyValue[1].trim()
            stringOptionsObject[key] = window.Bumper.Core.castType(value)

        # merge options into defaults
        options = $.extend {}, @options, stringOptionsObject

        # extract method and arguments
        stringArgs = stringMethodArgs.split ','

        # use the first arg as the method name
        stringMethod = stringArgs.shift()

        # find match within element's parent chain
        $element = $rootEl.parent().closest("#{stringSelector}")

        # find first matching element anywhere in the dom
        if options.parents == false && !$element.length
          $element = $("#{stringSelector}").first()

        # use the nearest visible parent as a last resort with the root element
        $element = $rootEl.parent().closest(':visible') unless $element.length

        # use the body tag as a LAST last resort
        $element = $('body') unless $element.length

        # convert special value types
        # typically options passed in the string will want to be boolean (e.g. true vs 'true')
        for arg, index in stringArgs
          stringArgs[index] = window.Bumper.Core.castType(arg)

        # call methods to request data
        value = $element[stringMethod](stringArgs...)

        # create data object with details to pass custom functions
        matchData =
          element: $element
          selector: stringSelector
          method: stringMethod
          arguments: stringArgs
          options: options

        # call custom function on target element (if it exists)
        value = $element.data('bumper-dom-function')?(value, matchData) || value

        # call custom function on root element (if it exists)
        value = $rootEl.data('bumper-dom-function')?(value, matchData) || value

        # replace inteprolation syntax with value
        string = string.replace match, value

      return string

  window.Bumper ||= {}
  if window.Bumper.Dom?
    console.warn 'There is already a dom handler loaded. It will be replaced by the jQuery handler', window.Bumper.Dom
  window.Bumper.Dom = new BumperDom
