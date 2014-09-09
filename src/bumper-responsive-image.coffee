###
# * bumper | responsive | image
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
      'bumper-core'
    ], ($, BumperCore) ->
      factory $, BumperCore
  else
    root.Bumper.Responsive.Image = factory jQuery, root.Bumper.Core
) @, ($, BumperCore) ->

  class BumperResponsiveImage extends BumperCore

    # resize the image for a single jquery img
    #
    resize: ($img, breakpoint) ->
      url = $img.attr("data-bumper-responsive-image-url-#{breakpoint}") ||
            $img.attr('data-bumper-responsive-image-url')

      unless url
        console.warn "data-bumper-responsive-image-url[-#{breakpoint}] is not set.", $img
        return

      defaultParams = $img.attr('data-bumper-responsive-image-url-params')
      bpParams = $img.attr("data-bumper-responsive-image-url-params-#{breakpoint}")

      # prepare image source
      params = @combineParams defaultParams, bpParams
      src = @interpolateElementAttrs "#{url}#{params}"

      # trigger event
      $img.load ->
        $img.trigger 'bumper.responsive.image.loaded'
      $img.attr 'data-bumper-breakpoint', breakpoint
      $img.attr 'src', src

    # resize all matching elements
    #
    resizeAll: (breakpoint) ->
      _this = @
      $('.bumper-responsive-image').each -> _this.resize($(@), breakpoint)

  new BumperResponsiveImage
