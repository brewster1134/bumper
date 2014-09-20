###
# * bumper | responsive | image
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
      'bumper-responsive-breakpoint'
    ], ->
      factory()
  else
    factory()
) @, ->

  class BumperResponsiveImage

    # resize the image for a single jquery element
    #
    resize: (el, breakpoint) ->
      el = el[0] if el.jquery # convert from a jquery object
      breakpoint ||= window.Bumper.Responsive.Breakpoint.getCurrent()
      fullUrl = window.Bumper.Core.getUrl el, breakpoint

      return unless fullUrl

      # handle images
      #
      if el.tagName == 'IMG'
        img = el
        # trigger event
        img.addEventListener 'load', ->
          event = new Event 'bumper-responsive-image-loaded'
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

          event = new CustomEvent 'bumper-responsive-image-loaded',
            detail:
              img: img
          el.dispatchEvent event

        img.setAttribute 'src', fullUrl

      return fullUrl

  window.Bumper ||= {}
  window.Bumper.Responsive ||= {}
  window.Bumper.Responsive.Image ||= new BumperResponsiveImage
