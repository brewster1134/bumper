###
# * bumper | responsive | images | background
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
    ], ($) ->
      factory $
  else
    window.Bumper.Responsive.BackgroundImage = factory jQuery
) @, ($) ->

  # resize the background image for a single jquery object
  #
  resizeEl: ($el, breakpoint) ->
    url = $el.attr("data-bumper-responsive-backgroundimage-url-#{breakpoint}") ||
      $el.attr('data-bumper-responsive-backgroundimage-url')

    unless url
      console.warn "data-bumper-responsive-backgroundimage-url[-#{breakpoint}] is not set.", $el
      return

    defaultParams = $el.attr('data-bumper-responsive-backgroundimage-url-params')
    bpParams = $el.attr("data-bumper-responsive-backgroundimage-url-params-#{breakpoint}")

    # remove empty values and create url paramaters
    params = [defaultParams, bpParams].filter (n) -> n != undefined && n != null && n != ''
    params = if params.length then "?#{params.join('&')}" else ''

    # create a temp image tag so we can fire an event when the image is loaded
    $img = $('<img/>')
    $img.load ->
      $el.attr 'data-bumper-breakpoint', breakpoint
      $el.css
        backgroundImage: "url(#{$(@).attr('src')})"

      $el.trigger 'bumper.responsive.backgroundimage.loaded'
    $img.attr 'src', "#{url}#{params}"

  # resize all matching elements
  #
  resizeAll: (breakpoint) ->
    _this = @
    $('.bumper-responsive-backgroundimage').each -> _this.resizeEl($(@), breakpoint)
