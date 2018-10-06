_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
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


    # => WEBPACK
    # ---
    webpackGetEntries: ->
      entries = [
        "#{@rootPath}/app/scripts/app.coffee"
        "#{@rootPath}/user/app/scripts/user_app.coffee"
      ]
    
      libs = @libsGetPaths()
      for lib in libs
        entries.push "#{@rootPath}/user/libs/#{lib}/#{lib}.js"
        entries.push "#{@rootPath}/user/libs/#{lib}/#{lib}.coffee"
      
      return entries


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
    libsBuildObject: (libNames) ->
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
          test: @libsRenderTestHtml libName

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
    libsRenderTestHtml: (libName) ->
      return false unless config.env.tests

      jestConfigFile = path.join @rootPath, 'jest.js'
      testReportFile = path.join @rootPath, '.tmp', 'test-report.html'
      
      # # 
      # if fs.existsSync libFilePath
      
      shell.exec "yarn run jest --config='#{jestConfigFile}' --testMatch '**/user/libs/#{libName}/#{libName}_test.js'"

      return fs.readFileSync testReportFile, 'utf8'

  return new Helper
