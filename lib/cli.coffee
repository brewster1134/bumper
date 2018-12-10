_ = require 'lodash'
chalk = require 'chalk'
fs = require 'fs'
path = require 'path'
rimraf = require 'rimraf'
yaml = require 'js-yaml'
yargs = require 'yargs'

# set and clean the root directory
process.chdir path.resolve __dirname, '..'
rimraf.sync './.tmp'

# cli config
flair = chalk.bold '------======------'

# import from config file
configFile = try yaml.safeLoad fs.readFileSync 'config.yaml'
configFile ||= try JSON.parse fs.readFileSync 'config.json'
configFile ||= new Object

# get all lib names
# @return {String[]} Array of all lib names
#
getLibs = ->
  libsDir = path.join 'user', 'libs'
  libsDirEntries = fs.readdirSync libsDir
  libs = new Array

  # check libs directory for all subdirectories
  for entry in libsDirEntries
    if fs.statSync(path.join(libsDir, entry)).isDirectory()
      libs.push entry

  return libs

# build core config
name = configFile.name || 'Bumper'
config =
  libs: getLibs()
  name: name
  nameSafe: name.toLowerCase().replace /\W/g, ''
  prod: process.env.NODE_ENV == 'production'
  rootPath: process.cwd()

# assemble all data into each lib data
# @arg originalData {Object} Data to inject into each lib data
# @return {Object} Object with original data for each lib
#
addGenericDataToLibs = (originalData) ->
  libs = config.libs
  libData = new Object
  nonLibData = new Object

  # create skeleton of lib
  for lib in libs
    libData[lib] = new Object

  # separate non-lib data
  for key, value of originalData
    if libs.includes key
      libData[key] = value
    else
      nonLibData[key] = value

  # merge non-lib data into each lib's data
  for lib, value of libData
    libData[lib] = _.merge new Object, nonLibData, libData[lib]

  return libData

# build the data object
# @arg command {String} Name of command
# @arg argsData {Object} Data passed from cli
# @return {Object} Object with full data for each lib
#
buildDataObject = (command, argsData) ->
  libs = config.libs
  libData = new Object

  # create skeleton of lib
  for lib in libs
    libData[lib] = new Object

  # merge in root data into libs
  if configFile.data
    _.merge libData, addGenericDataToLibs(configFile.data)

  # merge in command specific data into libs
  if configFile[command]?.data
    _.merge libData, addGenericDataToLibs(configFile[command].data)

  # merge cli data into libs
  if argsData
    for lib, value of libData
      _.merge libData[lib], argsData

  return libData

# build interface
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

  # handle data key/value pairs
  .option 'data',
    alias: 'd'
    desc: 'Custom key/value pairs (--data foo:bar,bar:baz)'
    type: 'string'
    coerce: (custom) ->
      # parse key/values in the format of --custom key1:value1,key2:value2
      customObject = new Object
      keyValuePairStrings = custom.split ','
      for keyValuePairString in keyValuePairStrings
        keyValuePairArray = keyValuePairString.split ':'
        customObject[keyValuePairArray[0]] = keyValuePairArray[1]

      return customObject


  # => DEMO
  # ---
  .command 'demo', 'Start the demo', (yargs) ->
    yargs.option 'engines',
      default: configFile.demo?.engines || {}
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
      desc: 'Show test results (slower)'
      type: 'boolean'
  , (args) ->
    config.demo =
      data: buildDataObject 'demo', args.data
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
      default: '.+'
      desc: 'One or more library names to test'
      type: 'array'
  , (args) ->
    config.test =
      data: buildDataObject 'test', args.data
      libs: args.libs

    require('./test.coffee') config


  .argv
