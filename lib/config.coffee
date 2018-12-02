_ = require 'lodash'
fs = require 'fs'
yaml = require 'js-yaml'

module.exports = (args) ->
  userConfig = yaml.safeLoad fs.readFileSync 'config.yaml'
  name = userConfig.name || 'Bumper'

  config =
    rootPath: process.cwd()
    name: name
    nameSafe: name.toLowerCase().replace /\W/g, ''
    demo:
      host: process.env.BUMPER_HOST || userConfig.demo.host || args.demo.host
      port: process.env.BUMPER_PORT || userConfig.demo.port || args.demo.port
      tests: userConfig.demo.tests || args.demo.tests
      engines:
        css: _.union userConfig.demo.engines.css || new Array, ['sass', 'css']
        html: _.union userConfig.demo.engines.html || new Array, ['pug', 'md', 'html']
        js: _.union userConfig.demo.engines.js || new Array, ['coffee', 'js']
    libs: userConfig.libs || new Object
