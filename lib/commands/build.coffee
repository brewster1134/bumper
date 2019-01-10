Extract = require 'mini-css-extract-plugin'
fs = require 'fs-extra'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports =
  class Build
    constructor: (@config, @helpers) ->
      @runWebpack()

    # Get webpack entries based on the split option
    # @arg {Array} libs - an array of the lib to get entries for
    # @arg {Boolean} split - the split option
    # @return {String|Object} lib path or object of multiple lib paths
    #
    getEntries: ->
      entries = new Object

      if @config.build.split
        for lib in @config.build.libs
          entries[lib] = @helpers.getLibSource lib
      else
        bundlePath = "#{@config.packagePath}/.tmp/build/#{@config.nameSafe}_#{@config.version}.js"
        bundleWrite = fs.createWriteStream bundlePath
        for lib in @config.build.libs
          bundleWrite.write "import #{lib} from '#{@helpers.getLibSource(lib)}'\n"
        bundleWrite.end()

        entries = bundlePath

      return entries

    # Get combined bundle file name
    # @return {String} the name of the bundle file
    #
    getOutputFile: ->
      if @config.build.split then "[name].js" else "#{@config.nameSafe}_#{@config.version}.js"

    # Compile the bundles with webpack
    # @return {Boolean}
    #
    runWebpack: ->
      webpackCompiler = webpack
        mode: @helpers.getMode @helpers.getConfigFileValue 'build', 'develop'
        target: 'web'
        externals: [nodeExternals()]
        entry: @getEntries()
        output:
          filename: @getOutputFile()
          path: "#{@config.packagePath}/.tmp/build"
        plugins: [
          new Extract()
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
              loader: Extract.loader
            ,
              loader: 'css-loader'
            ,
              loader: 'sass-loader'
            ]
          ]

      webpackCompiler.run ->
        console.log 'runnn'
        # Interpolate files
        # BuildFiles = glob '.tmp/build/*.js'
        # For buildName, buildPath of buildFiles
        #   try
        #     @helpers.interpolateFile path.join(@config.packagePath, buildPath), @config.build.globals[buildName]
        #   catch error
        #     @helpers.logMessage "template variable #{error.message}", 'error'
