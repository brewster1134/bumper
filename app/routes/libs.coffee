express = require 'express'
fs = require 'fs'
path = require 'path'
router = express.Router()

module.exports = (helpers) ->
  # ALL: list all libs
  router.get '/', (req, res, next) ->
    libsDir = path.join helpers.rootPath, 'libs'
    libsDirEntries = fs.readdirSync libsDir
    libs = new Array

    # check libs directory for all subdirectories
    for entry in libsDirEntries
      if fs.statSync(path.join(libsDir, entry)).isDirectory()
        libs.push entry

    res.render 'libs_index',
      libs: libs

  # SELECT: require user-selected libs
  router.post '/', (req, res, next) ->
    libNames = Object.keys(req.body).join '/'
    res.redirect "/libs/#{libNames}"

  router.get '/*', (req, res, next) ->
    libNames = req.params[0].split /\W/
    libs = helpers.libsBuildObject libNames

    res.render 'libs',
      subtitle: libNames.join ', '
      libs: libs

  return router
