# dependencies
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

# helpers
Helpers = require '../lib/helpers.coffee'
sinon.stub Helpers::, 'logMessage'
helpers = new Helpers

# test configuration
expect = chai.expect
chai.use sinonChai

module.exports =
  expect: expect
  sinon: sinon
  helpers: helpers
