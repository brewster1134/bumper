_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
jest = require 'jest'
markdown = require 'marked'
path = require 'path'

module.exports = (config) ->
  BumperHelpers = require(path.join(config.rootPath, 'lib', 'helpers')) config

  class Helper extends BumperHelpers
    # => GLOBAL
    # ---
    config: config

    # Build a single string from multiple strings
    # @arg {...String} strings - 1 or more strings to be concatenated
    # @return {String} Full title
    #
    buildTitle: (strings...) -> _.compact(strings).join(': ')


    # => ROUTE:DEMO
    # ---

    # Builds libs object required for the libs route
    # @arg {...String} libNames - lib names
    # @return {Object} Object of all data needed to render the demo page
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

    # Get path to a specific lib directory
    # @arg {String} libName - Name of a library
    # @return {String} Path to the library
    #
    _demoGetLibPath: (libName) ->
      path.join 'user', 'libs', libName

    # Renders the demo for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib demo
    #
    _demoGetDemoHtml: (libName) ->
      compiledHtml = null

      for engine in config.demo.engines.html
        libFilePath = path.join @_demoGetLibPath(libName), "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.demo.data[libName], (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    # Renders the documentation for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib documentation
    #
    _demoGetDocsHtml: (libName) ->
      compiledHtml = null

      for engine in config.demo.engines.html
        libFilePath = path.join @_demoGetLibPath(libName), "#{libName}_docs.#{engine}"

        if fs.existsSync libFilePath
          fileContents = fs.readFileSync libFilePath, 'utf8'

          switch engine
            when 'md'
              compiledHtml = markdown fileContents,
                breaks: true
                gfm: true

          break

      return compiledHtml

    # Renders the test results
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib test results
    #
    _demoGetTestHtml: (libName) ->
      return false unless config.demo.tests

      jestConfigFile = path.join 'jest.js'
      testReportFile = path.join '.tmp', 'demo', 'test-results.html'

      # interpolate the test
      @interpolateFile path.join('.tmp', 'demo', "#{libName}_test.js"), config.demo.data[libName]

      # run the test
      await jest.run("--detectOpenHandles --config='#{jestConfigFile}' --testRegex='\.tmp\/demo\/(#{libName})_test\.js$'").then ->
        fs.readFileSync testReportFile, 'utf8'

  return new Helper
