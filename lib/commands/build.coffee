Extract = require 'mini-css-extract-plugin'
fs = require 'fs-extra'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

Logger = require '../logger.coffee'

module.exports =
  class Build
    run: ->
      @config = global.bumper.config
      @bundleName = "#{@config.nameSafe}_#{@config.version}"
      @downloadsDir = @config.build.output
      @tmpDir = "#{@config.projectPath}/.tmp/build"
      @distDir = "#{@tmpDir}/dist"
      webpackConfig = @_getWebpackConfig()

      fs.ensureDirSync @distDir

      # initialize zip plugin if compress option is set
      if @config.build.compress
        Zip = require 'zip-webpack-plugin'

        webpackConfig.plugins.push new Zip
          filename: @bundleName
          path: @downloadsDir

      @_runWebpack webpackConfig

    # The webpack configuration object
    # @return {object}
    #
    _getWebpackConfig: ->
      devtool: 'source-map'
      entry: @_getEntries()
      externals: [nodeExternals()]
      mode: @_getWebpackMode()
      target: 'web'
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
            loader: Extract.loader
            options:
              sourceMap: true
          ,
            loader: 'css-loader'
            options:
              sourceMap: true
          ,
            loader: 'sass-loader'
            options:
              sourceMap: true
          ]
        ]
      optimization:
        minimize: !@config.develop
        noEmitOnErrors: !@config.develop
      output:
        filename: @_getOutputFile 'js'
        path: @distDir
      plugins: [
        new Write
        new Extract
          filename: @_getOutputFile 'css'
      ]
      resolve:
        modules: [
          @config.bumperPath
          @config.projectPath
        ]

    # Get webpack entries based on the split option
    # @return {string|object} lib path or object of multiple lib paths
    #
    _getEntries: ->
      # build object with each project library name & path
      if @config.build.split
        entries = {}
        for lib in @config.build.libs
          entries[lib] = @config.libs[lib]

      # write js file with import for each library to build
      else
        entries = "#{@tmpDir}/#{@bundleName}.js"
        bundleWrite = fs.createWriteStream entries
        for lib in @config.build.libs
          bundleWrite.write "import #{lib} from '#{@config.libs[lib]}'\n"
        bundleWrite.end()

      return entries

    # Get webpack mode configuration value
    # https://webpack.js.org/concepts/mode/
    # @return {string}
    #
    _getWebpackMode: ->
      if @config.develop
        return 'development'
      else
        return 'production'

    # Get combined bundle file name
    # @arg {string} extension
    # @return {string} the name of the bundle file
    #
    _getOutputFile: (extension) ->
      if @config.build.split
        "[name].#{extension}"
      else
        "#{@bundleName}.#{extension}"

    # Compile the bundles with webpack
    # @return {boolean}
    #
    _runWebpack: (webpackConfig) ->
      compiler = webpack webpackConfig

      # webpack success callback
      compiler.run =>
        # if uncompressed, move asset directory
        if !@config.build.compress
          @_moveLib()

        # log output
        @_logOutput()

    # Move built assets to downloads directory
    #
    _moveLib: ->
      fs.copySync @distDir, "#{@downloadsDir}/#{@bundleName}"

    # Log output to user
    #
    _logOutput: ->
      builtName = if @config.build.split then @config.build.libs.join(', ') else @config.name
      fileExt = if @config.build.compress then '.zip' else ''

      new Logger "#{builtName} libraries built to: #{@bundleName}#{fileExt}",
        exit: 0
        type: 'success'
