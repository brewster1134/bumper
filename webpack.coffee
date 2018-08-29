coffee = require 'coffeescript/register'
Extract = require 'mini-css-extract-plugin'
path = require 'path'
Write = require 'write-file-webpack-plugin'

module.exports =
  mode: 'development'
  entry:
    demo_scripts: path.resolve 'server', 'scripts', 'demo.coffee'
    demo_styles: path.resolve 'server', 'styles', 'demo.sass'
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
