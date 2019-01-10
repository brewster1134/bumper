chalk = require 'chalk'
glob = require 'webpack-glob-entry'
jest = require 'jest'
path = require 'path'
webpack = require 'webpack'

module.exports =
  class Tests
    constructor: (@config, @helpers) ->
      @runWebpack()

    runWebpack: ->
      webpackCompiler = webpack
        mode: 'none'
        entry: glob path.join(@config.packagePath, 'libs', '**', '*_test.+(coffee|js)')
        output:
          filename: '[name].js'
          path: path.join @config.packagePath, '.tmp', 'test'
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

      webpackCompiler.run =>
        # run tests
        regexlib = @config.test.libs.join '|'
        jest.run "--watch --colors --testRegex='\.tmp\/test\/(#{regexlib})_test\.js$'"
