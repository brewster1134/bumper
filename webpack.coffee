coffee = require 'coffeescript/register'
Extract = require 'mini-css-extract-plugin'
path = require 'path'
Write = require 'write-file-webpack-plugin'

module.exports =
  mode: 'development'
  entry:
    app_scripts: path.resolve 'server', 'scripts', 'app.coffee'
    app_styles: path.resolve 'server', 'styles', 'app.sass'
  output:
    path: path.resolve '.tmp'
    filename: '[name].js'
  plugins: [
    new Write()
    new Extract()
  ]
  module:
    rules: [
      test: /\.coffee$/
      use: [
        loader: 'babel-loader'
        options:
          presets: ['babel-preset-env']
      ,
        loader: 'coffee-loader'
      ]
    ,
      test: /\.sass/
      use: [
        loader: Extract.loader
      ,
        loader: 'css-loader'
      ,
        loader: 'sass-loader'
      ]
    ]
