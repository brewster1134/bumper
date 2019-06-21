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
      global.bumper.config =
        formats:
          js: []
        test:
          libs: []
      test = sandbox.createStubInstance Test
      test._getWebpackConfig.returns 'webpack config'
      test.run.restore()
      test.run()

    it 'should run webpack with the right config', ->
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
