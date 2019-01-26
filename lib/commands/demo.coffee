argv = require('yargs-parser') process.argv.slice 2
bodyParser = require 'body-parser'
debMW = require 'webpack-dev-middleware'
express = require 'express'
Extract = require 'mini-css-extract-plugin'
glob = require 'webpack-glob-entry'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

class Demo
  constructor: ->
    @config = JSON.parse argv.config

    # helpers
    Helpers = require("#{@config.bumperPath}/demo/scripts/helpers") @config
    @helpers = new Helpers @config

    # webpack
    webpackConfig = @_webpackConfig()
    webpackCompiler = @_webpackCompiler webpackConfig

    # start server
    @_runServer webpackCompiler

  # the webpack configuration object
  # @return {Object}
  #
  _webpackConfig: ->
    mode: 'development'
    target: 'node'
    devtool: if @config.develop then false else 'eval'
    externals: [nodeExternals()]
    entry: glob "#{@config.bumperPath}/demo/scripts/demo.coffee",
                "#{@config.packagePath}/demo/user_demo.coffee",
                "#{@config.packagePath}/libs/**/*.coffee",
                "#{@config.packagePath}/libs/**/*.js"
    output:
      filename: "[name].js"
      path: "#{@config.packagePath}/.tmp/demo"
    plugins: [
      new Write
      new Extract
      new webpack.HotModuleReplacementPlugin
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
          loader: if @config.develop then 'style-loader' else Extract.loader
        ,
          loader: 'css-loader'
        ,
          loader: 'sass-loader'
        ]
      ]

  # get a webpack compiler instance
  #
  _webpackCompiler: (webpackConfig) ->
    webpack webpackConfig

  # setup and run the web server
  #
  _runServer: (compiler) ->
    demo = express()
    demo.use debMW compiler

    # config
    demo.set 'view engine', 'pug'
    demo.set 'views', "#{@config.bumperPath}/demo/views"

    # routes
    demo.use bodyParser.urlencoded
      extended: false
    demo.use express.static "#{@config.bumperPath}/demo/images"
    demo.use (req, res, next) =>
      res.locals.config = @config
      res.locals.helpers = @helpers
      res.locals.view = req.url.match(/^\/(\w+)?/)[1]
      next()
    demo.use '/', require("#{@config.bumperPath}/demo/routes/root") @config, @helpers
    demo.use '/build', require("#{@config.bumperPath}/demo/routes/build") @config, @helpers
    demo.use '/demo', require("#{@config.bumperPath}/demo/routes/demo") @config, @helpers

    # listen
    demo.listen @config.demo.port, @config.demo.host

# run demo
new Demo
