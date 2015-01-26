###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
# * @version 2.0.0
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [], ->
      factory()
  else
    factory()
) @, ->

  class BumperCore
    # process inital images
    events: ->
      # process all modules on page load
      window.onload = => @process()

      # process all modules on breakpoint changes
      window.addEventListener 'bumper-responsive-breakpoint-change', => @process()

      # check for breakpoint changes on window resize
      window.onresize = requestAnimationFrame ->
        window.Bumper.Responsive.Breakpoint.checkBreakpointChange()

    # Creates a mutation observor for bumper modules when new elements are added to the dom
    # Register a module into the switch statement with how to handle the new element
    #
    watch: ->
      # http://caniuse.com/#feat=mutationobserver
      #
      responsiveObserver = new MutationObserver (mutations) ->
        # return unless window.Bumper
        for mutation in mutations
          for node in mutation.addedNodes
            return if typeof node.className != 'string'
            switch
              when node.className.indexOf('bumper-responsive-image') > -1
                window.Bumper.Responsive.Image.resize node

      responsiveObserver.observe document,
        childList: true
        subtree: true

    process: ->
      images = document.querySelectorAll '.bumper-responsive-image'
      for image in images
        window.Bumper.Responsive.Image.resize image

    # Gets the full url based on bumper data attributes
    #
    getUrl: (el, breakpoint) ->
      url = el.getAttribute("data-bumper-responsive-image-url-#{breakpoint}") ||
            el.getAttribute('data-bumper-responsive-image-url')
      params = el.getAttribute("data-bumper-responsive-image-url-params-#{breakpoint}") ||
               el.getAttribute('data-bumper-responsive-image-url-params')

      # Log warning if no url is defined
      throw "data-bumper-responsive-image-url[-#{breakpoint}] is not set." unless url

      fullUrl = if params
        "#{url}?#{params}"
      else
        url

      # detect if inteprolation is needed
      if fullUrl.indexOf('{') > -1
        if window.Bumper.Dom
          fullUrl = window.Bumper.Dom.interpolateElementAttrs fullUrl, el
        else
          if el.className.indexOf 'bumper-responsive-image-delay' == -1
            el.className = "#{el.className} bumper-responsive-image-delay"
          return

      return fullUrl

  window.Bumper ||= {}
  window.Bumper.Core ||= new BumperCore
