module.exports = ->
  express = require 'express'
  router = express.Router()

  router.get '/', (req, res, next) ->
    res.render 'root'

  return router

return module.exports
