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
    ], ($) ->
      factory $
  else
    factory jQuery
) @, ($) ->
  class ResponsiveBg

    # resize the background image for a single jquery object
    #
    resizeEl: ($el, breakpoint) ->
      url = $el.attr("data-bumper-responsive-image-background-url-#{breakpoint}") ||
        $el.attr('data-bumper-responsive-image-background-url')

      unless url
        console.warn "data-bumper-responsive-image-background-url[-#{breakpoint}] is not set.", $el
        return

      defaultParams = $el.attr('data-bumper-responsive-image-background-url-params')
      bpParams = $el.attr("data-bumper-responsive-image-background-url-params-#{breakpoint}")

      # remove empty values and create url paramaters
      params = [defaultParams, bpParams].filter (n) ->
        return n != undefined && n != null && n != ''
      params = if params.length then "?#{params.join('&')}" else ''

      # create a temp image tag so we can fire an event when the image is loaded
      $img = $('<img/>')
      $img.load ->
        $el.css
          backgroundImage: "url(#{$(@).attr('src')})"

        $(window).trigger 'bumper.responsive.image.background.loaded'
      $img.attr 'src', "#{url}#{params}"


    # resize all matching elements
    #
    resizeAll: (breakpoint) ->
      _this = @
      $('.responsivebg').each -> _this.resizeEl($(@), breakpoint)

  window.Bumper.Responsive.Image.Background = new ResponsiveBg
