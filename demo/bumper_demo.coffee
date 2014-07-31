$ ->
  $(window).resize ->
    breakpoint = if $(window).innerWidth() <= 800
      'mobile'
    else
      'desktop'

    Bumper.Responsive.Image.Background.resizeAll breakpoint

  $(window).trigger 'resize'
