express = require 'express'
fs = require 'fs'
path = require 'path'
router = express.Router()

module.exports = (helpers) ->
  # ALL: list all libs
  router.get '/', (req, res, next) ->
    res.render 'libs_index',
      libs: helpers.libsGetPaths()

  # SELECT: require user-selected libs
  router.post '/', (req, res, next) ->
    libNames = Object.keys(req.body).join '/'
    res.redirect "/libs/#{libNames}"

  router.get '/*', (req, res, next) ->
    libNames = req.params[0].split /\W/
    libs = await helpers.libsBuildObject libNames, req

    res.render 'libs',
      subtitle: libNames.join ', '
      libs: libs

  return router
