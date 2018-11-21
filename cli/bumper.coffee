yargs = require 'yargs'

yargs
  .scriptName 'bumper'

  # command callback format
  # * require dependencies
  # * require config w/ custom options
  # * require and run associated lib

  # start the demo
  .command 'demo', 'Start the Bumper demo', (yargs) ->
    yargs.option 'host',
      alias: 'h'
      default: 'localhost'
      desc: 'Host to run the demo on'
      type: 'string'
    yargs.option 'port',
      alias: 'p'
      default: 8383
      desc: 'Port to run the demo on'
      type: 'number'
    yargs.option 'tests',
      default: false
      desc: 'Enable showing test results in the demo (slower)'
      type: 'boolean'
  , (args) ->
    nodemon = require 'nodemon'
    config = require('../lib/config')
      demo:
        host: args.host
        port: args.port
        tests: args.tests

    nodemon
      script: './lib/demo.coffee'
      args: [ "--config='#{JSON.stringify(config)}'" ]
    .on 'restart', (files) ->
      console.log 'Demo restarted due to changes to', files.toString()
    .on 'quit', ->
      console.log "\nDemo has quit"
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
    shell.exec 'yarn run -s webpack --silent --config ./lib/test_webpack.coffee'
    shell.exec "yarn run jest --colors --testRegex '\.tmp\/(#{regexLibs})_test.js$'"


  # if no command is passed
  .demandCommand 1, 'No Command was passed'

  # if unsupported command is passed
  .strict()
  .fail (msg, err) ->
    yargs.showHelp()
    console.log "\n=> #{msg.toUpperCase()} <=\n"

  .argv
