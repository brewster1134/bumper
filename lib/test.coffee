glob = require 'webpack-glob-entry'
jest = require 'jest'
path = require 'path'
webpack = require 'webpack'

module.exports = (config, args) ->
  webpackCompiler = webpack
    mode: 'none'
    entry: glob path.join(config.rootPath, 'user', 'libs', '**', '*_test.coffee'),
                path.join(config.rootPath, 'user', 'libs', '**', '*_test.js')
    output:
      filename: '[name].js'
      path: path.join config.rootPath, '.tmp'
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

  webpackCompiler.run ->
    regexLibs = args.libs.join '|'
    jest.run "--verbose --colors --testRegex '\.tmp\/(#{regexLibs})_test.js$'"
