argv = require('yargs-parser') process.argv.slice 2

Cli = require './cli.coffee'
Config = require './config.coffee'
Logger = require './logger.coffee'

module.exports =
  class Bumper
    run: ->
      # route uncaught exceptions through logger
      process.on 'uncaughtException', (error) ->
        new Logger error.message,
          exit: 1
          type: 'error'

      # initialize singletons
      cli = new Cli argv
      config = new Config cli

      # create global bumper object
      global.bumper =
        verbose: cli.getVerbose()

      # replace global object with full config
      global.bumper = config.build()

      # initialize cli
      cli.run()
