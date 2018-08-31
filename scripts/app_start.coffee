# => DEPENDENCIES
# ---
coffee = require 'coffeescript/register'
express = require 'express'
fs = require 'fs'
path = require 'path'
webpack = require 'webpack'
webpackMiddleware = require 'webpack-dev-middleware'
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

# webpack
webpackConfig = require path.join(rootPath, 'webpack')
webpackCompiler = webpack(webpackConfig)
app.use webpackMiddleware webpackCompiler

# helpers
app.locals.helpers = require(path.join(rootPath, 'server', 'scripts', 'helpers')) app.locals.config

# routes
rootRouter = require(path.join(rootPath, 'server', 'routes', 'root')) app.locals.config.app, app.locals.helpers
libsRouter = require(path.join(rootPath, 'server', 'routes', 'libs')) app.locals.config.app, app.locals.helpers
app.use '/', rootRouter
app.use '/libs', libsRouter

# listen
app.listen config.env.port, config.env.host, ->
  console.log "Bumper app running at #{config.env.host}:#{config.env.port}"
