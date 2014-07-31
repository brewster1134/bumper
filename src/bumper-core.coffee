###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
# * @version 0.0.1
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((root, factory) ->
  if typeof define == 'function' && define.amd
    define [], ->
      factory()
  else
    factory()
) @, ->

  # Create empty bumper object
  window.Bumper =
    Responsive:
      Image:
        Background: null
