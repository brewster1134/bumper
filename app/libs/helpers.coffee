_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
path = require 'path'

module.exports = (config) ->
  class Helper
    # GLOBAL
    #
    isProd: process.env.NODE_ENV == 'production'
    rootPath: config.env.rootPath

    # Build a single string from multiple strings
    # @param strings [String] String(s) to be concatenated
    # @return [String]
    #
    buildTitle: (strings...) ->
      _.compact(strings).join(': ')

    # ROUTES
    # -> LIBS
    #

    # Builds libs object required for the libs route
    # @param libNames [Array|String] Array of lib names
    # @return [Object]
    #
    buildLibsObject: (libNames) ->
      libs = new Object

      for libName in libNames
        lib = libs[libName] =
          js: "/#{libName}_demo.js"
          template: @includeDemoHtml libName

      return libs

    # Renders the demo for a given library
    # @param libName [String] The name of the library
    # @return [String] Raw html
    #
    includeDemoHtml: (libName) ->
      rawFile = null
      libRootPath = path.join @rootPath, 'libs', libName

      for engine in config.app.engines.html
        libFilePath = path.join libRootPath, "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.libs[libName] || {}, (err, html) ->
            rawFile = err || html
          return rawFile

  return new Helper
