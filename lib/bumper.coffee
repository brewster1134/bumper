yargsParser = require 'yargs-parser'

Cli = require './cli.coffee'
Config = require './config.coffee'
Logger = require './logger.coffee'

module.exports =
  class Bumper
    run: ->
      # route uncaught exceptions through logger
      process.on 'uncaughtException', (error) =>
        @_log error.message,
          exit: 1
          type: 'error'

      # create global bumper object
      global.bumper =
        log: @_log
        verbose: @_getVerbose

      # initialize config and make global
      global.bumper.config = new Config().build()

      # # initialize cli
      new Cli().run()

    # helper method to initialize a logger instance
    #
    # @see Logger#log
    _log: (message, options = {}) ->
      new Logger message, options

    # check if in verbose mode
    #
    # @return {Boolean}
    _getVerbose: ->
      # check if verbose exists in the configuration
      if global.bumper.config?.verbose?
        return global.bumper.config.verbose

      # check if verbose flag was passed via cli
      argv = yargsParser process.argv.slice 2
      if argv?.V?
        return argv.V
      else if argv?.verbose?
        return argv.verbose

      # default to false
      return false
