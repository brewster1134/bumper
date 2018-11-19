_ = require 'lodash'
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

module.exports = (args) ->
  rootPath = process.cwd()
  userConfig = yaml.safeLoad fs.readFileSync path.join(rootPath, 'config.yaml')

  config =
    name: userConfig.name || 'Bumper'
    rootPath: rootPath
    app:
      host: process.env.BUMPER_HOST || userConfig.app.host || args.app.host
      port: process.env.BUMPER_PORT || userConfig.app.port || args.app.port
      tests: userConfig.app.tests || args.app.tests
      engines:
        css: _.union userConfig.app.engines.css || new Array, ['sass', 'css']
        html: _.union userConfig.app.engines.html || new Array, ['pug', 'md', 'html']
        js: _.union userConfig.app.engines.js || new Array, ['coffee', 'js']
    libs: userConfig.libs || new Object
