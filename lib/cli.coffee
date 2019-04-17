_ = require 'lodash'
chalk = require 'chalk'
fs = require 'fs-extra'
yargs = require 'yargs'

Logger = require './logger.coffee'

module.exports =
  class Cli
    run: ->
      global.bumper.setSharedOptionValues()
      @_buildCli().argv

    # Search for an option's value across all locations
    # @arg {string} command
    # @arg {string} option
    # @return {*}
    #
    getOptionValue: (command, option) ->
      defaultVal = @_getOptionDefault command, option
      optionType = defaultVal.constructor

      # search for an environment variable
      envVarVal = @_getEnvVarValue command, option, optionType
      return envVarVal if envVarVal?

      # search in the configuration
      configVal = @_getConfigFileValue command, option
      return configVal if configVal?

      # if no value was found, return the default
      return defaultVal

    # Lookup command option defaults
    # @arg {string} command
    # @arg {string} option
    # @return {object}
    #
    _getOptionDefault: (command, option) ->
      if global.bumper.optionDefaults[command]?[option]?
        global.bumper.optionDefaults[command][option]
      else
        global.bumper.optionDefaults[option]

    # Get value from an environment variable
    # @arg {string} command - the command passed
    # @arg {string} option - the option passed
    # @arg {function} type - the class type of the returned value
    # @return {object|null}
    #
    _getEnvVarValue: (command, option, type) ->
      # search all variations of environment variable names
      customCommandEnvVar = "#{global.bumper.config.nameSafe}_#{command}_#{option}".toUpperCase()
      customEnvVar = "#{global.bumper.config.nameSafe}_#{option}".toUpperCase()
      bumperCommandEnvVar = "bumper_#{command}_#{option}".toUpperCase()
      bumperEnvVar = "bumper_#{option}".toUpperCase()
      envVar =  process.env[customCommandEnvVar] ||
                process.env[customEnvVar] ||
                process.env[bumperCommandEnvVar] ||
                process.env[bumperEnvVar]

      # if no environment variable was set, return null
      return null unless envVar

      # typecast the string to the proper object class type
      return switch type
        when Array
          envVar.split ','
        when Boolean
          envVar == 'true'
        when Number
          parseInt envVar
        when Object
          @_getGlobalsFromArray envVar.split ','
        else
          envVar

    # Search for value in the configuration object
    # @arg {string} command
    # @arg {string} option
    #
    _getConfigFileValue: (command, option) ->
      if global.bumper.config?.file[command]?[option]?
        return global.bumper.config.file[command][option]
      else
        return global.bumper.config?.file[option]

    # Set the command object on the global config
    # @arg {string} command
    # @arg {object} args - the command line argument object
    #
    _setCommandOptions: (command, args) ->
      # add command options into command namespace
      global.bumper.config[command] = @_cleanCommandOptions args

      new Logger "running: #{command} w/ #{JSON.stringify(global.bumper.config[command], null, 2)}",
        type: 'alert'
        verbose: true

    # Cleanup unnecessary keys from command specific config
    # @arg {object} args
    # @return {object}
    #
    _cleanCommandOptions: (args) ->
      # remove args keys
      delete args.$0
      delete args._

      # remove shared options from command object
      for option, alias of global.bumper.optionShared
        delete args[option]
        delete args[alias]

      # remove all aliases, not just for shared options
      # the requires that aliases are always a lowercase of the first letter of the option
      for key, val of args
        if key.length == 1
          delete args[key]

      return args

    # Build the globals object
    # @arg {array} cliGlobals - array of globals from command line
    # @return {object} object with full globals for each lib
    #
    _buildGlobals: (cliGlobals) ->
      envVarVal = @_getEnvVarValue 'demo', 'globals', Object
      configVal = @_getConfigFileValue 'demo', 'globals'
      cliGlobals = @_getGlobalsFromArray cliGlobals

      # Create skeleton of lib
      libGlobals = {}
      for lib, path of global.bumper.config.libs
        libGlobals[lib] = {}

      # Merge all globals together
      if envVarVal
        _.merge libGlobals, @_buildLibGlobals envVarVal
      if configVal
        _.merge libGlobals, @_buildLibGlobals configVal
      if cliGlobals
        _.merge libGlobals, @_buildLibGlobals cliGlobals

      return libGlobals

    # Parse object from command line into key/value pairs
    # @arg {string[]} globalsArray - array of key/value pairs in the format 'key:value'
    # @return {object}
    #
    _getGlobalsFromArray: (globalsArray) ->
      return null unless globalsArray?.length

      objekt = {}
      for globalString in globalsArray
        objectArray = globalString.split ':'
        if objectArray[0]
          objekt[objectArray[0]] = objectArray[1] || null

      return objekt

    # Duplicate all non-lib globals into each lib's globals
    # @arg {object} originalGlobals - globals to inject into each lib globals
    # @return {object} object with original globals for each lib
    #
    _buildLibGlobals: (originalGlobals) ->
      libGlobals = {}
      nonLibGlobals = {}

      # create empty objects for each lib
      for lib, path of global.bumper.config.libs
        libGlobals[lib] = {}

      # separate lib and non-lib globals
      for key, val of originalGlobals
        if global.bumper.config.libs[key]
          libGlobals[key] = val
        else
          nonLibGlobals[key] = val

      # merge non-lib globals into each lib's globals
      for lib, val of libGlobals
        libGlobals[lib] = _.merge {}, nonLibGlobals, libGlobals[lib]

      return libGlobals

    # => COMMANDS
    # Run command-specific script with command-specific configuration
    # @arg {object} config - command-specific configuration
    #
    # => BUILD
    # ---
    _runBuild: ->
      Build = require './commands/build.coffee'
      new Build().run()

    # => DEMO
    # ---
    _runDemo: ->
      # delete package.json data for sending through nodemon
      delete config.bumperJson
      delete config.projectJson

      nodemon = require 'nodemon'
      nodemon
        verbose: config.verbose
        script: "#{config.bumperPath}/lib/commands/demo.coffee"
        ext: config.formats.js.join ' '
        args: [ "--config='#{JSON.stringify(config)}'" ]
        watch: [
          "#{config.bumperPath}/demo/routes"
          "#{config.bumperPath}/demo/scripts"
          "#{config.bumperPath}/lib"
        ]
      .on 'crash', =>
        new Logger "#{config.name} demo has crashed",
          exit: 1
          type: 'error'
      .on 'quit', =>
        new Logger "#{config.name} demo has quit",
          exit: 0
          type: 'alert'
      .on 'restart', (files) =>
        new Logger "#{config.name} demo restarted due to changes to #{files.toString()}",
          exit: false
          type: 'alert'
      .on 'start', =>
        new Logger "#{config.name} demo is running at http://#{config.demo.host}:#{config.demo.port}",
          exit: false
          type: 'success'

    # => TEST
    # ---
    _runTest: ->
      Test = require './commands/test.coffee'
      new Test().run()

    # Build command line interface
    #
    _buildCli: ->
      return yargs
        .epilogue global.bumper.config.flair
        .example chalk.bold 'bumper [COMMAND] --help'
        .example chalk.bold 'bumper --version'
        .hide 'help'
        .hide 'version'
        .scriptName chalk.bold 'bumper'
        .strict()
        .usage global.bumper.config.flair

        # handle missing or unsupported commands
        .demandCommand 1, 'no command was passed'
        .fail (msg, err) =>
          yargs.showHelp()
          new Logger msg,
            exit: 1
            type: 'error'

        # run before each command
        .middleware (argv) =>
          # get command name
          command = argv._[0]

          # get path to command cache directory
          tmpDir = "#{global.bumper.config.projectPath}/.tmp/#{command}"

          # ensure command cache directory exists & is empty
          fs.ensureDirSync tmpDir
          fs.emptyDirSync tmpDir

        # the shared options alias must...
        # * match the first character of the option name
        # * be capitalized
        .option 'develop',
          alias: 'D'
          default: @_getOptionDefault null, 'develop'
          desc: 'Run the commands in development mode'
          type: 'boolean'
        .option 'verbose',
          alias: 'V'
          default: @_getOptionDefault null, 'verbose'
          desc: 'Log additional information'
          type: 'boolean'

        # => COMMANDS
        # * Use _setCommandOptions to build the command-specific configuration object
        # * Call the command-specific run method and pass the bumper arguments
        #
        # => BUILD
        # ---
        .command 'build', 'Build assets from your libraries', (yargs) =>
          yargs.option 'compress',
            alias: 'c'
            default: @getOptionValue 'build', 'compress'
            desc: 'Compress assets into a single archive file'
            type: 'boolean'
          yargs.option 'libs',
            alias: 'l'
            default: @getOptionValue 'build', 'libs'
            desc: 'One or more library names to build'
            type: 'array'
          yargs.option 'split',
            alias: 's'
            default: @getOptionValue 'build', 'split'
            desc: 'Build each library separately'
            type: 'boolean'
          yargs.option 'output',
            alias: 'o'
            default: @getOptionValue 'build', 'output'
            desc: 'Local directory to save built project to'
            type: 'string'
        , (args) =>
          @_setCommandOptions 'build', args
          @_runBuild()

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
            default: @getOptionValue 'demo', 'host'
            desc: 'Host to run the demo on'
            type: 'string'
          yargs.option 'port',
            alias: 'p'
            default: @getOptionValue 'demo', 'port'
            desc: 'Port to run the demo on'
            type: 'number'
          yargs.option 'tests',
            alias: 't'
            default: @getOptionValue 'demo', 'tests'
            desc: 'Show test results in the demo (slower)'
            type: 'boolean'
        , (args) =>
          @_setCommandOptions 'demo', args
          @_runDemo()

        # => TEST
        # ---
        .command 'test', 'Run your tests', (yargs) =>
          yargs.option 'libs',
            alias: 'l'
            default: @getOptionValue 'test', 'libs'
            desc: 'One or more libraries to test'
            type: 'array'
          yargs.option 'watch',
            alias: 'w'
            default: @getOptionValue 'test', 'watch'
            desc: 'Watch lib and run tests when changes are made'
            type: 'boolean'
        , (args) =>
          @_setCommandOptions 'test', args
          @_runTest()
