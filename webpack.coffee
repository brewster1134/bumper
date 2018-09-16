entry = require 'webpack-glob-entry'
Extract = require 'mini-css-extract-plugin'
webpack = require 'webpack'

module.exports = (helpers) ->
  mode: 'development'
  entry: entry  "#{helpers.rootPath}/app/scripts/*.coffee",
                "#{helpers.rootPath}/libs/**/*_demo.coffee",
                "#{helpers.rootPath}/libs/**/*_demo.js"
  output:
    filename: '[name].js'
  plugins: [
    new Extract()
    new webpack.HotModuleReplacementPlugin()
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
