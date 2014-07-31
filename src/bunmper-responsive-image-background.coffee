###
# * bumper | responsive | images | background
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
    ], ->
      factory $
  else
    window.Bumper.Responsive.Image.Background = factory $
) @, ($) ->
  class ResponsiveBg
    # resize the background image for a single jquery object
    #
    resizeEl: ($el, breakpoint) ->
      url = $el.data('bumper-responsive-image-background-url')
      unless url
        console.warn 'data-bumper-responsive-image-background-url is not set on: ', $el
        return

      defaultParams = $el.data('bumper-responsive-image-background-url-params')
      bpParams = $el.data("bumper-responsive-image-background-url-params-#{breakpoint}")

      # remove empty values
      params = [defaultParams, bpParams].filter (n) ->
        return n != undefined && n != null && n != ''

      params = if params.length
        "?#{params.join('&')}"
      else
        ''

      $el.css
        backgroundImage: "url(#{url}#{params})"

    # resize all matching elements
    #
    resizeAll: (breakpoint) ->
      _this = @
      $('.responsivebg').each -> _this.resizeEl($(@), breakpoint)

  new ResponsiveBg
