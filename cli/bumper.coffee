shell = require 'shelljs'
yargs = require 'yargs'

yargs
  .scriptName 'bumper'
  .showHelpOnFail true

  # start the server
  .command 'start', 'Start your Bumper demo', (yargs) ->
    yargs.option 'host',
      alias: 'h'
      default: 'localhost'
      desc: 'Host to run the server on'
      type: 'string'
    yargs.option 'port',
      alias: 'p'
      default: 8383
      desc: 'Port to run the server on'
      type: 'number'
    yargs.option 'tests',
      default: false
      desc: 'Enable showing test results in the demo (slower)'
      type: 'boolean'
  , (args) ->
    shell.exec "yarn run -s nodemon ./app/start.coffee --host=#{args.host} --port=#{args.port} --tests=#{args.tests}"

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
    regexLibs = args.libs.join '|'
    shell.exec 'yarn run -s webpack --silent --config ./webpack.test.coffee'
    shell.exec "yarn run jest --colors --testRegex '\.tmp\/(#{regexLibs})_test.js$'"

  # if no command is passed
  .demandCommand 1, 'No Command was passed'
  .help()
  .argv
