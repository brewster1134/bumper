entry = require 'webpack-glob-entry'
path = require 'path'
Write = require 'write-file-webpack-plugin'

module.exports = (helpers) ->
  mode: 'none'
  entry: entry  path.join(__dirname, 'user', 'libs', '**', '*_test.coffee'),
                path.join(__dirname, 'user', 'libs', '**', '*_test.js')
  output:
    filename: '[name].js'
    path: path.join __dirname, '.tmp'

  plugins: [
    new Write()
  ]

  module:
    rules: [
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
        loader: 'css-loader'
      ,
        loader: 'sass-loader'
      ]
    ]
