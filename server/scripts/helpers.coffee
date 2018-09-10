consolidate = require 'consolidate'
fs = require 'fs'
path = require 'path'

module.exports = (config) ->
  class Helper
    isProd: process.env.NODE_ENV == 'production'
    rootPath: config.env.rootPath

    getLibFile: (libName, libType, isDemo) ->
      libRootPath = path.join @rootPath, 'libs', libName
      libFileName = if isDemo then "#{libName}_demo" else libName
      rawFile = null

      switch libType
        when 'css'
          console.log 'get CSS'

        when 'html'
          for template in config.app.templates
            templateFile = path.join libRootPath, "#{libFileName}.#{template}"

            if fs.existsSync templateFile
              consolidate[template] templateFile, config.libs[libName] || {}, (err, html) ->
                rawFile = err || html
              return rawFile

        when 'js'
          console.log 'get JS'

      return rawFile

  return new Helper

return module.exports
