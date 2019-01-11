fs = require 'fs-extra'
yaml = require 'js-yaml'
{ expect, sinon, helpers } = require '../test_helpers'

Cli = require '../../lib/cli.coffee'
cli = null

describe 'Cli', ->
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#_getConfigFile', ->
    yamlSpy = sandbox.spy yaml, 'safeLoad'
    jsonSpy = sandbox.spy JSON, 'parse'
    readFileStub = sandbox.stub fs, 'readFileSync'

    before ->
      cli = sandbox.createStubInstance Cli
      cli._getConfigFile.restore()

    afterEach ->
      readFileStub.reset()

    it 'should load a yaml config', ->
      readFileStub.returns 'foo: bar'

      configFile = cli._getConfigFile 'packagePath'

      expect(readFileStub).to.have.been.calledWith 'packagePath/config.yaml'
      expect(yamlSpy).to.have.been.called
      expect(configFile).to.deep.equal
        foo: 'bar'

    it 'should load a json config', ->
      readFileStub.onCall(0).throws()
                  .onCall(1).returns '{"bar": "baz"}'

      configFile = cli._getConfigFile 'packagePath'

      expect(readFileStub.getCall(1)).to.have.been.calledWith 'packagePath/config.json'
      expect(jsonSpy).to.have.been.called
      expect(configFile).to.deep.equal
        bar: 'baz'

    it 'should return an empty object if no config is found', ->
      readFileStub.throws()

      configFile = cli._getConfigFile()

      expect(readFileStub).to.have.callCount 2
      expect(configFile).to.deep.equal new Object
