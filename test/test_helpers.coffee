# require dependencies
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

# require bumper libs
Helpers = require '../lib/helpers.coffee'

# test configuration
expect = chai.expect
chai.use sinonChai

# mocks, stubs & spies
sinon.stub Helpers::, 'logMessage'

module.exports =
  expect: expect
  sinon: sinon
  helpers: new Helpers
