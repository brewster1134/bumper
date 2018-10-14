# => DEPENDENCIES
# ---
_ = require 'lodash'
argv = require('yargs-parser') process.argv.slice 2
bodyParser = require 'body-parser'
coffee = require 'coffeescript/register'
debMW = require 'webpack-dev-middleware'
express = require 'express'
fs = require 'fs'
path = require 'path'
webpack = require 'webpack'
yaml = require 'js-yaml'


# => CONFIGURATION
# ---
rootPath = process.cwd()
userConfig = yaml.safeLoad fs.readFileSync path.join(rootPath, 'config.yaml')
config =
  app:
    title: userConfig.app.title || 'Bumper'
    engines:
      css: _.union userConfig.app.engines.css || new Array, ['sass', 'css']
      html: _.union userConfig.app.engines.html || new Array, ['pug', 'md', 'html']
      js: _.union userConfig.app.engines.js || new Array, ['coffee', 'js']
  env:
    host: process.env.BUMPER_HOST || userConfig.env.host || argv.host
    port: process.env.BUMPER_PORT || userConfig.env.port || argv.port
    tests: userConfig.env.tests || argv.tests == 'true'
    rootPath: rootPath
  libs: userConfig.libs || new Object


# => SERVER
# ---
app = express()

# application
app.set 'view engine', 'pug'
app.set 'views', path.join('app', 'views')
app.locals.config = config

# helpers
helpers = require(path.join(rootPath, 'app', 'scripts', 'helpers')) config
app.locals.helpers = helpers

# webpack
webpackConfig = require(path.join(rootPath, 'webpack.app')) helpers
webpackCompiler = webpack(webpackConfig)
app.use debMW webpackCompiler

# routes
app.use bodyParser.urlencoded
  extended: false
app.use express.static path.join rootPath, 'app', 'images'
app.use (req, res, next) ->
  res.locals = app.locals
  res.locals.view = req.url.match(/^\/(\w+)?/)[1]
  next()
app.use '/', require(path.join(rootPath, 'app', 'routes', 'root')) helpers
app.use '/demo', require(path.join(rootPath, 'app', 'routes', 'demo')) helpers

# listen
app.listen config.env.port, config.env.host, ->
  console.log "Bumper app running at #{config.env.host}:#{config.env.port}"
