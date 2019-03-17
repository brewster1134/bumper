chalk = require 'chalk'
consolidate = require 'consolidate'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'

module.exports =
  class Config
    build: ->
      # get npm json files
      bumperPath = path.resolve __dirname, '..'
      projectPath = process.cwd()

      # get package.json files
      bumperJson = @_getPackageJson bumperPath
      projectJson = @_getPackageJson projectPath

      # get user configuration
      configFile = @_getConfigFile projectPath

      # additional config
      name = configFile.name || projectJson.name || 'Bumper'
      jsFormats = [ 'coffee', 'js' ]

      # get package libraries
      libs = @_getlibs projectPath, jsFormats
      if !Object.keys(libs).length
        global.bumper.log 'No valid Bumper libraries found',
          exit: 1
          type: 'error'

      # return all config values
      return @config =
        bumperPath: bumperPath
        file: configFile
        flair: chalk.bold '------======------'
        libs: libs
        name: name
        nameSafe: name.toLowerCase().replace /\W/g, '_'
        projectPath: projectPath
        verbose: configFile.verbose == true
        version: projectJson.version
        formats:
          css: [ 'css', 'sass', 'scss' ]
          docs: [ 'md' ]
          html: Object.keys consolidate
          js: jsFormats

    # get package.json
    # @arg {String} path - absolute directory path
    # @return {Object}
    #
    _getPackageJson: (path) ->
      try
        return require "#{path}/package.json"
      catch err
        global.bumper.log 'No `package.json` found',
          exit: false
          type: 'alert'

    # Get user configuration
    # @arg {String} projectPath - path to bumper package
    # @return {Object}
    #
    _getConfigFile: (projectPath) ->
      # look for yaml file
      configFile = try yaml.safeLoad fs.readFileSync "#{projectPath}/config.yaml"

      # look for json file
      configFile ||= try JSON.parse fs.readFileSync "#{projectPath}/config.json"

      return configFile || new Object

    # Get all current package libraries
    # @return {Object} key: library name, value: library source path
    #
    _getlibs: (projectPath, formats) ->
      libFormats = formats.join '|'
      libs = new Object

      try
        files = fs.readdirSync "#{projectPath}/libs"
      catch err
        global.bumper.log 'No `libs` directory found',
          exit: 1
          type: 'error'

      for file in files
        libGlobPath = "#{projectPath}/libs/#{file}/#{file}.+(#{libFormats})"
        libPath = glob.sync(libGlobPath)[0]

        if libPath
          libs[file] = libPath

      return libs
