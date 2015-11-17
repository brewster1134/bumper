###
# * bumper core
# * https://github.com/brewster1134/bumper
# *
# * @author Ryan Brewster
# * Copyright (c) 2014
# * Licensed under the MIT license.
###

((factory) ->
  if define.amd
    define [], ->
      factory()
  else
    factory()
) ->

  class BumperCore
    # Maintain bumper version here...
    version: '3.1.2'

    # convert strings into a given javascript class type
    #
    castType: (string, type) ->
      if type
        switch type
          when 'boolean'
            switch string
              when 'true' then true
              when 'false' then false
          when 'integer'
            parseInt string
          when 'float'
            parseFloat string
          else
            string

      # attempt detection if no type is passed
      else
        switch string
          when 'true' then true
          when 'false' then false
          else string

    # default global options object
    Options: {}

    # expose Module class to easily extend modules with
    #
    Module: class BumperModule
      # default options object
      options: {}

      constructor: ->
        # turn the class name into an array of class namespaces
        # e.g. BumperFooBar => ['Foo', 'Bar']
        names = @constructor
          .name
          .replace /([A-Z])/g, ($1) ->
            return '.' + $1
          .replace /^\.Bumper\./, ''
          .split '.'

        # setup global options object
        namespace = window.Bumper.Core.Options
        for name in names
          # assign the options to the last namespace
          value = if name == names.slice(-1)[0] then @options else {}
          namespace = namespace[name] ||= value

      # api to assign options to a module
      #
      setOption: (option, value) ->
        @options[option] = value

  window.Bumper ||= {}
  window.Bumper.Core ||= new BumperCore
