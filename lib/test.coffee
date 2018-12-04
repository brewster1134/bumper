glob = require 'webpack-glob-entry'
jest = require 'jest'
path = require 'path'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports = (config, args) ->
  console.log webpack
    mode: 'none'
    entry: glob path.join(config.rootPath, 'user', 'libs', '**', '*_test.coffee'),
                path.join(config.rootPath, 'user', 'libs', '**', '*_test.js')
    output:
      filename: '[name].js'
      path: path.join config.rootPath, '.tmp'
    plugins: [
      new Write
        force: true
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
      # ,
      #   test: /\.(sass|css)$/
      #   use: [
      #     loader: 'css-loader'
      #   ,
      #     loader: 'sass-loader'
      #   ]
      ]

  regexLibs = args.libs.join '|'
  jest.run "--verbose --colors --testRegex '\.tmp\/(#{regexLibs})_test.js$'"
