_ = require 'lodash'
chalk = require 'chalk'
fs = require 'fs'
path = require 'path'

module.exports = (config) ->
  class Helpers
    constructor: ->
      @libs ||= @_getLibs()

    # log a formatted message
    # @arg message {String} the message to log
    # @arg type {String} the type of message to log
    #
    logMessage: (message, type) ->
      switch type
        when 'error', 'fail'
          console.log chalk.red "\n=> #{message.toUpperCase()} <=\n"
        when 'info', 'warning'
          console.log chalk.yellow "\n=> #{message.toUpperCase()} <=\n"
        when 'success', 'pass'
          console.log chalk.green "\n=> #{message.toUpperCase()} <=\n"
        else
          console.log message

    # get the source file for a given lib
    # @arg lib {String} the name of a lib
    # @return {String} absolute path to lib source
    #
    getLibSourceFile = (lib) ->
      glob(path.join('user', 'libs', lib, "#{lib}.js"),
        path.join('user', 'libs', lib, "#{lib}.coffee"))[lib]

    # get all lib names
    # @return {String[]} array of all lib names
    #
    _getLibs: ->
      libsDir = path.join 'user', 'libs'
      libsDirEntries = fs.readdirSync libsDir
      libs = new Array

      # check libs directory for all subdirectories
      for entry in libsDirEntries
        if fs.statSync(path.join(libsDir, entry)).isDirectory()
          libs.push entry

      return libs

    # interpolate template placeholders with values
    # @arg filePath {String} full path to a file
    # @arg locals {Object} locals object with key/value pairs of placeholders and values
    # @return {Object} full path to the interpolated file
    #
    interpolateFile: (filePath, locals) ->
      # use mustache style interpolation
      _.templateSettings.interpolate = /{{([\s\S]+?)}}/g

      # read the test file
      contents = fs.readFileSync filePath

      # create and interpolate the file
      try
        compiled = _.template contents
        interpolated = compiled locals
      catch er
        interpolated = contents

      # write back to the same file
      fs.writeFileSync filePath, interpolated

      return
        file: filePath
        contents: interpolated


    # => CLI
    # ---
    # assemble all data into each lib data
    # @arg originalData {Object} data to inject into each lib data
    # @return {Object} object with original data for each lib
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
    # @arg command {String} name of command
    # @arg argsData {Object} data passed from cli
    # @return {Object} object with full data for each lib
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
