express = require 'express'

module.exports = (config, helpers) ->
  router = express.Router()

  # build selected lib
  router.post '/', (req, res) ->
    lib = req.body.lib.split ','

    # build command line
    # console.log 'PWD'
    # shell.exec 'pwd'
    # command = "yarn exec webpack --config ./lib/build_webpack.coffee --output ./tmp/#{helpers.config.nameSafe}.js"
    command = "yarn exec webpack --config ./lib/build_webpack.coffee"
    for lib in lib
      command += " --entry=./usr/lib/#{lib}/#{lib}.js"

    # console.log 'COMMAND'
    # console.log command
    # shell.exec command

    # res.redirect "/demo/#{libNames}"

  # Download bundle
  # router.get '/*', (req, res) ->
  #   libNames = req.params[0].split '/'
  #   lib = helpers.demoBuildLibObject libNames
  #
  #   res.render 'demo',
  #     subtitle: libNames.join ', '
  #     lib: lib

  return router
