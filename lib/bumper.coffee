argvParser = require 'yargs-parser'
downloadsFolder = require 'downloads-folder'

Cli = require './cli'
Config = require './config'
Logger = require './logger'

### !pragma no-coverage-next ###
# route uncaught exceptions through logger
process.on 'uncaughtException', (error) ->
  new Logger error,
    exit: 1
    type: 'error'

module.exports =
  class Bumper
    run: ->
      # extract command & cli options
      @args = argvParser process.argv.slice 2
      command = @args._[0]

      # create global bumper object
      global.bumper =
        # expose function to global object & bind to this bumper instance
        log: @_log.bind @
        requirer: @_requirer.bind @
        setSharedOptionValues: @_setSharedOptionValues.bind @

        config:
          command: command
          file: {}
        optionShared:
          develop: 'D'
          verbose: 'V'
        optionDefaults:
          develop: false
          verbose: false
          build:
            compress: false
            output: downloadsFolder()
            split: false
          demo:
            host: 'localhost'
            port: 8383
            tests: false
          test:
            watch: false

      # create cli singleton
      @cli = new Cli

      # populate global config
      config = new Config
      global.bumper.config = config.build()

      # initialize cli
      @cli.run()

    _log: (args...) ->
      new Logger args...

    _requirer: (args...) ->
      require args...

    # set shared options to global config object
    #
    _setSharedOptionValues: ->
      for option, alias of global.bumper.optionShared
        optVal = if @args[option]?
          @args[option]
        else if @args[alias]?
          @args[alias]
        else
          @cli.getOptionValue global.bumper.config.command, option

        global.bumper.config[option] = optVal
