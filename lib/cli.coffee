chalk = require 'chalk'
path = require 'path'
yargs = require 'yargs'

# run everything from bumper root
process.chdir path.resolve __dirname, '..'

flair = chalk.bold '------======------'

yargs
  .scriptName chalk.bold 'bumper'
  .example 'bumper demo help'
  .usage flair
  .epilogue flair
  .strict()

  # if missing or unsupported command is passed
  .demandCommand 1, 'No Command was passed'
  .fail (msg, err) ->
    yargs.showHelp()
    console.log chalk.red "\n=> #{msg.toUpperCase()} <=\n"

  # start the demo
  .command 'demo', 'Start the demo', (yargs) ->
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
      desc: 'Show test results (slower)'
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
      ext: 'coffee,js'
      args: [ "--config='#{JSON.stringify(config)}'" ]
      watch: [
        'demo/routes'
        'demo/scripts'
        'lib/demo.coffee'
        'user/demo/scripts'
        'user/libs'
      ]
    .on 'restart', (files) ->
      console.log "#{config.name} demo restarted due to changes to", files.toString()
    .on 'quit', ->
      console.log "\n#{config.name} demo has quit"
      process.exit()

  # libs
  .command 'lib', 'Manage your libraries', (yargs) ->
    yargs.command 'new [NAME]', 'Create a new library skeleton', (yargs) ->
      yargs.positional 'name',
        desc: 'The name of the new library'

    yargs.command 'depend [LIB_NAME] [PACKAGES]', 'Add dependencies to your library', (yargs) ->
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
    config = require('../lib/config')
      test:
        foo: 'bar'
    require('./test.coffee') config, args

  .argv
