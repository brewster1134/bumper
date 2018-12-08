_ = require 'lodash'
chalk = require 'chalk'
path = require 'path'
yargs = require 'yargs'
fs = require 'fs'
yaml = require 'js-yaml'

# run everything from bumper root
process.chdir path.resolve __dirname, '..'

# cli config
flair = chalk.bold '------======------'

# core config
configFile = try yaml.safeLoad fs.readFileSync 'config.yaml'
configFile ||= try JSON.parse fs.readFileSync 'config.json'
configFile ||= new Object

name = configFile.name || 'Bumper'
configCore =
  name: name
  nameSafe: name.toLowerCase().replace /\W/g, ''
  prod: process.env.NODE_ENV == 'production'
  rootPath: process.cwd()
  libs: configFile.libs || {}

yargs
  .scriptName chalk.bold 'bumper'
  .example chalk.bold 'bumper demo help'
  .usage flair
  .epilogue flair
  .strict()

  # handle missing or unsupported commands
  .demandCommand 1, 'No Command was passed'
  .fail (msg, err) ->
    yargs.showHelp()
    console.log chalk.red "\n=> #{msg.toUpperCase()} <=\n"

  # handle custom key/value pairs
  .option 'config',
    alias: 'c'
    desc: 'Custom key/value pairs (--config foo:bar,bar:baz)'
    type: 'string'
    coerce: (configCli) ->
      # parse key/values in the format of --config key1:value1,key2:value2
      configObject = new Object
      keyValuePairStrings = configCli.split ','
      for keyValuePairString in keyValuePairStrings
        keyValuePairArray = keyValuePairString.split ':'
        configObject[keyValuePairArray[0]] = keyValuePairArray[1]

      return configObject


  # => DEMO
  # ---
  .command 'demo', 'Start the demo', (yargs) ->
    yargs.config configFile.demo || {}
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
    yargs.option 'engines',
      default: configFile.demo?.engines || {}
      hidden: true

  , (args) ->
    nodemon = require 'nodemon'

    configCore.demo =
      config: args.config
      host: process.env.BUMPER_HOST || args.host
      port: process.env.BUMPER_PORT || args.port
      tests: args.tests
      engines:
        css: _.union args.engines.css || new Array, ['sass', 'css']
        html: _.union args.engines.html || new Array, ['pug', 'md', 'html']
        js: _.union args.engines.js || new Array, ['coffee', 'js']

    nodemon
      script: './lib/demo.coffee'
      ext: 'coffee,js'
      args: [ "--config='#{JSON.stringify(configCore)}'" ]
      watch: [
        'demo/routes'
        'demo/scripts'
        'lib/demo.coffee'
        'user/demo/scripts'
        'user/libs'
      ]
    .on 'restart', (files) ->
      console.log "#{configCore.name} demo restarted due to changes to", files.toString()
    .on 'quit', ->
      console.log "\n#{configCore.name} demo has quit"
      process.exit()


  # => TEST
  # ---
  .command 'test', 'Run your tests', (yargs) ->
    yargs.config configFile.test || {}
    yargs.option 'libs',
      alias: 'l'
      default: '.+'
      desc: 'One or more library names to test'
      type: 'array'
  , (args) ->
    configCore.test =
      libs: args.libs
    require('./test.coffee') configCore


  .argv
