express = require 'express'

module.exports = (config, helpers) ->
  router = express.Router()

  router.get '/', (req, res) ->
    res.render 'root'

  return router
