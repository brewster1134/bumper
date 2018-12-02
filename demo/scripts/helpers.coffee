_ = require 'lodash'
async = require 'async'
consolidate = require 'consolidate'
fs = require 'fs'
http = require 'http'
markdown = require 'marked'
path = require 'path'
shell = require 'shelljs'

module.exports = (config) ->
  class Helper

    # => GLOBAL
    # ---
    config: config
    isProd: process.env.NODE_ENV == 'production'

    # Build a single string from multiple strings
    # @param strings [String] String(s) to be concatenated
    # @return [String]
    #
    buildTitle: (strings...) -> _.compact(strings).join(': ')


    # => DEMO
    # ---
    # Get all lib names
    # @return [Array<String>] Array of lib names
    #
    demoGetLibs: ->
      libsDir = path.join 'user', 'libs'
      libsDirEntries = fs.readdirSync libsDir
      libs = new Array

      # check libs directory for all subdirectories
      for entry in libsDirEntries
        if fs.statSync(path.join(libsDir, entry)).isDirectory()
          libs.push entry

      return libs

    # Get path to a specific lib directory
    # @param libName [String] Name of a library
    # @return [String] Absolute path to the library
    #
    demoGetLibPath: (libName) ->
      path.join 'user', 'libs', libName

    # Builds libs object required for the libs route
    # @param libNames [Array<String>] Array of lib names
    # @return [Object]
    #
    demoBuildLibObject: (libNames) ->
      libs = new Object

      for libName in libNames
        libs[libName] =

          # js demo file path
          js: "/#{libName}.js"

          # demo html
          demo: @demoGetDemoHtml libName

          # documentation
          docs: @demoGetDocsHtml libName

          # test report
          test: @demoGetTestHtml libName

      return libs

    # Renders the demo for a given library
    # @param libName [String] Name of a library
    # @return [String] Raw html
    #
    demoGetDemoHtml: (libName) ->
      compiledHtml = null

      for engine in config.demo.engines.html
        libFilePath = path.join @demoGetLibPath(libName), "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.libs[libName] || {}, (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    # Renders the documentation for a given library
    # @param libName [String] Name of a library
    # @return [String] Raw html
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
    # @param libName [String] Name of a library
    # @return [String] Raw html
    #
    demoGetTestHtml: (libName) ->
      return false unless config.demo.tests

      jestConfigFile = path.join 'jest.js'
      testReportFile = path.join '.tmp', 'test-report.html'

      # run the test
      shell.exec "yarn run jest --silent --config='#{jestConfigFile}' --testMatch '**/.tmp/#{libName}_test.js'"

      # get the test results
      fs.readFileSync testReportFile, 'utf8'

  return new Helper
