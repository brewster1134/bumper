glob = require 'glob'
globEntries = require 'webpack-glob-entry'
Mocha = require 'mocha'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports =
  class Tests
    constructor: (@config, @helpers) ->
      @runWebpack()

    runWebpack: ->
      webpackCompiler = webpack
        mode: 'development'
        target: 'node'
        entry: globEntries "#{@config.packagePath}/libs/**/*_test.+(#{@config.formats.js.join('|')})"
        output:
          filename: '[name].js'
          path: "#{@config.packagePath}/.tmp/test"
        plugins: [
          new Write
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

      webpackCompiler.run =>
        mocha = new Mocha
          ui: 'bdd'
          reporter: 'spec'

        tests = glob.sync "#{@config.packagePath}/.tmp/test/*_test.js"
        for test in tests
          mocha.addFile test

        mocha.run()
