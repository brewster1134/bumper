{ expect, sinon } = require '../../test_helpers'
path = require 'path'

Demo = require '../../../lib/commands/demo'

describe 'COMMAND: Demo', ->
  demo = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    before ->
      global.bumper =
        config:
          bumperPath: path.resolve __dirname, '..', '..', '..'

      demo = sandbox.createStubInstance Demo
      demo._getWebpackConfig.returns 'webpack config'
      demo.run.restore()
      demo.run()

    it 'should set the helpers', ->
      expect(demo.helpers).to.be.a 'object'

    it 'should run the server with the right webpack compiler', ->
      expect(demo._runServer).to.be.calledOnce

  describe '_getWebpackConfig', ->
    wpConfig = null

    before ->
      demo = sandbox.createStubInstance Demo

  describe '_runServer', ->
    wpConfig = null

    before ->
      demo = sandbox.createStubInstance Demo
      demo._runServer.restore()
      demo._runServer()
