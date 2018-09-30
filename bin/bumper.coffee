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
      default: 8484
      description: 'Port to run the server on'
  , (args) ->
    shell.exec 'yarn run -s coffee --bare --no-header -o ./.tmp/app.js ./app/app.coffee'
    shell.exec "yarn run -s nodemon .tmp/app.js --host=#{args.host} --port=#{args.port}"

  .command 'lib', 'Manage your libraries', (yargs) ->
    yargs.command 'new [NAME]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name'

  # .command 'test'

  .argv
