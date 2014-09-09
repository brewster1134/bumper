$ ->
  $(window).resize ->
    breakpoint = if $(window).innerWidth() <= 800 then 'mobile' else 'desktop'

    Bumper.Responsive.BackgroundImage.resizeAll breakpoint
    Bumper.Responsive.Image.resizeAll breakpoint

  $(window).trigger 'resize'
