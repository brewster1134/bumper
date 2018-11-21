entry = require 'webpack-glob-entry'
Extract = require 'mini-css-extract-plugin'
nodeExternals = require 'webpack-node-externals'
path = require 'path'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports = (helpers) ->
  mode: 'development'
  target: 'node'
  externals: [nodeExternals()]
  entry: entry  path.join(helpers.config.rootPath, 'demo', 'scripts', 'demo.coffee'),
                path.join(helpers.config.rootPath, 'user', 'libs', '**', '*.coffee'),
                path.join(helpers.config.rootPath, 'user', 'libs', '**', '*.js')
  output:
    filename: '[name].js'
    path: path.join helpers.config.rootPath, '.tmp'

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
        loader: if helpers.isProd then Extract.loader else 'style-loader'
      ,
        loader: 'css-loader'
      ,
        loader: 'sass-loader'
      ]
    ]
