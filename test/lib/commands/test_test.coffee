{ expect, sinon } = require '../../test_helpers'
fs = require 'fs-extra'

Test = require '../../../lib/commands/test'

describe 'COMMAND: Test', ->
  test = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    before ->
      test = sandbox.createStubInstance Test
      test._getWebpackConfig.returns 'webpack config'
      test.run.restore()

    it 'should run webpack with the right config', ->
      test.run()

      expect(test._getWebpackConfig).to.be.calledOnce
      expect(test._runWebpack).to.be.calledAfter test._getWebpackConfig
      expect(test._runWebpack).to.be.calledWith 'webpack config'

  describe '_getWebpackConfig', ->
    wpConfig = null

    before ->
      test = sandbox.createStubInstance Test
      test.config =
        bumperPath: '/bumper'
        projectPath: '/project'
        formats:
          js: []
        test:
          libs: []
      test._getWebpackConfig.restore()

      wpConfig = test._getWebpackConfig()

    it 'should return a valid webpack config', ->
      expect(wpConfig).to.be.a 'object'
      expect(wpConfig).to.not.be.empty

  # TODO: need to stub calling `require webpack`
  describe.skip '_runWebpack', ->
    before ->
      stubWebpackRun = sandbox.stub()
      sandbox.stub(require).returns webpack: stubWebpackRun

      test = sandbox.createStubInstance Test
      test._runWebpack.restore()
      test._runWebpack()

    it 'should call webpack with config', ->
      expect(require).to.be.calledWith 'webpack'
      expect(stubWebpackRun).to.be.calledWith 'webpack config object'
