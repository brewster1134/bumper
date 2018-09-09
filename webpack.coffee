Extract = require 'mini-css-extract-plugin'
path = require 'path'
webpack = require 'webpack'

module.exports = (config, helpers) ->
  mode: 'development'
  entry: [
    path.resolve 'server', 'scripts', 'app.coffee'
    'webpack-hot-middleware/client?reload=true&quiet=true'
  ]
  output:
    filename: 'app.js'
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
        options:
          presets: ['babel-preset-env']
      ,
        loader: 'coffee-loader'
      ]
    ,
      test: /\.sass$/
      use: [
        loader: if helpers.isProd then Extract.loader else 'style-loader'
      ,
        loader: 'css-loader'
      ,
        loader: 'sass-loader'
      ]
    ]
