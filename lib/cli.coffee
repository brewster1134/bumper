_ = require 'lodash'
chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
path = require 'path'
yaml = require 'js-yaml'
yargs = require 'yargs'

module.exports =
  class Cli
    constructor: ->
      # get config
      configFile = @_getConfigFile()
      configCore = @_getConfigCore configFile
      @config ||= @_getConfig configFile, configCore

      # get helpers
      @helpers ||= @_getHelpers()

      return @_buildCli()

    # Load the config file
    # @return {Object}
    #
    _getConfigFile: ->
      # Look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync 'config.yaml'

      # Look for json file
      configFile ||= try JSON.parse fs.readFileSync 'config.json'

      # Pass empty object if no config is found
      configFile ||= new Object

      return configFile

    # Build core config of defaults
    # @arg {Object} configFile
    # @return {Object}
    #
    _getConfigCore: (configFile) ->
      # set default values
      name = configFile.name || 'Bumper'
      bumperPath = path.resolve __dirname, '..'

      return
        bumperPath: bumperPath
        flair: chalk.bold '------======------'
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, ''
        packagePath: process.cwd()
        version: require('../package.json').version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: [ 'coffee', 'js' ]

    # Build full config
    # @arg {Object} configFile
    # @arg {Object} configCore
    # @return {Object}
    #
    _getConfig: (configFile, configCore) ->
      _.mergeWith configFile, configCore, (fileVal, coreVal) ->
        # if merging arrays, combine values from both
        if _.isArray(fileVal) && _.isArray(coreVal)
          _.union fileVal, coreVal

    # Require core helpers
    # @return {Object}
    #
    _getHelpers: ->
      Helpers = require './helpers'
      return new Helpers @config

    # => COMMANDS
    # Runs command-specific scripts
    # * Merge the cli arguments into the nested command-specific key in the config object
    # * Pass the config and helpers to the command script
    # @arg {Object} args - object of cli arguments
    #
    # => BUILD
    # ---
    _runBuild: (args) ->
      _.merge @config.build, args
      Build = require './commands/build.coffee'
      new Build @config, @helpers

    # => DEMO
    # ---
    _runDemo: (args) ->
      # Clear globals before merge
      @config.demo.globals = new Object
      _.merge @config.demo, args

      nodemon = require 'nodemon'
      nodemon
        script: "#{@config.bumperPath}/lib/commands/demo.coffee"
        ext: @config.formats.js.join ' '
        args: [ "--config='#{JSON.stringify(@config)}'" ]
        watch: [
          'demo/routes'
          'demo/scripts'
          'lib'
        ]
      .on 'crash', =>
        @helpers.logMessage "#{@config.name} demo has crashed", 'fail'
        process.exit 1
      .on 'quit', =>
        @helpers.logMessage "#{@config.name} demo has quit", 'alert'
        process.exit 0
      .on 'restart', (files) =>
        @helpers.logMessage "#{@config.name} demo restarted due to changes to #{files.toString()}", 'alert'
      .on 'start', =>
        @helpers.logMessage "#{@config.name} demo is running at http://#{@config.demo.host}:#{@config.demo.port}", 'success'

    # => TEST
    # ---
    _runTest: (args) ->
      _.merge @config.test, args
      Test = require './commands/test.coffee'
      new Test @config, @helpers

    # Build cli interface
    #
    _buildCli: ->
      yargs
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
          @helpers.logMessage msg, 'error'

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
          default: @helpers.getConfigValue null, 'develop', false
          desc: 'Run the commands in development mode'
          type: 'boolean'

        # global option to set verbose mode
        .option 'verbose',
          alias: 'V'
          default: @helpers.getConfigValue null, 'verbose', false
          desc: 'Log additional information'
          type: 'boolean'

        # => COMMANDS
        # Build command-specific options
        # * Use getConfigValue to lookup a default value, or
        # * Use coerce to use other means
        # * Call the command-specific run methodm and pass the cli arguments
        #
        # => BUILD
        # ---
        .command 'build', 'Build assets from your libraries', (yargs) =>
          yargs.option 'libs',
            alias: 'l'
            default: @helpers.getConfigValue 'build', 'libs', Object.keys(@helpers.libs).join ' '
            desc: 'One or more library names to build'
            type: 'array'
          yargs.option 'split',
            alias: 's'
            default: @helpers.getConfigValue 'build', 'split', false
            desc: 'Build each library separately'
            type: 'boolean'
        , (args) =>
          @_runBuild args

        # => DEMO
        # ---
        .command 'demo', 'Start the demo', (yargs) =>
          yargs.option 'globals',
            alias: 'g'
            default: new Array
            desc: 'Key:value pairs, separated by a colon'
            type: 'array'
            coerce: (globals) =>
              @helpers.cliDemoBuildLibGlobals globals
          yargs.option 'host',
            alias: 'h'
            default: @helpers.getConfigValue 'demo', 'host', 'localhost'
            desc: 'Host to run the demo on'
            type: 'string'
          yargs.option 'port',
            alias: 'p'
            default: @helpers.getConfigValue 'demo', 'port', 8383
            desc: 'Port to run the demo on'
            type: 'number'
          yargs.option 'tests',
            alias: 't'
            default: @helpers.getConfigValue 'demo', 'tests', false
            desc: 'Show test results in the demo (slower)'
            type: 'boolean'
        , (args) =>
          @_runDemo args

        # => TEST
        # ---
        .command 'test', 'Run your tests', (yargs) =>
          yargs.option 'bumper',
            alias: 'b'
            default: false
            desc: 'Run the core Bumper tests'
            type: 'boolean'
          yargs.option 'libs',
            alias: 'l'
            default: Object.keys(@helpers.libs).join ' '
            desc: 'One or more libraries to test'
            type: 'array'
          yargs.option 'watch',
            alias: 'w'
            default: false
            desc: 'Watch lib and run tests when changes are made'
            type: 'boolean'
        , (args) ->
          @_runTest args
