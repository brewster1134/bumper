entry = require 'webpack-glob-entry'
Extract = require 'mini-css-extract-plugin'
path = require 'path'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports = (helpers) ->
  mode: 'development'
  target: 'node'
  entry: entry  path.join(helpers.rootPath, 'app', 'scripts', 'app.coffee'),
                path.join(helpers.rootPath, 'user', 'libs', '**', '*.coffee'),
                path.join(helpers.rootPath, 'user', 'libs', '**', '*.js')
  output:
    filename: '[name].js'
    path: path.join helpers.rootPath, '.tmp'

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
