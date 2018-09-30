child = require 'child_process'
shell = require 'shelljs'
yargs = require 'yargs'

yargs
  .scriptName 'bumper'

  .command ['start', '$0'], 'Start your Bumper demo', (yargs) ->
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
      desc: 'Show tests in the demo (slower)'
      type: 'boolean'
  , (args) ->
    shell.exec 'yarn run -s coffee --bare --no-header -o ./.tmp/app.js ./app/app.coffee'
    shell.exec "yarn run -s nodemon .tmp/app.js --host=#{args.host} --port=#{args.port} --tests=#{args.tests}"

  .command 'lib', 'Manage your libraries', (yargs) ->
    yargs.command 'new [NAME]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name',
        desc: 'The name of the new library'

    yargs.command 'depend [LIB_NAME] [NPM_PACKAGE(S)]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name',
        desc: 'The name of the library'
      yargs.positional 'packages',
        desc: 'NPM packages the library depends on (seperated by spaces)'

  .command 'test', 'Run your tests', (yargs) ->
    yargs.options 'libs',
      alias: 'l'
      default: '**'
      desc: 'One or more library names to test'
      type: 'array'
  , (args) ->
    regexLibs = args.libs.join '|'
    child.exec "yarn run jest --colors --testMatch '**/libs/(#{regexLibs})/(#{regexLibs})_test.js'", (error, stdout, stderr) ->
      console.log stderr

  .argv
