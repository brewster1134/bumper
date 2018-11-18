express = require 'express'

module.exports = ->
  router = express.Router()

  router.get '/', (req, res) ->
    res.render 'root'

  return router
