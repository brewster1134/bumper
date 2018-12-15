glob = require 'webpack-glob-entry'
jest = require 'jest'
path = require 'path'
webpack = require 'webpack'

module.exports = (config) ->
  Helpers = require(path.join(config.rootPath, 'lib', 'helpers')) config
  helpers = new Helpers

  webpackCompiler = webpack
    mode: 'none'
    entry: glob path.join(config.rootPath, 'user', 'libs', '**', '*_test.coffee'),
                path.join(config.rootPath, 'user', 'libs', '**', '*_test.js')
    output:
      filename: '[name].js'
      path: path.join config.rootPath, '.tmp', 'test'
    module:
      rules: [
        test: /\.coffee$/
        use: [
          loader: 'babel-loader'
        ,
          loader: 'coffee-loader'
        ]
      ,
        test: /\.js$/
        use: [
          loader: 'babel-loader'
        ]
      ,
        test: /\.(sass|css)$/
        use: [
          loader: 'css-loader'
        ,
          loader: 'sass-loader'
        ]
      ]

  # console.log webpackCompiler.options.entry

  webpackCompiler.run ->
    # interpolate files
    testFiles = glob '.tmp/test/*_test.js'
    for testName, testPath of testFiles
      libName = testName.match(/^(.+)_test$/)[1]
      helpers.interpolateFile path.join(config.rootPath, testPath), config.test.data[libName]

    # run tests
    regexLibs = config.test.libs.join '|'
    jest.run "--verbose --colors --testRegex '\.tmp\/test\/(#{regexLibs})_test.js$'"
