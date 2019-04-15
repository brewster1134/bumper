chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'

Logger = require './logger.coffee'

module.exports =
  class Config
    constructor: (@cli) ->

    build: ->
      # get npm json files
      bumperPath = path.resolve __dirname, '..'
      projectPath = process.cwd()

      # get user configuration & set it to global for checking for verbose
      configFile = @_getConfigFile projectPath
      global.bumper.config.file = configFile

      # check if verbose is set
      verbose = @_getVerbose()

      # get package.json files
      bumperJson = @_getPackageJson bumperPath
      projectJson = @_getPackageJson projectPath

      # additional config
      name = configFile.name || projectJson.name || 'Bumper'
      jsFormats = [ 'coffee', 'js' ]

      # get package libraries
      libs = @_getlibs projectPath, jsFormats
      if !Object.keys(libs).length
        new Logger 'No valid Bumper libraries found',
          exit: 1
          type: 'error'

      # set libs option default
      global.bumper.optionDefaults.libs = Object.keys libs

      # return all config values
      return
        bumperJson: bumperJson
        bumperPath: bumperPath
        file: configFile
        flair: chalk.bold '------======------'
        libs: libs
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, '_'
        projectJson: projectJson
        projectPath: projectPath
        verbose: verbose
        version: projectJson.version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: jsFormats

    # get user configuration
    # @arg {String} projectPath - path to bumper package
    # @return {Object}
    #
    _getConfigFile: (projectPath) ->
      # look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync "#{projectPath}/config.yaml"

      # look for json file
      configFile ||= try JSON.parse fs.readFileSync "#{projectPath}/config.json"

      return configFile || new Object

    # check all config sources for verbose flag
    # @arg {Object} configFile
    # @return {Boolean}
    #
    _getVerbose: ->
      # if verbose passed via cli
      return global.bumper.config.verbose if global.bumper.config.verbose?
      return @cli.getOptionValue null, 'verbose'

    # get package.json
    # @arg {String} path - absolute directory path
    # @return {Object}
    #
    _getPackageJson: (path) ->
      try
        return require "#{path}/package.json"
      catch err
        new Logger 'No `package.json` found',
          type: 'alert'

    # Get all current package libraries
    # @arg {String} projectPath
    # @arg {Array} formats
    # @return {Object} key: library name, value: library source path
    #
    _getlibs: (projectPath, formats) ->
      libFormats = formats.join '|'
      libs = new Object

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
