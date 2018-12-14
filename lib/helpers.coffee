_ = require 'lodash'
fs = require 'fs'
path = require 'path'

module.exports =
  class Helpers
    constructor: ->
      @libs = @getLibs()

    # get all lib names
    # @return {String[]} Array of all lib names
    #
    getLibs: ->
      libsDir = path.join 'user', 'libs'
      libsDirEntries = fs.readdirSync libsDir
      libs = new Array

      # check libs directory for all subdirectories
      for entry in libsDirEntries
        if fs.statSync(path.join(libsDir, entry)).isDirectory()
          libs.push entry

      return libs


    # => CLI
    # ---
    # assemble all data into each lib data
    # @arg originalData {Object} Data to inject into each lib data
    # @return {Object} Object with original data for each lib
    #
    addGenericDataToLibs: (originalData) ->
      libData = new Object
      nonLibData = new Object

      # create skeleton of lib
      for lib in @libs
        libData[lib] = new Object

      # separate non-lib data
      for key, value of originalData
        if @libs.includes key
          libData[key] = value
        else
          nonLibData[key] = value

      # merge non-lib data into each lib's data
      for lib, value of libData
        libData[lib] = _.merge new Object, nonLibData, libData[lib]

      return libData

    # build the data object
    # @arg command {String} Name of command
    # @arg argsData {Object} Data passed from cli
    # @return {Object} Object with full data for each lib
    #
    buildDataObject: (configFile, command, argsData) ->
      libData = new Object

      # create skeleton of lib
      for lib in @libs
        libData[lib] = new Object

      # merge in root data into libs
      if configFile.data
        _.merge libData, @addGenericDataToLibs(configFile.data)

      # merge in command specific data into libs
      if configFile[command]?.data
        _.merge libData, @addGenericDataToLibs(configFile[command].data)

      # merge cli data into libs
      if argsData
        for lib, value of libData
          _.merge libData[lib], argsData

      return libData


    # => TEST
    # ---
