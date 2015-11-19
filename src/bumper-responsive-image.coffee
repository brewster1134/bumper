###
# * bumper | responsive | image
# * https://github.com/brewster1134/bumper
# *
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((factory) ->
  if define?.amd
    define [
      'bumper-core'
      'bumper-responsive-breakpoint'
    ], (Core, ResponsiveBreakpoint) ->
      factory Core, ResponsiveBreakpoint
  else
    factory window.Bumper.Core, window.Bumper.Responsive.Breakpoint
) (Core, ResponsiveBreakpoint) ->

  class BumperResponsiveImage extends Core.Module
    events: ->
      # resize all images on page load
      window.addEventListener 'load', => @resizeAll()

      # resize all images on breakpoint change increase
      window.addEventListener 'bumper-responsive-breakpoint-change', => @resizeAll()

      # Creates a mutation observor when new elements are added to the dom
      # http://caniuse.com/#feat=mutationobserver
      responsiveObserver = new MutationObserver => @resizeAll()
      responsiveObserver.observe document,
        childList: true
        subtree: true

      return @

    # calls resize on all matching elements
    #
    resizeAll: ->
      images = document.querySelectorAll '.bumper-responsive-image'
      for image in images
        @resize image

      return images

    # set the repsonsive image and fire events
    # @param el [HTML Element] html img or div element that has responsive image data attributes
    # @param breakpoint [String] an optional name of a breakpoint (as defined from setBreakpoints)
    #
    resize: (el, breakpoint, force = false) ->
      el = el[0] if el.jquery # convert from a jquery object
      breakpoint ||= window.Bumper.Responsive.Breakpoint?.getCurrent()
      fullUrl = @getUrl el, breakpoint

      # return if no url, or url is the same as the existing url
      return false unless fullUrl
      if force == false && (el.getAttribute('src')?.indexOf(fullUrl) >= 0 || el.style.backgroundImage.indexOf(fullUrl) >= 0)
        return fullUrl

      # handle images
      #
      if el.tagName == 'IMG'
        img = el
        # trigger event
        img.addEventListener 'load', ->
          event = new CustomEvent 'bumper-responsive-image-loaded',
            detail:
              img: img
          img.dispatchEvent event

        img.setAttribute 'data-bumper-breakpoint', breakpoint
        img.setAttribute 'src', fullUrl

      # handle background images
      #
      else
        # create a temp image tag so we can fire an event when the image is loaded
        img = document.createElement 'img'
        img.addEventListener 'load', ->
          src = @getAttribute 'src'

          el.setAttribute 'data-bumper-breakpoint', breakpoint
          el.style.backgroundImage = "url(#{src})"
          el.style.width = "#{img.width}px"
          el.style.height = "#{img.height}px"

          event = new CustomEvent 'bumper-responsive-image-loaded',
            detail:
              img: img
          el.dispatchEvent event

        img.setAttribute 'src', fullUrl

      return fullUrl

    # Gets the full url based on bumper data attributes
    # @param el [HTML Element] html img or div element that has responsive image data attributes
    # @param breakpoint [String] an optional name of a breakpoint (as defined from setBreakpoints)
    #
    getUrl: (el, breakpoint = 'default') ->
      url = el.getAttribute("data-bumper-responsive-image-url-#{breakpoint}") ||
            el.getAttribute('data-bumper-responsive-image-url')
      params = el.getAttribute("data-bumper-responsive-image-url-params-#{breakpoint}") ||
               el.getAttribute('data-bumper-responsive-image-url-params')

      # Log warning if no url is defined
      throw new Error "data-bumper-responsive-image-url[-#{breakpoint}] is not set." unless url

      # preserve any params in the url value
      # best practice is to keep all url parameters out of the url attribute, but this provides fallback support for special cases
      urlParams = url.split('?')
      if urlParams.length > 1
        url = urlParams[0]
        params = if params
          "#{urlParams[1]}&#{params}"
        else
          urlParams[1]

      # combine params if they are found
      fullUrl = if params then "#{url}?#{params}" else url

      # process any possible string inteprolation
      fullUrl = window.Bumper.Dom?.getElementData(fullUrl, el) || fullUrl

      return fullUrl

  window.Bumper ||= {}
  window.Bumper.Responsive ||= {}
  window.Bumper.Responsive.Image ||= new BumperResponsiveImage
