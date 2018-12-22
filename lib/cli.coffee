_ = require 'lodash'
chalk = require 'chalk'
fs = require 'fs'
packageJson = require '../package.json'
path = require 'path'
rimraf = require 'rimraf'
yaml = require 'js-yaml'
yargs = require 'yargs'

# set the root directory
rootPath = path.resolve __dirname, '..'
process.chdir rootPath

# cli config
flair = chalk.bold '------======------'

# import from config file
configFile = try yaml.safeLoad fs.readFileSync 'config.yaml'
configFile ||= try JSON.parse fs.readFileSync 'config.json'
configFile ||= new Object

# build core config
name = configFile.name || 'Bumper'
config =
  name: name
  nameSafe: name.toLowerCase().replace /\W/g, ''
  prod: process.env.NODE_ENV == 'production'
  rootPath: rootPath
  version: packageJson.version

# require helpers
Helpers = require('./helpers') config
helpers = new Helpers

# build interface
yargs
  .epilogue flair
  .example chalk.bold 'bumper [COMMAND] --help'
  .example chalk.bold 'bumper --version'
  .hide 'help'
  .hide 'version'
  .scriptName chalk.bold 'bumper'
  .strict()
  .usage flair

  # handle missing or unsupported commands
  .demandCommand 1, 'No Command was passed'
  .fail (msg, err) ->
    yargs.showHelp()
    helpers.logMessage msg, 'error'

  # runs before each command callback
  .middleware (argv) ->
    command = argv._[0]
    rimraf.sync path.join '.tmp', command

  # handle data key/value pairs
  .option 'data',
    alias: 'D'
    desc: 'Custom key:value pairs, splitd by a :'
    type: 'array'
    coerce: (data) ->
      # parse key/values in the format of --data key1:value1 key2:value2
      dataObject = new Object
      for keyValuePairString in data
        keyValuePairArray = keyValuePairString.split ':'
        dataObject[keyValuePairArray[0]] = keyValuePairArray[1]

      return dataObject


  # => BUILD
  # ---
  .command 'build', 'Build bundles from your libraries', (yargs) ->
    yargs.option 'development',
      alias: 'd'
      default: false
      desc: 'Build un-minified bundles'
      type: 'boolean'
    yargs.option 'libs',
      alias: 'l'
      default: helpers.libs
      desc: 'One or more library names to build'
      type: 'array'
    yargs.option 'split',
      alias: 's'
      default: false
      desc: 'Build each lib separately'
      type: 'boolean'
  , (args) ->
    config.build =
      data: helpers.buildDataObject configFile, 'build', args.data
      development: args.development
      libs: args.libs
      split: args.split

    require('./build.coffee') config, helpers


  # => DEMO
  # ---
  .command 'demo', 'Start the demo', (yargs) ->
    yargs.option 'engines',
      default: configFile.demo?.engines || new Object
      hidden: true
    yargs.option 'host',
      alias: 'h'
      default: process.env.BUMPER_HOST || configFile.demo?.host || 'localhost'
      desc: 'Host to run the demo on'
      type: 'string'
    yargs.option 'port',
      alias: 'p'
      default: process.env.BUMPER_PORT || configFile.demo?.port || 8383
      desc: 'Port to run the demo on'
      type: 'number'
    yargs.option 'tests',
      default: false
      desc: 'Show test results in the demo (slower)'
      type: 'boolean'
  , (args) ->
    config.demo =
      data: helpers.buildDataObject configFile, 'demo', args.data
      host: args.host
      port: args.port
      tests: args.tests
      engines:
        css: _.union args.engines.css || new Array, ['sass', 'css']
        html: _.union args.engines.html || new Array, ['pug', 'md', 'html']
        js: _.union args.engines.js || new Array, ['coffee', 'js']

    nodemon = require 'nodemon'
    nodemon
      script: './lib/demo.coffee'
      ext: 'coffee,js'
      args: [ "--config='#{JSON.stringify(config)}'" ]
      watch: [
        'demo/routes'
        'demo/scripts'
        'lib/demo.coffee'
        'lib/helpers.coffee'
        'user/demo/scripts'
        'user/libs'
      ]
    .on 'restart', (files) ->
      console.log "#{config.name} demo restarted due to changes to", files.toString()
    .on 'quit', ->
      console.log "\n#{config.name} demo has quit"
      process.exit()


  # => TEST
  # ---
  .command 'test', 'Run your tests', (yargs) ->
    yargs.option 'libs',
      alias: 'l'
      default: helpers.libs
      desc: 'One or more library names to test'
      type: 'array'
  , (args) ->
    config.test =
      data: helpers.buildDataObject configFile, 'test', args.data
      libs: args.libs

    require('./test.coffee') config, helpers


  .argv
