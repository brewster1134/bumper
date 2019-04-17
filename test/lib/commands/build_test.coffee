{ expect, sinon } = require '../../test_helpers'
fs = require 'fs-extra'

Build = require '../../../lib/commands/build'

describe 'COMMAND: Build', ->
  build = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    before ->
      sandbox.stub fs, 'ensureDirSync'
      global.bumper =
        config:
          build:
            output: '/downloads'

      build = sandbox.createStubInstance Build
      build._getWebpackConfig.returns plugins: []
      build.run.restore()

    it 'should run webpack with the right config', ->
      build.run()

      expect(build._getWebpackConfig).to.be.calledOnce
      expect(build._runWebpack).to.be.calledAfter build._getWebpackConfig
      expect(build._runWebpack).to.be.calledWith plugins: []

    context 'when compress is set to true', ->
      before ->
        global.bumper =
          config:
            nameSafe: 'nameSafe'
            version: '1.2.3'
            build:
              compress: true
              output: '/downloads'

        build.run()

      it 'should add the compression plugin to the webpack config', ->
        expect(build._runWebpack).to.be.calledWith
          plugins: [
            sandbox.match.has 'options', sandbox.match.has('filename', 'nameSafe_1.2.3')
          ]
        expect(build._runWebpack).to.be.calledWith
          plugins: [
            sandbox.match.has 'options', sandbox.match.has('path', '/downloads')
          ]

  describe '_getWebpackConfig', ->
    wpConfig = null

    before ->
      build = sandbox.createStubInstance Build
      build.distDir = '/dist'
      build.config =
        bumperPath: '/bumper'
        projectPath: '/project'
        develop: true
      build._getEntries.returns 'entries'
      build._getWebpackMode.returns 'mode'
      build._getOutputFile.returns 'file.ext'
      build._getWebpackConfig.restore()

      wpConfig = build._getWebpackConfig()

    it 'should return a valid webpack config', ->
      expect(build._getEntries).to.be.calledOnce
      expect(build._getWebpackMode).to.be.calledOnce
      expect(build._getOutputFile).to.be.calledTwice
      expect(wpConfig).to.be.a 'object'
      expect(wpConfig).to.not.be.empty
      expect(wpConfig.entry).to.eq 'entries'
      expect(wpConfig.mode).to.eq 'mode'
      expect(wpConfig.output.filename).to.eq 'file.ext'

  describe '_getEntries', ->
    before ->
      build = sandbox.createStubInstance Build
      build.tmpDir = '/.tmp'
      build.bundleName = 'projectName'
      build.config =
        libs:
          foo: '/foo'
          bar: '/bar'
          baz: '/baz'
        build:
          libs: [ 'foo', 'bar' ]
      build._getEntries.restore()

    context 'when split is true', ->
      before ->
        build.config.build.split = true

      it 'should return each library and its path', ->
        expect(build._getEntries()).to.deep.eq
          foo: '/foo'
          bar: '/bar'

    context 'when split is false', ->
      before ->
        sandbox.stub(fs, 'createWriteStream').returns
          write: sandbox.stub()
          end: sandbox.stub()
        build.config.build.split = false

      it 'should return a single project name', ->
        expect(build._getEntries()).to.eq '/.tmp/projectName.js'

    it 'should run webpack with config', ->
      build.run()

  describe '_getWebpackMode', ->
    before ->
      build = sandbox.createStubInstance Build
      build._getWebpackMode.restore()

    it 'should return correct mode based on develop option', ->
      build.config = develop: true
      expect(build._getWebpackMode()).to.eq 'development'

      build.config = develop: false
      expect(build._getWebpackMode()).to.eq 'production'

  describe '_getOutputFile', ->
    before ->
      build = sandbox.createStubInstance Build
      build._getOutputFile.restore()

    context 'when split is true', ->
      before ->
        build.config =
          build:
            split: true

      it 'should return the webpack template name', ->
        expect(build._getOutputFile('ext')).to.eq '[name].ext'

    context 'when split is false', ->
      before ->
        build.bundleName = 'projectName'
        build.config =
          build:
            split: false

      it 'should return the project name', ->
        expect(build._getOutputFile('ext')).to.eq 'projectName.ext'

  # TODO: need to stub calling `require webpack`
  describe.skip '_runWebpack', ->
    before ->
      stubWebpackRun = sandbox.stub()
      sandbox.stub(require).returns webpack: stubWebpackRun

      build = sandbox.createStubInstance Build
      build._runWebpack.restore()
      build._runWebpack()

    it 'should call webpack with config', ->
      expect(require).to.be.calledWith 'webpack'
      expect(stubWebpackRun).to.be.calledWith 'webpack config object'

  describe '_moveLib', ->
    before ->
      build = sandbox.createStubInstance Build
      build.distDir = '/dist'
      build.downloadsDir = '/downloads'
      build.bundleName = 'projectName'
      sandbox.stub fs, 'copySync'
      build._moveLib.restore()
      build._moveLib()

    it 'should copy the generated assets to the download folder', ->
      expect(fs.copySync).to.be.calledWith '/dist', '/downloads/projectName'

  # TODO: need to stub calling `new Logger`
  describe.skip '_logOutput', ->
    before ->
      build = sandbox.createStubInstance Build
      build._logOutput.restore()
      build._logOutput()

    it 'should log results to user', ->
      expect(Logger).to.be.created
