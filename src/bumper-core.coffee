###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
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

  class BumperCore
    version: '3.0.0'

  window.Bumper ||= {}
  window.Bumper.Core ||= new BumperCore
