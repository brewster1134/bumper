module.exports = (config) ->
  helpers =
    rootPath: config.env.rootPath
    isProd: process.env.NODE_ENV == 'production'

  return helpers

return module.exports
