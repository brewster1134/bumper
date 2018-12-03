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
demo = express()

# demo
demo.set 'view engine', 'pug'
demo.set 'views', path.join 'demo', 'views'
demo.locals.config = config

# helpers
helpers = require(path.join(config.rootPath, 'demo', 'scripts', 'helpers')) config
demo.locals.helpers = helpers

# webpack
webpackConfig = require(path.join(config.rootPath, 'lib', 'demo_webpack')) config
webpackCompiler = webpack webpackConfig
demo.use debMW webpackCompiler

# routes
demo.use bodyParser.urlencoded
  extended: false
demo.use express.static path.join config.rootPath, 'demo', 'images'
demo.use (req, res, next) ->
  res.locals = demo.locals
  res.locals.view = req.url.match(/^\/(\w+)?/)[1]
  next()
demo.use '/', require(path.join(config.rootPath, 'demo', 'routes', 'root')) helpers
demo.use '/build', require(path.join(config.rootPath, 'demo', 'routes', 'build')) helpers
demo.use '/demo', require(path.join(config.rootPath, 'demo', 'routes', 'demo')) helpers

# listen
demo.listen config.demo.port, config.demo.host, ->
  console.log "#{config.name} demo running at #{config.demo.host}:#{config.demo.port}"
