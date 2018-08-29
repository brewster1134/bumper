# DEPENDENCIES
coffee = require 'coffeescript/register'
express = require 'express'
fs = require 'fs'
path = require 'path'
webpack = require 'webpack'
webpackMiddleware = require 'webpack-dev-middleware'
yaml = require 'js-yaml'

# CONFIGURATION
webpackConfig = require '../webpack'
webpackCompiler = webpack(webpackConfig)
configCustom = yaml.safeLoad fs.readFileSync('./config.yaml')
configDefaults =
  host: 'localhost'
  port: 3000
  title: 'Bumper'
  viewEngine: 'pug'
config = Object.assign configDefaults, configCustom

# APP
rootRouter = require('../server/routes/root') config
libsRouter = require('../server/routes/libs') config

# SERVER
demo = express()
demo.use webpackMiddleware webpackCompiler
demo.set 'views', path.join 'server', 'views'
demo.set 'view engine', config.viewEngine
demo.use '/', rootRouter
demo.use '/libs', libsRouter
demo.listen config.port, config.host, ->
  console.log "Bumper Demo running at #{config.host}:#{config.port}"
