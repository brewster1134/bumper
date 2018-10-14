express = require 'express'
router = express.Router()

module.exports = (helpers) ->
  # list all libs
  router.get '/', (req, res, next) ->
    res.render 'libs',
      libs: helpers.demoGetLibPaths()

  # request selected libs
  router.post '/', (req, res, next) ->
    libNames = Object.keys(req.body).join '/'
    res.redirect "/demo/#{libNames}"

  # render selected libs
  router.get '/*', (req, res, next) ->
    libNames = req.params[0].split '/'
    libs = helpers.demoBuildLibObject libNames

    res.render 'demo',
      subtitle: libNames.join ', '
      libs: libs

  return router
