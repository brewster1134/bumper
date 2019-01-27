glob = require 'glob'
globEntries = require 'webpack-glob-entry'
Mocha = require 'mocha'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports =
  class Tests
    constructor: (@config, @helpers) ->
      webpackConfig = @_getWebpackConfig()
      webpackCompiler = @_getWebpackCompiler webpackConfig
      @_runWebpack webpackCompiler

    _getWebpackConfig: ->
      mode: 'development'
      target: 'node'
      entry: globEntries  "#{@config.packagePath}/libs/**/*_test.+(#{@config.formats.js.join('|')})"
      externals: [nodeExternals()]
      output:
        filename: '[name].js'
        path: "#{@config.packagePath}/.tmp/test"
      plugins: [
        new Write
      ]
      resolve:
        modules: [
          @config.bumperPath
          'node_modules'
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

    _getWebpackCompiler: (webpackConfig) ->
      webpack webpackConfig

    _runWebpack: (webpackCompiler) ->
      webpackCompiler.run =>
        mocha = new Mocha
          ui: 'bdd'
          reporter: 'spec'

        tests = glob.sync "#{@config.packagePath}/.tmp/test/*_test.js"
        for test in tests
          mocha.addFile test

        mocha.run()
