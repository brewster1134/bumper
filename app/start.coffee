# => DEPENDENCIES
# ---
argv = require('yargs-parser') process.argv.slice 2
bodyParser = require 'body-parser'
debMW = require 'webpack-dev-middleware'
express = require 'express'
path = require 'path'
webpack = require 'webpack'


# => CONFIGURATION
# ---
config = JSON.parse argv.config


# => SERVER
# ---
app = express()

# application
app.set 'view engine', 'pug'
app.set 'views', path.join('app', 'views')
app.locals.config = config

# helpers
helpers = require(path.join(config.rootPath, 'app', 'scripts', 'helpers')) config
app.locals.helpers = helpers

# webpack
webpackConfig = require(path.join(config.rootPath, 'webpack.app')) helpers
webpackCompiler = webpack(webpackConfig)
app.use debMW webpackCompiler

# routes
app.use bodyParser.urlencoded
  extended: false
app.use express.static path.join config.rootPath, 'app', 'images'
app.use (req, res, next) ->
  res.locals = app.locals
  res.locals.view = req.url.match(/^\/(\w+)?/)[1]
  next()
app.use '/', require(path.join(config.rootPath, 'app', 'routes', 'root')) helpers
app.use '/build', require(path.join(config.rootPath, 'app', 'routes', 'build')) helpers
app.use '/demo', require(path.join(config.rootPath, 'app', 'routes', 'demo')) helpers

# listen
app.listen config.app.port, config.app.host, ->
  console.log "Bumper app running at #{config.app.host}:#{config.app.port}"
