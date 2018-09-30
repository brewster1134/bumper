child = require 'child_process'
shell = require 'shelljs'
yargs = require 'yargs'

yargs
  .scriptName 'bumper'

  .command ['start', '$0'], 'Start your Bumper demo', (yargs) ->
    yargs.option 'host',
      alias: 'h'
      default: 'localhost'
      description: 'Host to run the server on'
    yargs.option 'port',
      alias: 'p'
      default: 8383
      description: 'Port to run the server on'
  , (args) ->
    shell.exec 'yarn run -s coffee --bare --no-header -o ./.tmp/app.js ./app/app.coffee'
    shell.exec "yarn run -s nodemon .tmp/app.js --host=#{args.host} --port=#{args.port}"

  .command 'test', 'Run your tests', (yargs) ->
    yargs.options 'libs',
      alias: 'l'
      default: '**'
      description: 'One or more library names to test'
      type: 'array'
  , (args) ->
    regexLibs = args.libs.join '|'
    child.exec "yarn run jest --colors --testMatch '**/libs/(#{regexLibs})/(#{regexLibs})_test.js'", (error, stdout, stderr) ->
      console.log stderr

  .argv
