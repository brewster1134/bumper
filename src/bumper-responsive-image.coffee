###
# * bumper | responsive | images
# * https://github.com/brewster1134/bumper
# *
# * @version 0.0.1
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [
      'jquery'
      'bumper-core'
    ], ($) ->
      factory $
  else
    window.Bumper.Responsive.Image = factory jQuery
) @, ($) ->

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

    # remove empty values and create url paramaters
    params = [defaultParams, bpParams].filter (n) -> n != undefined && n != null && n != ''
    params = if params.length then "?#{params.join('&')}" else ''

    # trigger event
    $img.load ->
      $img.trigger 'bumper.responsive.image.loaded'
    $img.attr 'data-bumper-breakpoint', breakpoint
    $img.attr 'src', "#{url}#{params}"

  # resize all matching elements
  #
  resizeAll: (breakpoint) ->
    _this = @
    $('.bumper-responsive-image').each -> _this.resize($(@), breakpoint)
