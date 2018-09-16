_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
markdown = require 'marked'
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

    getLibPath: (libName) ->
      path.join @rootPath, 'libs', libName

    # Builds libs object required for the libs route
    # @param libNames [Array|String] Array of lib names
    # @return [Object]
    #
    buildLibsObject: (libNames) ->
      libs = new Object

      for libName in libNames
        lib = libs[libName] =

          # js demo file path
          js: "/#{libName}_demo.js"

          # demo html
          demo: @renderDemoHtml libName

          # documentation
          docs: @renderDocsHtml libName

      return libs

    # Renders the demo for a given library
    # @param libName [String] The name of the library
    # @return [String] Raw html
    #
    renderDemoHtml: (libName) ->
      compiledHtml = null

      for engine in config.app.engines.html
        libFilePath = path.join @getLibPath(libName), "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.libs[libName] || {}, (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    renderDocsHtml: (libName) ->
      compiledHtml = null

      for engine in config.app.engines.html
        libFilePath = path.join @getLibPath(libName), "#{libName}_docs.#{engine}"

        if fs.existsSync libFilePath
          fileContents = fs.readFileSync libFilePath, 'utf8'

          switch engine
            when 'md'
              compiledHtml = markdown fileContents,
                breaks: true
                gfm: true

          break

      return compiledHtml

  return new Helper
