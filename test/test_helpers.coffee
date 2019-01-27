# dependencies
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'

# test configuration
expect = chai.expect
chai.use sinonChai

module.exports =
  expect: expect
  sinon: sinon
