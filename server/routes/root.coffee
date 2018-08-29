module.exports = (config) ->
  express = require 'express'
  router = express.Router()

  router.get '/', (req, res, next) ->
    res.render 'root',
      title: config.title

  return router

return module.exports
