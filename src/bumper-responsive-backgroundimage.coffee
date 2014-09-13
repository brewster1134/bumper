###
# * bumper | responsive | backgroundimage
# * https://github.com/brewster1134/bumper
# *
# * @version 1.0.0
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'jquery'
      'bumper-core'
    ], ($, BumperCore) ->
      factory $, BumperCore
  else
    root.Bumper.Responsive.BackgroundImage = factory jQuery, root.Bumper.Core
) @, ($, BumperCore) ->

  class BumperResponsiveBackgroundImage extends BumperCore

    # resize the background image for a single jquery object
    #
    resize: ($el, breakpoint) ->
      url = $el.attr("data-bumper-responsive-backgroundimage-url-#{breakpoint}") ||
            $el.attr('data-bumper-responsive-backgroundimage-url')

      unless url
        console.warn "data-bumper-responsive-backgroundimage-url[-#{breakpoint}] is not set.", $el
        return

      defaultParams = $el.attr('data-bumper-responsive-backgroundimage-url-params')
      bpParams = $el.attr("data-bumper-responsive-backgroundimage-url-params-#{breakpoint}")

      # prepare image source
      params = @combineParams defaultParams, bpParams
      src = @interpolateElementAttrs "#{url}#{params}"

      # create a temp image tag so we can fire an event when the image is loaded
      $img = $('<img/>')
      $img.load ->
        $el.attr 'data-bumper-breakpoint', breakpoint
        $el.css
          backgroundImage: "url(#{$(@).attr('src')})"

        $el.trigger 'bumper.responsive.backgroundimage.loaded',
          img: $img
      $img.attr 'src', src

    # resize all matching elements
    #
    resizeAll: (breakpoint) ->
      _this = @
      $('.bumper-responsive-backgroundimage').each -> _this.resize($(@), breakpoint)

  new BumperResponsiveBackgroundImage
