module.exports = (config) ->
  express = require 'express'
  router = express.Router()

  # ALL: require all libs
  router.get '/', (req, res, next) ->
    libs = {}
    libs.bar = require '../../client/src/bar/bar'
    console.log 'LIBS!', libs
    res.render 'libs',
      libs: libs

  # router.get '/', (req, res, next) ->
  #   libs = req.params[0].split('/')
  #   res.render 'root',
  #     title: config.title

  return router

return module.exports

# express = require 'express'
# router = express.Router()
#
# router.get '/', (req, res, next) ->
#   res.render 'index',
#     title: 'Express'
#
# module.exports = router
#
#
#
#
#
# demo.get('/libs/*', (req, res) => {
#   var libs = req.params[0].split('/');
#   res.render('libs', { libs: libs });
# });
#
