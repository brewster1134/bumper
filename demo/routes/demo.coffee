express = require 'express'

module.exports = (helpers) ->
  router = express.Router()

  # list all libs
  router.get '/', (req, res) ->
    res.render 'libs',
      libs: helpers.libs

  # render selected libs
  router.get '/*', (req, res) ->
    libNames = req.params[0].split '/'
    libs = await helpers.demoBuildLibObject libNames...

    res.render 'demo',
      subtitle: libNames.join ', '
      libs: libs

  # request selected libs
  router.post '/', (req, res) ->
    libNames = Object.keys(req.body).join '/'
    res.redirect "/demo/#{libNames}"

  return router
