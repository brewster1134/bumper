_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
globEntries = require 'webpack-glob-entry'
markdown = require 'marked'
path = require 'path'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports = (config) ->
  BumperHelpers = require "#{config.bumperPath}/lib/helpers"

  class Helper extends BumperHelpers
    constructor: (@config) ->
      super config.verbose

    # Build a single string from multiple strings
    # @arg {...String} strings - 1 or more strings to be concatenated
    # @return {String} Full title
    #
    buildTitle: (strings...) -> _.compact(strings).join(': ')

    # Builds lib object required for the lib route
    # @arg {...String} libNames - lib names
    # @return {Object} Object of all globals needed to render the demo page
    #
    demoBuildLibObject: (libNames...) ->
      libs = new Object

      for libName in libNames
        libs[libName] =
          # css demo file path
          css: "/#{libName}.css"

          # demo html
          demo: @_demoGetDemoHtml libName

          # documentation
          docs: @_demoGetDocsHtml libName

          # test report
          test: await @_demoGetTestHtml libName

          # js demo file path
          js: "/#{libName}.js"

      return libs

    # Interpolate template placeholders with values
    # @arg {String} filePath - full path to a file
    # @arg {Object} locals - locals object with key/value pairs of placeholders and values
    # @arg {Boolean} modifyOriginal - if set to false, copy file to tmp, and modify the tmp file instead
    # @return {Object} full path to the interpolated file
    #
    _interpolateFile: (filePath, locals, modifyOriginal = false) ->
      # Use mustache style interpolation
      _.templateSettings.interpolate = /{{([\s\S]+?)}}/g

      # if tmp set, create a tmp file to interpolate rather than modify the original
      unless modifyOriginal
        fileName = path.basename filePath
        tmpFile = "#{@config.packagePath}/.tmp/demo/#{fileName}"
        fs.copySync filePath, tmpFile
        filePath = tmpFile

      # Read the test file
      contents = fs.readFileSync filePath, 'utf8'

      # Create and interpolate the file
      try
        compiled = _.template contents
        interpolated = compiled locals
      catch er
        interpolated = contents

      # Write back to the same file
      fs.writeFileSync filePath, interpolated

      return
        file: filePath
        contents: interpolated

    # Get path to a specific lib directory
    # @arg {String} libName - Name of a library
    # @return {String} Path to the library
    #
    _demoGetLibPath: (libName) ->
      "#{@config.packagePath}/libs/#{libName}"

    # Renders the demo for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib demo
    #
    _demoGetDemoHtml: (libName) ->
      compiledHtml = null

      for engine in @config.formats.html
        libDemoPath = "#{@_demoGetLibPath(libName)}/#{libName}_demo.#{engine}"

        if fs.pathExistsSync libDemoPath
          consolidate[engine] libDemoPath, @config.demo.globals?[libName], (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    # Renders the documentation for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib documentation
    #
    _demoGetDocsHtml: (libName) ->
      compiledHtml = null

      for engine in @config.formats.html
        libDocsPath = "#{@_demoGetLibPath(libName)}/#{libName}_docs.#{engine}"
        tmpDocsPath = "#{@config.packagePath}/.tmp/demo/#{libName}_docs.#{engine}"

        continue unless fs.pathExistsSync libDocsPath

        # interpolate tmp file
        interpolated = @_interpolateFile tmpDocsPath, @config.demo.globals?[libName], false

        # create html
        switch engine
          when 'md'
            compiledHtml = markdown interpolated.contents,
              breaks: true
              gfm: true

        break

      return compiledHtml

    # Renders the test results
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib test results
    #
    _demoGetTestHtml: (libName) ->
      return false unless @config.demo.tests

      # create mocha instance
      Mocha = require 'mocha'
      mocha = new Mocha
        ui: 'bdd'
        reporter: 'doc'

      # add single lib test to mocha
      mocha.addFile "#{@config.packagePath}/.tmp/demo/#{libName}_test.js"

      # start write stream to html report
      htmlFile = "#{@config.packagePath}/.tmp/demo/#{libName}_test.html"
      html = fs.createWriteStream htmlFile,
        flags: 'a'

      # backup console.log
      ogLog = console.log

      # force console.log to write to file
      console.log = (data, args...) ->
        val = require('util').format(data, args...)
        html.write val
        ogLog val

      # run tests and generate reports
      await mocha.run()

      # restore console.log
      console.log = ogLog

      # return html
      return fs.readFileSync htmlFile, 'utf8'
