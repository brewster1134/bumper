argv = require('yargs-parser') process.argv.slice 2
downloadsFolder = require 'downloads-folder'

Cli = require './cli.coffee'
Config = require './config.coffee'
Logger = require './logger.coffee'

module.exports =
  class Bumper
    run: ->
      # route uncaught exceptions through logger
      process.on 'uncaughtException', (error) ->
        new Logger error,
          exit: 1
          type: 'error'

      # create global bumper object
      global.bumper =
        config: new Object
        optionGlobals:
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

      # initialize singletons
      cli = new Cli argv
      config = new Config cli

      # add cli verbose to config in case config.build() needs it
      global.bumper.config.verbose = cli.getVerbose()

      # populate global object with full config
      global.bumper.config = config.build()

      # initialize cli
      cli.run()
