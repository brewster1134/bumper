# => DEPENDENCIES
# ---
coffee = require 'coffeescript/register'
debMW = require 'webpack-dev-middleware'
express = require 'express'
fs = require 'fs'
hotMW = require 'webpack-hot-middleware'
path = require 'path'
webpack = require 'webpack'
yaml = require 'js-yaml'


# => CONFIGURATION
# ---
rootPath = process.cwd()
userConfig = yaml.safeLoad fs.readFileSync(path.join(rootPath, 'config.yaml'))
config =
  app:
    title: userConfig.app.title || 'Bumper'
    viewEngine: userConfig.app.title || 'pug'
  env:
    host: process.env.BUMPER_HOST || userConfig.env.host || 'localhost'
    port: process.env.BUMPER_PORT || userConfig.env.port || 8383
    rootPath: rootPath
  user: userConfig.user || new Object


# => SERVER
# ---
app = express()

# application
app.set 'view engine', config.app.viewEngine
app.set 'views', path.join('server', 'views')
app.locals.config = config

# helpers
helpers = require(path.join(rootPath, 'server', 'scripts', 'helpers')) config
app.locals.helpers = helpers

# webpack
webpackConfig = require(path.join(rootPath, 'webpack')) config, helpers
webpackCompiler = webpack(webpackConfig)
app.use debMW webpackCompiler
app.use hotMW webpackCompiler

# routes
app.use (req, res, next) ->
  res.locals = app.locals
  next()
app.use '/', require(path.join(rootPath, 'server', 'routes', 'root')) helpers
app.use '/libs', require(path.join(rootPath, 'server', 'routes', 'libs')) helpers

# listen
app.listen config.env.port, config.env.host, ->
  console.log "Bumper app running at #{config.env.host}:#{config.env.port}"
