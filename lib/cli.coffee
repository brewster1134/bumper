_ = require 'lodash'
chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'
yargs = require 'yargs'

module.exports =
  class Cli
    constructor: ->
      # get environment configuration
      @VERBOSE = process.argv.includes('-V') || process.argv.includes('--verbose')
      packagePath = process.cwd()

      # get package.json
      try
        @packageJson = require "#{packagePath}/package.json"
      catch err
        @logMessage 'No `package.json` found', 'fail', err

      # get user configuration
      @configFile = @_getConfigFile packagePath

      # get core configuration
      @configCore = @_getConfigCore packagePath

      # get package libraries
      try
        @libs = @_getlibs()

        if !Object.keys(@libs).length
          @logMessage 'No valid Bumper libraries found', 'fail', true
      catch err
        @logMessage 'No `libs` directory found', 'fail', err

      # get cli
      return @_buildCli()

    # Log a formatted message
    # @arg {String} message - the message to log
    # @arg {String} type - the type of message to log
    # @arg {Error|true} exception
    #
    logMessage: (message, type, exception) ->
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
      if exception && @VERBOSE
        if exception == true
          throw new Error message
        else
          throw exception

      # exit node if exception
      process.exit 1 if exception

    # Get user configuration
    # @return {Object}
    #
    _getConfigFile: (packagePath) ->
      # look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync "#{packagePath}/config.yaml"

      # look for json file
      configFile ||= try JSON.parse fs.readFileSync "#{packagePath}/config.json"

      return configFile || new Object

    # Get core configuration
    # @return {Object}
    #
    _getConfigCore: (packagePath) ->
      # shared defaults
      name = @configFile.name || @packageJson.name || 'Bumper'

      return
        # core defaults
        bumperPath: path.resolve __dirname, '..'
        flair: chalk.bold '------======------'
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, ''
        packagePath: packagePath
        version: @packageJson.version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: [ 'coffee', 'js' ]

    # # Require core helpers
    # # @return {Object}
    # #
    # _getHelpers: ->
    #   Helpers = require './helpers'
    #   return new Helpers @configCore

    # Get all current package libraries
    # @return {Object} key: library name, value: library source path
    # @return {null} if no libs directory exists
    #
    _getlibs: ->
      libFormats = @configCore.formats.js.join '|'
      libs = new Object
      files = fs.readdirSync "#{@configCore.packagePath}/libs"

      for file in files
        libGlobPath = "#{@configCore.packagePath}/libs/#{file}/#{file}.+(#{libFormats})"
        libPath = glob.sync(libGlobPath)[0]

        if libPath
          libs[file] = libPath

      return libs

    # Reference for command defaults
    # @return {Object}
    #
    _getOptionDefault: (command, option) ->
      defaults =
        develop: false
        libs: Object.keys @libs
        verbose: false
        build:
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


    # Build full config
    # @arg {Object} configFile
    # @arg {Object} configCore
    # @return {Object}
    #
    # _getConfigObject: (configFile, configCore) ->
    #   _.mergeWith configFile, configCore, (fileVal, coreVal) ->
    #     # if merging arrays, combine values from both
    #     if _.isArray(fileVal) && _.isArray(coreVal)
    #       _.union fileVal, coreVal


    # Search for value from all configuration locations
    # @arg {String} command
    # @arg {String} option
    # @arg defaultVal - the default value if no other value is found
    #
    _getOptionValue: (command, option) ->
      defaultVal = @_getOptionDefault command, option
      optionType = defaultVal.constructor

      envVarVal = @_getEnvVarValue command, option, optionType
      configVal = @_getConfigValue command, option

      if envVarVal?
        return envVarVal
      else if configVal?
        return configVal
      else
        return defaultVal

    # Build the globals object
    # @arg {Array} cliVal - array of globals from cli
    # @return {Object} object with full globals for each lib
    #
    _buildGlobals: (cliVal) ->
      envVarVal = @_getEnvVarValue 'demo', 'globals', Object
      configVal = @_getConfigValue 'demo', 'globals'
      cliVal = @_getGlobalsFromString cliVal

      # Create skeleton of lib
      libGlobals = new Object
      for lib, path of @libs
        libGlobals[lib] = new Object

      # Merge all globals together
      if envVarVal
        _.merge libGlobals, @_buildLibGlobals envVarVal
      if configVal
        _.merge libGlobals, @_buildLibGlobals configVal
      if cliVal
        _.merge libGlobals, @_buildLibGlobals cliVal

      return libGlobals

    # Get value from an environment variable
    # @arg {String} command - the command passed
    # @arg {String} option - the option passed
    # @arg {Function} type - the class type of the returned value
    #
    _getEnvVarValue: (command, option, type) ->
      # search all variations of environment variable names
      customCommandEnvVar = "#{@configCore.nameSafe}_#{command}_#{option}".toUpperCase()
      customEnvVar = "#{@configCore.nameSafe}_#{option}".toUpperCase()
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
            envVar = @_getGlobalsFromString envVar.split ','

      return envVar

    # Search for value in the configuration object
    # @arg {String} command
    # @arg {String} option
    #
    _getConfigValue: (command, option) ->
      if @configFile[command]?[option]?
        return @configFile[command][option]
      else
        return @configFile[option]

    # Parse globals from command line into key/value pairs
    # @arg {String[]} stringGlobals - array of key/value pairs in the format 'key:value'
    # @return {Object}
    #
    _getGlobalsFromString: (stringGlobals) ->
      return unless stringGlobals.length

      globals = new Object
      for stringGlobal in stringGlobals
        globalArray = stringGlobal.split ':'
        if globalArray[0]
          globals[globalArray[0]] = globalArray[1]

      return globals

    # Duplicate all non-lib globals into each lib's globals
    # @arg {Object} originalGlobals - globals to inject into each lib globals
    # @return {Object} object with original globals for each lib
    #
    _buildLibGlobals: (originalGlobals) ->
      libGlobals = new Object
      nonLibGlobals = new Object

      # create empty objects for each lib
      for lib, path of @libs
        libGlobals[lib] = new Object

      # separate lib and non-lib globals
      for key, val of originalGlobals
        if @libs[key]
          libGlobals[key] = val
        else
          nonLibGlobals[key] = val

      # merge non-lib globals into each lib's globals
      for lib, val of libGlobals
        libGlobals[lib] = _.merge new Object, nonLibGlobals, libGlobals[lib]

      return libGlobals

    _buildCommandConfig: (command, args) ->
      config = new Object

      _.merge config, @configCore, @_getGlobalOptions command, args
      config[command] = args

      return config

    # => COMMANDS
    # Runs command-specific script with command-specific configuration
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
        script: "#{@configCore.bumperPath}/lib/commands/demo.coffee"
        ext: @configCore.formats.js.join ' '
        args: [ "--config='#{JSON.stringify(config)}'" ]
        watch: [
          'demo/routes'
          'demo/scripts'
          'lib'
        ]
      .on 'crash', =>
        @logMessage "#{config.name} demo has crashed", 'fail'
        process.exit 1
      .on 'quit', =>
        @logMessage "#{config.name} demo has quit", 'alert'
        process.exit 0
      .on 'restart', (files) =>
        @logMessage "#{config.name} demo restarted due to changes to #{files.toString()}", 'alert'
      .on 'start', =>
        @logMessage "#{config.name} demo is running at http://#{config.demo.host}:#{config.demo.port}", 'success'

    # => TEST
    # ---
    _runTest: (config) ->
      Test = require './commands/test.coffee'
      new Test config

    _getGlobalOptions: (command, args) ->
      globalOptions =
        develop: null
        verbose: null

      for option, value of globalOptions
        globalOptions[option] = @_getOptionValue command, option

        # update app-level verbose flag
        @VERBOSE = globalOptions.verbose if option == 'verbose'

      return globalOptions


    # Build cli interface
    #
    _buildCli: ->
      return yargs
        .epilogue @configCore.flair
        .example chalk.bold 'bumper [COMMAND] --help'
        .example chalk.bold 'bumper --version'
        .hide 'help'
        .hide 'version'
        .scriptName chalk.bold 'bumper'
        .strict()
        .usage @configCore.flair

        # handle missing or unsupported commands
        .demandCommand 1, 'no command was passed'
        .fail (msg, err) =>
          yargs.showHelp()
          @logMessage msg, 'error'

        # run before each command
        .middleware (argv) =>
          # get command name
          command = argv._[0]

          # get path to command cache directory
          tmpDir = "#{@configCore.packagePath}/.tmp/#{command}"

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
        # Build command-specific options
        # * Use _buildCommandConfig to build the command-specific configuration object
        # * Call the command-specific run method and pass the cli arguments
        #
        # => BUILD
        # ---
        .command 'build', 'Build assets from your libraries', (yargs) =>
          yargs.option 'libs',
            alias: 'l'
            default: @_getOptionValue 'build', 'libs'
            desc: 'One or more library names to build'
            type: 'array'
          yargs.option 'split',
            alias: 's'
            default: @_getOptionValue 'build', 'split'
            desc: 'Build each library separately'
            type: 'boolean'
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
