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

    # Find an element on the page to use it's attributes as responsive data
    #
    getElementData: (string, rootEl) ->
      $rootEl = $(rootEl)

      # regex to match the convention:
      # {selector:method,arg:option=value,foo=bar}
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
        $element = $rootEl.closest("#{stringSelector}")

        # find first matching elemnt anywhere in the dom
        if options.parents == false && !$element.length
          $element = $("#{stringSelector}").first()

        # use the nearest visible parent as a last resort
        $element = $rootEl.parent().closest(':visible') unless $element.length

        throw new Error "No element found for `#{stringSelector}`." unless $element.length

        # convert special value types
        # typically options passed in the string will want to be boolean (e.g. true vs 'true')
        for arg, index in stringArgs
          stringArgs[index] = window.Bumper.Core.castType(arg)

        # call methods to request data
        value = $element[stringMethod](stringArgs...)

        # call custom function if it exists
        value = $element.data('bumper-dom-function')?(value) || value

        # replace inteprolation syntax with value
        string = string.replace match, value

      return string

  window.Bumper ||= {}
  if window.Bumper.Dom?
    console.warn 'There is already a dom handler loaded. It will be replaced by the jQuery handler', window.Bumper.Dom
  window.Bumper.Dom = new BumperDom
