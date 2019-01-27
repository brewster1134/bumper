_ = require 'lodash'
argv = require('yargs-parser') process.argv.slice 2
chalk = require 'chalk'
fs = require 'fs-extra'
path = require 'path'
yargs = require 'yargs'

Config = require './config'

module.exports =
  class Bumper
    constructor: ->
      # get config
      @config = new Config

      # get cli
      return @_buildCli()

    # Lookup command option defaults
    # @arg {String} command
    # @arg {String} option
    # @return {Object}
    #
    _getOptionDefault: (command, option) ->
      defaults =
        develop: false
        libs: Object.keys @config.libs
        verbose: false
        build:
          compress: false
          split: false
        demo:
          host: 'localhost'
          port: 8383
          tests: false
        test:
          watch: false

      if defaults[command]?[option]?
        return defaults[command][option]
      else
        return defaults[option]

    # Search for an option's value
    # @arg {String} command
    # @arg {String} option
    # @return {*}
    #
    _getOptionValue: (command, option) ->
      defaultVal = @_getOptionDefault command, option
      optionType = defaultVal.constructor

      # search for an environment variable
      envVarVal = @_getEnvVarValue command, option, optionType
      if envVarVal?
        return envVarVal

      # search in the configuration
      configVal = @_getConfigValue command, option
      if configVal?
        return configVal

      # if no value was found, return the default
      return defaultVal

    # Build the entire config object to be passed to each command script
    # @arg {String} command
    # @arg {Object} args - the command line argument object
    #
    _buildCommandConfig: (command, args) ->
      config = new Object

      # merge global options into config core
      _.merge config, @config, @_getGlobalOptions(command, args)

      # add command options into command namespace
      config[command] = @_cleanupCommandConfig args

      return config

    # cleanup unnecessary keys
    # @arg {Object} args
    # @return {Object}
    #
    _cleanupCommandConfig: (args) ->
      # remove args keys
      delete args.$0
      delete args._

      # remove global options from command object
      delete args.develop
      delete args.verbose

      # remove aliases
      for key, val of args
        if key.length == 1
          delete args[key]

      return args

    # Look for command-specific values for global options
    # @arg {String} command
    # @arg {Object} args
    # @return {Object}
    #
    _getGlobalOptions: (command, args) ->
      globalOptions = new Object
      commandOptions =
        D: 'develop'
        V: 'verbose'

      for alias, option of commandOptions
        # check if a value was passed in from the command line
        fromCli = argv[alias]? || argv[option]?

        if fromCli
          globalOptions[option] = args[option]
        else
          globalOptions[option] = @_getOptionValue command, option

      return globalOptions

    # Get value from an environment variable
    # @arg {String} command - the command passed
    # @arg {String} option - the option passed
    # @arg {Function} type - the class type of the returned value
    #
    _getEnvVarValue: (command, option, type) ->
      # search all variations of environment variable names
      customCommandEnvVar = "#{@config.nameSafe}_#{command}_#{option}".toUpperCase()
      customEnvVar = "#{@config.nameSafe}_#{option}".toUpperCase()
      bumperCommandEnvVar = "bumper_#{command}_#{option}".toUpperCase()
      bumperEnvVar = "bumper_#{option}".toUpperCase()
      envVar =  process.env[customCommandEnvVar] ||
                process.env[customEnvVar] ||
                process.env[bumperCommandEnvVar] ||
                process.env[bumperEnvVar]

      # if an env var is found, convert the string to the proper object class type
      if envVar
        switch type
          when Array
            envVar = envVar.split ','
          when Boolean
            envVar = envVar == 'true'
          when Number
            envVar = parseInt envVar
          when Object
            envVar = @_getGlobalsFromArray envVar.split ','

      return envVar

    # Search for value in the configuration object
    # @arg {String} command
    # @arg {String} option
    #
    _getConfigValue: (command, option) ->
      if @config.file[command]?[option]?
        return @config.file[command][option]
      else
        return @config.file[option]

    # Parse object from command line into key/value pairs
    # @arg {String[]} globalsArray - array of key/value pairs in the format 'key:value'
    # @return {Object}
    #
    _getGlobalsFromArray: (globalsArray) ->
      return unless globalsArray.length

      objekt = new Object
      for globalString in globalsArray
        objectArray = globalString.split ':'
        if objectArray[0]
          objekt[objectArray[0]] = objectArray[1]

      return objekt

    # Build the globals object
    # @arg {Array} cliGlobals - array of globals from command line
    # @return {Object} object with full globals for each lib
    #
    _buildGlobals: (cliGlobals) ->
      envVarVal = @_getEnvVarValue 'demo', 'globals', Object
      configVal = @_getConfigValue 'demo', 'globals'
      cliGlobals = @_getGlobalsFromArray cliGlobals

      # Create skeleton of lib
      libGlobals = new Object
      for lib, path of @config.libs
        libGlobals[lib] = new Object

      # Merge all globals together
      if envVarVal
        _.merge libGlobals, @_buildLibGlobals envVarVal
      if configVal
        _.merge libGlobals, @_buildLibGlobals configVal
      if cliGlobals
        _.merge libGlobals, @_buildLibGlobals cliGlobals

      return libGlobals

    # Duplicate all non-lib globals into each lib's globals
    # @arg {Object} originalGlobals - globals to inject into each lib globals
    # @return {Object} object with original globals for each lib
    #
    _buildLibGlobals: (originalGlobals) ->
      libGlobals = new Object
      nonLibGlobals = new Object

      # create empty objects for each lib
      for lib, path of @config.libs
        libGlobals[lib] = new Object

      # separate lib and non-lib globals
      for key, val of originalGlobals
        if @config.libs[key]
          libGlobals[key] = val
        else
          nonLibGlobals[key] = val

      # merge non-lib globals into each lib's globals
      for lib, val of libGlobals
        libGlobals[lib] = _.merge new Object, nonLibGlobals, libGlobals[lib]

      return libGlobals

    # => COMMANDS
    # Run command-specific script with command-specific configuration
    # @arg {Object} config - command-specific configuration
    #
    # => BUILD
    # ---
    _runBuild: (config) ->
      Build = require './commands/build.coffee'
      new Build config

    # => DEMO
    # ---
    _runDemo: (config) ->
      nodemon = require 'nodemon'
      nodemon
        script: "#{config.bumperPath}/lib/commands/demo.coffee"
        ext: config.formats.js.join ' '
        args: [ "--config='#{JSON.stringify(config)}'" ]
        watch: [
          "#{config.bumperPath}/demo/routes"
          "#{config.bumperPath}/demo/scripts"
          "#{config.bumperPath}/lib"
        ]
      .on 'crash', =>
        @config.log "#{config.name} demo has crashed", 'fail'
        process.exit 1
      .on 'quit', =>
        @config.log "#{config.name} demo has quit", 'alert'
        process.exit 0
      .on 'restart', (files) =>
        @config.log "#{config.name} demo restarted due to changes to #{files.toString()}", 'alert'
      .on 'start', =>
        @config.log "#{config.name} demo is running at http://#{config.demo.host}:#{config.demo.port}", 'success'

    # => TEST
    # ---
    _runTest: (config) ->
      Test = require './commands/test.coffee'
      new Test config

    # Build command line interface
    #
    _buildCli: ->
      return yargs
        .epilogue @config.flair
        .example chalk.bold 'bumper [COMMAND] --help'
        .example chalk.bold 'bumper --version'
        .hide 'help'
        .hide 'version'
        .scriptName chalk.bold 'bumper'
        .strict()
        .usage @config.flair

        # handle missing or unsupported commands
        .demandCommand 1, 'no command was passed'
        .fail (msg, err) =>
          yargs.showHelp()
          @config.log msg, 'error'

        # run before each command
        .middleware (argv) =>
          # get command name
          command = argv._[0]

          # get path to command cache directory
          tmpDir = "#{@config.packagePath}/.tmp/#{command}"

          # ensure command cache directory exists & is empty
          fs.ensureDirSync tmpDir
          fs.emptyDirSync tmpDir

        # global option to set development mode
        .option 'develop',
          alias: 'D'
          default: @_getOptionDefault null, 'develop'
          desc: 'Run the commands in development mode'
          type: 'boolean'

        # global option to set verbose mode
        .option 'verbose',
          alias: 'V'
          default: @_getOptionDefault null, 'verbose'
          desc: 'Log additional information'
          type: 'boolean'

        # => COMMANDS
        # * Use _buildCommandConfig to build the command-specific configuration object
        # * Call the command-specific run method and pass the bumper arguments
        #
        # => BUILD
        # ---
        .command 'build', 'Build assets from your libraries', (yargs) =>
          yargs.option 'compress',
            alias: 'c'
            default: @_getOptionValue 'build', 'compress'
            desc: 'Compress assets into a single archive file'
            type: 'boolean'
          yargs.option 'libs',
            alias: 'l'
            default: @_getOptionValue 'build', 'libs'
            desc: 'One or more library names to build'
            type: 'array'
          yargs.option 'split',
            alias: 's'
            default: @_getOptionValue 'build', 'split'
            desc: 'Build each library separately'
        , (args) =>
          config = @_buildCommandConfig 'build', args
          @_runBuild config

        # => DEMO
        # ---
        .command 'demo', 'Start the demo', (yargs) =>
          yargs.option 'globals',
            alias: 'g'
            desc: 'Key:value pairs, separated by a colon'
            type: 'array'
            coerce: (globals) =>
              @_buildGlobals globals
          yargs.option 'host',
            alias: 'h'
            default: @_getOptionValue 'demo', 'host'
            desc: 'Host to run the demo on'
            type: 'string'
          yargs.option 'port',
            alias: 'p'
            default: @_getOptionValue 'demo', 'port'
            desc: 'Port to run the demo on'
            type: 'number'
          yargs.option 'tests',
            alias: 't'
            default: @_getOptionValue 'demo', 'tests'
            desc: 'Show test results in the demo (slower)'
            type: 'boolean'
        , (args) =>
          config = @_buildCommandConfig 'demo', args
          @_runDemo config

        # => TEST
        # ---
        .command 'test', 'Run your tests', (yargs) =>
          yargs.option 'libs',
            alias: 'l'
            default: @_getOptionValue 'test', 'libs'
            desc: 'One or more libraries to test (when run from your Bumper package directory)'
            type: 'array'
          yargs.option 'watch',
            alias: 'w'
            default: @_getOptionValue 'test', 'watch'
            desc: 'Watch lib and run tests when changes are made'
            type: 'boolean'
        , (args) =>
          config = @_buildCommandConfig 'test', args
          @_runTest config
