_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
markdown = require 'marked'
path = require 'path'
shell = require 'shelljs'

module.exports = (config) ->
  BumperHelpers = require(path.join(config.rootPath, 'lib', 'helpers')) config

  class Helper extends BumperHelpers
    config: config

    # Build a single string from multiple strings
    # @arg {...String} strings - 1 or more strings to be concatenated
    # @return {String} Full title
    #
    buildTitle: (strings...) -> _.compact(strings).join(': ')


    # => DEMO
    # ---

    # Get path to a specific lib directory
    # @arg {String} libName - Name of a library
    # @return {String} Path to the library
    #
    demoGetLibPath: (libName) ->
      path.join 'user', 'libs', libName

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
          demo: @demoGetDemoHtml libName

          # documentation
          docs: @demoGetDocsHtml libName

          # test report
          test: @demoGetTestHtml libName

          # js demo file path
          js: "/#{libName}.js"

      return libs

    # Renders the demo for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib demo
    #
    demoGetDemoHtml: (libName) ->
      compiledHtml = null

      for engine in config.demo.engines.html
        libFilePath = path.join @demoGetLibPath(libName), "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.demo.data[libName], (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    # Renders the documentation for a given library
    # @arg {String} libName - Name of a library
    # @return {String} Raw html of lib documentation
    #
    demoGetDocsHtml: (libName) ->
      compiledHtml = null

      for engine in config.demo.engines.html
        libFilePath = path.join @demoGetLibPath(libName), "#{libName}_docs.#{engine}"

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
    demoGetTestHtml: (libName) ->
      return false unless config.demo.tests

      jestConfigFile = path.join 'jest.js'
      testReportFile = path.join '.tmp', 'demo', 'test-results.html'

      # interpolate the test
      @interpolateFile path.join('.tmp', 'demo', "#{libName}_test.js"), config.demo.data[libName]

      # run the test
      shell.exec "yarn run jest --silent --config='#{jestConfigFile}' --testMatch='**/.tmp/demo/#{libName}_test.js'"

      # get the test results
      fs.readFileSync testReportFile, 'utf8'

  return new Helper
