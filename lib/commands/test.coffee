glob = require 'glob'
globEntries = require 'webpack-glob-entry'
Mocha = require 'mocha'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports =
  class Test
    run: ->
      @config = global.bumper.config
      @libsDelimited = "+(#{@config.test.libs.join('|')})"
      @formatsDelimited = "+(#{@config.formats.js.join('|')})"
      @_runWebpack @_getWebpackConfig()

    _getWebpackConfig: ->
      devtool: 'source-map'
      entry: globEntries "#{@config.projectPath}/libs/#{@libsDelimited}/*_test.#{@formatsDelimited}"
      externals: [nodeExternals()]
      mode: 'development'
      target: 'node'
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
      optimization:
        minimize: true
        noEmitOnErrors: true
      output:
        filename: '[name].js'
        path: "#{@config.projectPath}/.tmp/test"
      plugins: [
        new Write
      ]
      resolve:
        modules: [
          @config.bumperPath
          @config.projectPath
        ]

    # Compile the bundles with webpack
    #
    _runWebpack: (webpackConfig) ->
      compiler = webpack webpackConfig
      compiler.run => @_afterBuildSuccess()

    # callback after webpack completes successfully
    #
    _afterBuildSuccess: ->
      mocha = new Mocha
        ui: 'bdd'
        reporter: 'spec'

      tests = glob.sync "#{@config.projectPath}/.tmp/test/#{@libsDelimited}_test.js"
      for test in tests
        mocha.addFile test

      mocha.run()
