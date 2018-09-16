express = require 'express'
router = express.Router()

module.exports = (helpers) ->
  # ALL: require all libs

  # SELECT: require all specified libs
  router.get '/*', (req, res, next) ->
    libNames = req.params[0].split /\W/
    libs = new Object

    for libName in libNames
      lib = libs[libName] =
        js: "/#{libName}_demo.js"
        template: helpers.includeDemoHtml libName

    res.render 'libs',
      subtitle: Object.keys(libNames).join ', '
      libs: libs

  return router
