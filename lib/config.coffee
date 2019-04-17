_ = require 'lodash'
chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'

Logger = require './logger.coffee'

module.exports =
  class Config
    build: ->
      global.bumper.setSharedOptionValues()

      # get npm json files
      bumperPath = path.resolve __dirname, '..'
      projectPath = process.cwd()

      # get user configuration & set it to global for checking for verbose
      configFile = @_getConfigFile projectPath
      # global.bumper.config.file = configFile

      # get package.json files
      bumperJson = @_getPackageJson bumperPath
      projectJson = @_getPackageJson projectPath

      # additional config
      name = configFile.name || projectJson.name || 'Bumper'
      jsFormats = [ 'coffee', 'js' ]

      # get package libraries
      libs = @_getLibs projectPath, jsFormats
      if !Object.keys(libs).length
        new Logger 'No valid Bumper libraries found',
          exit: 1
          type: 'error'

      # set libs option default
      global.bumper.optionDefaults.libs = Object.keys libs

      # create full config object
      config =
        bumperJson: bumperJson
        bumperPath: bumperPath
        command: global.bumper.config.command
        file: configFile
        flair: chalk.bold '------======------'
        libs: libs
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, '_'
        projectJson: projectJson
        projectPath: projectPath
        version: projectJson.version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: jsFormats

      return config

    # get user configuration
    # @arg {string} projectPath - path to bumper package
    # @return {object}
    #
    _getConfigFile: (projectPath) ->
      # look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync "#{projectPath}/config.yaml"

      # look for json file
      configFile ||= try JSON.parse fs.readFileSync "#{projectPath}/config.json"

      return configFile || {}

    # get package.json
    # @arg {string} path - absolute directory path
    # @return {object}
    #
    _getPackageJson: (path) ->
      try
        return require "#{path}/package.json"
      catch err
        new Logger 'No `package.json` found',
          type: 'alert'

    # Get all current package libraries
    # @arg {string} projectPath
    # @arg {array} formats
    # @return {object} key: library name, value: library source path
    #
    _getLibs: (projectPath, formats) ->
      libFormats = formats.join '|'
      libs = {}

      try
        files = fs.readdirSync "#{projectPath}/libs"
      catch err
        new Logger 'No `libs` directory found',
          exit: 1
          type: 'error'

      for file in files
        libGlobPath = "#{projectPath}/libs/#{file}/#{file}.+(#{libFormats})"
        libPath = glob.sync(libGlobPath)[0]

        if libPath
          libs[file] = libPath

      return libs
