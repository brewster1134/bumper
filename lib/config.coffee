_ = require 'lodash'
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

module.exports = (args) ->
  rootPath = process.cwd()
  userConfig = yaml.safeLoad fs.readFileSync path.join rootPath, 'config.yaml'
  name = userConfig.name || 'Bumper'

  config =
    name: name.replace /\s/g, ''
    nameSafe: name.toLowerCase().replace /\W/g, ''
    rootPath: rootPath
    demo:
      host: process.env.BUMPER_HOST || userConfig.demo.host || args.demo.host
      port: process.env.BUMPER_PORT || userConfig.demo.port || args.demo.port
      tests: userConfig.demo.tests || args.demo.tests
      engines:
        css: _.union userConfig.demo.engines.css || new Array, ['sass', 'css']
        html: _.union userConfig.demo.engines.html || new Array, ['pug', 'md', 'html']
        js: _.union userConfig.demo.engines.js || new Array, ['coffee', 'js']
    libs: userConfig.libs || new Object
