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
  run: ->
    @config = JSON.parse argv.config

    # helpers
    Helpers = require("#{@config.bumperPath}/demo/scripts/helpers") @config
    @helpers = new Helpers @config

    # webpack
    webpackCompiler = webpack @_getWebpackConfig()

    # start server
    @_runServer webpackCompiler

  # the webpack configuration object
  # @return {Object}
  #
  _getWebpackConfig: ->
    devtool: 'source-map'
    externals: [nodeExternals()]
    mode: 'development'
    target: 'node'
    entry: glob "#{@config.bumperPath}/demo/scripts/demo.coffee",
                "#{@config.projectPath}/demo/user_demo.coffee",
                "#{@config.projectPath}/libs/**/*.coffee",
                "#{@config.projectPath}/libs/**/*.js"
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
          options:
            sourceMap: true
        ,
          loader: 'css-loader'
          options:
            sourceMap: true
        ,
          loader: 'sass-loader'
          options:
            sourceMap: true
        ]
      ]
    optimization:
      minimize: false
      noEmitOnErrors: false
    output:
      filename: '[name].js'
      path: "#{@config.projectPath}/.tmp/demo"
    plugins: [
      new Write
      new Extract
        filename: '[name].css'
      new webpack.HotModuleReplacementPlugin
    ]
    resolve:
      modules: [
        @config.bumperPath
        @config.projectPath
      ]

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
new Demo().run()
