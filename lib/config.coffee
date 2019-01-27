_ = require 'lodash'
argv = require('yargs-parser') process.argv.slice 2
chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'

module.exports =
  class Config
    constructor: ->
      # get npm json files
      bumperPath = path.resolve __dirname, '..'
      packagePath = process.cwd()
      verbose = argv?.V? || argv?.verbose?

      # get package.json files
      bumperJson = @_getPackageJson bumperPath
      packageJson = @_getPackageJson packagePath

      # get user configuration
      configFile = @_getConfigFile packagePath

      # additional config
      name = configFile.name || packageJson.name || 'Bumper'
      jsFormats = [ 'coffee', 'js' ]

      # get package libraries
      libs = @_getlibs packagePath, jsFormats
      if !Object.keys(libs).length
        @_logMessage 'No valid Bumper libraries found', 'fail', true

      # return all config values
      return @config =
        bumperPath: bumperPath
        file: configFile
        flair: chalk.bold '------======------'
        libs: libs
        log: @_logMessage
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, '_'
        packagePath: packagePath
        verbose: verbose
        version: packageJson.version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: jsFormats

    # Log a formatted message
    # @arg {String} message - the message to log
    # @arg {String} type - the type of message to log
    # @arg {Error|Boolean} exception, or true to use message as exception
    # @arg {Boolean} verbose - log additional information
    #
    _logMessage: (message, type, exception, verbose) ->
      isVerbose = verbose || @config?.verbose

      # log based on message type
      switch type
        when 'error', 'fail'
          console.error chalk.red "\n=> #{message} <=\n"
        when 'alert', 'info', 'warning'
          console.warn chalk.yellow "\n=> #{message} <=\n"
        when 'success', 'pass'
          console.log chalk.green "\n=> #{message} <=\n"
        else
          console.log message

      # log full stack trace if a developer
      console.error 'EXCEPTION && VERBOSE'
      console.error exception, isVerbose
      if exception && isVerbose
        if exception == true
          throw new Error message
        else
          throw exception

      # exit node if exception
      process.exit 1 if exception

    # get package.json
    # @arg {String} path - absolute directory path
    # @return {Object}
    #
    _getPackageJson: (path) ->
      try
        return require "#{path}/package.json"
      catch err
        @_logMessage err, 'fail', err
        @_logMessage err.message, 'fail', err
        @_logMessage 'No `package.json` found', 'fail', err
        return new Object

    # Get user configuration
    # @arg {String} packagePath - path to bumper package
    # @return {Object}
    #
    _getConfigFile: (packagePath) ->
      # look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync "#{packagePath}/config.yaml"

      # look for json file
      configFile ||= try JSON.parse fs.readFileSync "#{packagePath}/config.json"

      return configFile || new Object

    # Get all current package libraries
    # @return {Object} key: library name, value: library source path
    #
    _getlibs: (packagePath, formats) ->
      libFormats = formats.join '|'
      libs = new Object

      try
        files = fs.readdirSync "#{packagePath}/libs"
      catch err
        @_logMessage 'No `libs` directory found', 'fail', err

      for file in files
        libGlobPath = "#{packagePath}/libs/#{file}/#{file}.+(#{libFormats})"
        libPath = glob.sync(libGlobPath)[0]

        if libPath
          libs[file] = libPath

      return libs
