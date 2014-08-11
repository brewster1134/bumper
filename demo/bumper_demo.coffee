$ ->
  $(window).resize ->
    breakpoint = if $(window).innerWidth() <= 800
      'mobile'
    else
      'desktop'

    Bumper.Responsive.Image.Background.resizeAll breakpoint

  $(window).trigger 'resize'

  $(window).on 'bumper.responsive.image.background.loaded', (e, data) ->
    console.log 'Image Loaded'
