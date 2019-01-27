{ expect, sinon } = require '../test_helpers'

Config = require '../../lib/config'
fs = require 'fs-extra'
glob = require 'glob'
yaml = require 'js-yaml'

describe 'Config', ->
  config = null
  sandbox = sinon.createSandbox()

  beforeEach ->
    config = sandbox.createStubInstance Config

  after ->
    sandbox.restore()

  describe '#_getConfigFile', ->
    readFileStub = sandbox.stub fs, 'readFileSync'

    beforeEach ->
      config._getConfigFile.restore()

    afterEach ->
      readFileStub.reset()

    context 'with a yaml config file', ->
      it 'should check the right file path', ->
        config._getConfigFile 'packagePath'

        expect(readFileStub).to.have.been.calledWith 'packagePath/config.yaml'

      it 'should return a json object', ->
        readFileStub.returns 'yaml: true'

        configFile = config._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal
          yaml: true

    context 'with a json config file', ->
      it 'should check the right file path', ->
        readFileStub.onCall(0).throws()

        config._getConfigFile 'packagePath'

        expect(readFileStub.getCall(1)).to.have.been.calledWith 'packagePath/config.json'

      it 'should return a json object', ->
        readFileStub.onCall(0).throws()
        readFileStub.onCall(1).returns '{"json": true}'

        configFile = config._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal
          json: true

    context 'with no config file', ->
      it 'should return an empty object', ->
        # readFileStub.reset()
        readFileStub.throws()

        configFile = config._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal {}

  describe '#_getlibs', ->
    readdirSyncStub = sandbox.stub fs, 'readdirSync'

    beforeEach ->
      config._getlibs.restore()

    it 'should check the current working directory for valid libraries', ->
      readdirSyncStub.returns [
        'libFoo'
        'libBar'
      ]

      globSyncStub = sandbox.stub(glob, 'sync')
        .onCall(0).returns ['one']
        .onCall(1).returns ['two']

      libs = config._getlibs 'packagePath', [
        'formatFoo'
        'formatBar'
      ]

      expect(readdirSyncStub).to.be.calledWith 'packagePath/libs'
      expect(globSyncStub.getCall(0)).to.be.calledWith 'packagePath/libs/libFoo/libFoo.+(formatFoo|formatBar)'
      expect(globSyncStub.getCall(1)).to.be.calledWith 'packagePath/libs/libBar/libBar.+(formatFoo|formatBar)'
      expect(libs).to.deep.equal
        libFoo: 'one'
        libBar: 'two'
