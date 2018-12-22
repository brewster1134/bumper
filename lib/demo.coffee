argv = require('yargs-parser') process.argv.slice 2
bodyParser = require 'body-parser'
debMW = require 'webpack-dev-middleware'
express = require 'express'
Extract = require 'mini-css-extract-plugin'
glob = require 'webpack-glob-entry'
nodeExternals = require 'webpack-node-externals'
path = require 'path'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'


# => CONFIGURATION
# ---
config = JSON.parse argv.config


# => WEBPACK
# ---
webpackCompiler = webpack
  mode: 'development'
  target: 'node'
  devtool: if config.prod then 'eval' else false
  externals: [nodeExternals()]
  entry: glob path.join(config.rootPath, 'demo', 'scripts', 'demo.coffee'),
              path.join(config.rootPath, 'user', 'libs', '**', '*.coffee'),
              path.join(config.rootPath, 'user', 'libs', '**', '*.js')
  output:
    filename: '[name].js'
    path: path.join config.rootPath, '.tmp', 'demo'
  plugins: [
    new Extract()
    new webpack.HotModuleReplacementPlugin()
    new Write()
  ]
  module:
    rules: [
      test: /\.pug$/
      use: [
        loader: 'pug-loader'
      ]
    ,
      test: /\.coffee$/
      use: [
        loader: 'babel-loader'
      ,
        loader: 'coffee-loader'
      ]
    ,
      test: /\.js$/
      use: [
        loader: 'babel-loader'
      ]
    ,
      test: /\.(sass|css)$/
      use: [
        loader: if config.prod then Extract.loader else 'style-loader'
      ,
        loader: 'css-loader'
      ,
        loader: 'sass-loader'
      ]
    ]


# => SERVER
# ---
demo = express()
demo.use debMW webpackCompiler

# config
demo.set 'view engine', 'pug'
demo.set 'views', path.join 'demo', 'views'

# helpers
helpers = require(path.join(config.rootPath, 'demo', 'scripts', 'helpers')) config
demo.locals.helpers = helpers

# routes
demo.use bodyParser.urlencoded
  extended: false
demo.use express.static path.join 'demo', 'images'
demo.use (req, res, next) ->
  res.locals = demo.locals
  res.locals.view = req.url.match(/^\/(\w+)?/)[1]
  next()
demo.use '/', require(path.join(config.rootPath, 'demo', 'routes', 'root')) helpers
demo.use '/build', require(path.join(config.rootPath, 'demo', 'routes', 'build')) helpers
demo.use '/demo', require(path.join(config.rootPath, 'demo', 'routes', 'demo')) helpers

# listen
demo.listen config.demo.port, config.demo.host, ->
  helpers.logMessage "#{config.name} demo running at #{config.demo.host}:#{config.demo.port}", 'info'
