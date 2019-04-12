{ expect, sinon } = require '../test_helpers'

fs = require 'fs-extra'
glob = require 'glob'
yaml = require 'js-yaml'

Config = require '../../lib/config'

describe 'Config', ->
  config = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#_getConfigFile', ->
    readFileStub = sandbox.stub fs, 'readFileSync'

    before ->
      config = sandbox.createStubInstance Config
      config._getConfigFile.restore()

    afterEach ->
      readFileStub.reset()

    context 'with a yaml config file', ->
      it 'should check the right file path', ->
        config._getConfigFile 'projectPath'

        expect(readFileStub).to.have.been.calledWith 'projectPath/config.yaml'

      it 'should return a json object', ->
        readFileStub.returns 'yaml: true'

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.deep.equal
          yaml: true

    context 'with a json config file', ->
      it 'should check the right file path', ->
        readFileStub.onCall(0).throws()

        config._getConfigFile 'projectPath'

        expect(readFileStub.getCall(1)).to.have.been.calledWith 'projectPath/config.json'

      it 'should return a json object', ->
        readFileStub.onCall(0).throws()
        readFileStub.onCall(1).returns '{"json": true}'

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.deep.equal
          json: true

    context 'with no config file', ->
      it 'should return an empty object', ->
        # readFileStub.reset()
        readFileStub.throws()

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.deep.equal {}

  describe '#_getVerbose', ->
    before ->
      config = sandbox.createStubInstance Config
      config._getVerbose.restore()

    it 'should check the global config first', ->
      global.bumper =
        verbose: 'global'

      verbose = config._getVerbose()

      expect(verbose).to.equal 'global'

    it 'should call clis getOptionValue method', ->
      global.bumper =
        verbose: undefined
      config.cli =
        getOptionValue: sinon.stub()

      verbose = config._getVerbose()

      expect(config.cli.getOptionValue).to.be.calledOnce

  describe '#_getlibs', ->
    readdirSyncStub = sandbox.stub fs, 'readdirSync'

    before ->
      config = sandbox.createStubInstance Config
      config._getlibs.restore()

    it 'should check the current working directory for valid libraries', ->
      readdirSyncStub.returns [
        'libFoo'
        'libBar'
      ]

      globSyncStub = sandbox.stub(glob, 'sync')
        .onCall(0).returns ['one']
        .onCall(1).returns ['two']

      libs = config._getlibs 'projectPath', [
        'formatFoo'
        'formatBar'
      ]

      expect(readdirSyncStub).to.be.calledWith 'projectPath/libs'
      expect(globSyncStub.getCall(0)).to.be.calledWith 'projectPath/libs/libFoo/libFoo.+(formatFoo|formatBar)'
      expect(globSyncStub.getCall(1)).to.be.calledWith 'projectPath/libs/libBar/libBar.+(formatFoo|formatBar)'
      expect(libs).to.deep.equal
        libFoo: 'one'
        libBar: 'two'
