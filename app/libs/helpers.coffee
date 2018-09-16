_ = require 'lodash'
consolidate = require 'consolidate'
fs = require 'fs'
path = require 'path'

module.exports = (config) ->
  class Helper
    isProd: process.env.NODE_ENV == 'production'
    rootPath: config.env.rootPath

    # Build a single string from multiple strings
    # @function
    # @param {string} - String(s) to be concatenated
    # @return {string}
    #
    buildTitle: (strings...) ->
      _.compact(strings).join(': ')

    # Renders the demo for a given library
    # * @function
    # * @param {string} libName - The name of the library
    # * @return {string} - Raw html
    #
    includeDemoHtml: (libName) ->
      rawFile = null
      libRootPath = path.join @rootPath, 'libs', libName

      for engine in config.app.engines.html
        libFilePath = path.join libRootPath, "#{libName}_demo.#{engine}"

        if fs.existsSync libFilePath
          consolidate[engine] libFilePath, config.libs[libName] || {}, (err, html) ->
            rawFile = err || html
          return rawFile

  return new Helper
