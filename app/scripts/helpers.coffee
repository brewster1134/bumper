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
    isProd: process.env.NODE_ENV == 'production'
    rootPath: config.env.rootPath

    # Build a single string from multiple strings
    # @param strings [String] String(s) to be concatenated
    # @return [String]
    #
    buildTitle: (strings...) -> _.compact(strings).join(': ')


    # => LIBS
    # ---
    libsGetPaths: ->
      libsDir = path.join @rootPath, 'user', 'libs'
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
    libsGetPath: (libName) ->
      path.join @rootPath, 'user', 'libs', libName

    # Builds libs object required for the libs route
    # @param libNames [Array<String>] Array of lib names
    # @return [Object]
    #
    libsBuildObject: (libNames, request) ->
      libs = new Object

      for libName in libNames
        libs[libName] =

          # js demo file path
          js: "/#{libName}.js"

          # demo html
          demo: @libsRenderDemoHtml libName

          # documentation
          docs: @libsRenderDocsHtml libName

          # test report
          test: await @libsRenderTestHtml libName, request

      return libs

    # Renders the demo for a given library
    # @param libName [String] Name of a library
    # @return [String] Raw html
    #
    libsRenderDemoHtml: (libName) ->
      compiledHtml = null

      for engine in config.app.engines.html
        libFilePath = path.join @libsGetPath(libName), "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.libs[libName] || {}, (err, html) ->
            compiledHtml = html unless err
          break

      return compiledHtml

    # Renders the documentation for a given library
    # @param libName [String] Name of a library
    # @return [String] Raw html
    #
    libsRenderDocsHtml: (libName) ->
      compiledHtml = null

      for engine in config.app.engines.html
        libFilePath = path.join @libsGetPath(libName), "#{libName}_docs.#{engine}"

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
    libsRenderTestHtml: (libName, request) ->
      return false unless config.env.tests

      jestConfigFile = path.join @rootPath, 'jest.js'
      testReportFile = path.join @rootPath, '.tmp', 'test-report.html'

      # run the test
      shell.exec "yarn run jest --config='#{jestConfigFile}' --testMatch '**/.tmp/#{libName}_test.js'"

      # get the test results
      fs.readFileSync testReportFile, 'utf8'

  return new Helper
