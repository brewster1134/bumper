downloadsFolder = require 'downloads-folder'
Extract = require 'mini-css-extract-plugin'
fs = require 'fs-extra'
nodeExternals = require 'webpack-node-externals'
webpack = require 'webpack'
Write = require 'write-file-webpack-plugin'

module.exports =
  class Build
    constructor: (@config, @helpers) ->
      @bundleName = "#{@config.nameSafe}_#{@config.version}"
      @downloadsDir = downloadsFolder()
      @tmpDir = "#{@config.packagePath}/.tmp/build"

      @_runWebpack()

    # Get webpack entries based on the split option
    # @return {String|Object} lib path or object of multiple lib paths
    #
    _getEntries: ->
      # build object of each library to build separately
      if @config.build.split
        entries = new Object
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

    # Get combined bundle file name
    # @arg {String} extension
    # @return {String} the name of the bundle file
    #
    _getOutputFile: (extension) ->
      if @config.build.split
        "[name].#{extension}"
      else
        "#{@bundleName}.#{extension}"

    # Compress library and create archive in Downloads directory
    #
    _compressLib: ->
      archiver = require 'archiver'
      archive = archiver 'zip',
        zlib:
          level: 9

      archive.pipe fs.createWriteStream "#{@downloadsDir}/#{@bundleName}.zip"
      archive.directory @tmpDir, false
      archive.finalize()

    # Compile the bundles with webpack
    # @return {Boolean}
    #
    _runWebpack: ->
      webpackCompiler = webpack
        mode: @helpers.getWebpackMode @config.develop
        target: 'web'
        externals: [nodeExternals()]
        entry: @_getEntries()
        output:
          filename: @_getOutputFile 'js'
          path: @tmpDir
        plugins: [
          new Extract
            filename: @_getOutputFile 'css'
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

      webpackCompiler.run =>
        # handle assets
        if @config.build.compress
          @_compressLib()
        else
          fs.copy @tmpDir, "#{@downloadsDir}/#{@bundleName}"

        # log output
        libs = if @config.build.split then @config.build.libs.join(', ') else @config.name
        ext = if @config.build.compress then '.zip' else ''
        @helpers.logMessage "#{libs} libraries built to: #{@bundleName}#{ext}", 'success'
