express = require 'express'
router = express.Router()

module.exports = (helpers) ->
  # ALL: require all libs

  # SELECT: require all specified libs
  router.get '/*', (req, res, next) ->
    libsNames = req.params[0].split /\W/
    libs = new Object

    for libName in libsNames
      lib = libs[libName] =
        css: new Object
        html: new Object
        js: new Object

      # CSS: lib

      # CSS: demo

      # HTML: demo
      lib.html.demo = helpers.getLibFile libName, 'html', true

      # JS: lib

      # JS: demo

    res.render 'libs',
      subtitle: Object.keys(libs).join ', '
      libs: libs

  return router

return module.exports
