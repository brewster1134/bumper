yargs = require 'yargs'

yargs
  .scriptName 'bumper'
  .showHelpOnFail true

  # start the app
  .command 'start', 'Start the Bumper demo', (yargs) ->
    yargs.option 'host',
      alias: 'h'
      default: 'localhost'
      desc: 'Host to run the app on'
      type: 'string'
    yargs.option 'port',
      alias: 'p'
      default: 8383
      desc: 'Port to run the app on'
      type: 'number'
    yargs.option 'tests',
      default: false
      desc: 'Enable showing test results in the demo (slower)'
      type: 'boolean'
  , (args) ->
    nodemon = require 'nodemon'
    config = require('../lib/config')
      app:
        host: args.host
        port: args.port
        tests: args.tests

    nodemon
      script: './app/start.coffee'
      args: [ "--config='#{JSON.stringify(config)}'" ]
    .on 'restart', (files) ->
      console.log 'App restarted due to changes to', files.toString()
    .on 'quit', ->
      console.log "\nApp has quit"
      process.exit()

  # libs
  .command 'lib', 'Manage your libraries', (yargs) ->
    yargs.command 'new [NAME]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name',
        desc: 'The name of the new library'

    yargs.command 'depend [LIB_NAME] [PACKAGES]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name',
        desc: 'The name of the library'
      yargs.positional 'packages',
        desc: 'NPM packages the library depends on (seperated by spaces)'

  # tests
  .command 'test', 'Run your tests', (yargs) ->
    yargs.options 'libs',
      alias: 'l'
      default: '.+'
      desc: 'One or more library names to test'
      type: 'array'
  , (args) ->
    shell = require 'shelljs'

    regexLibs = args.libs.join '|'
    shell.exec 'yarn run -s webpack --silent --config ./webpack.test.coffee'
    shell.exec "yarn run jest --colors --testRegex '\.tmp\/(#{regexLibs})_test.js$'"

  # if no command is passed
  .demandCommand 1, 'No Command was passed'
  .help()
  .argv
