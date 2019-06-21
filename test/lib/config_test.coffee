{ expect, sinon } = require '../test_helpers'
fs = require 'fs-extra'
glob = require 'glob'
path = require 'path'
yaml = require 'js-yaml'

Config = require '../../lib/config'

describe 'Config', ->
  config = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'build', ->
    build = null
    stubPathResolve = null
    stubProcessCwd = null

    before ->
      global.bumper =
        config:
          command: 'command'
        setSharedOptionValues: sandbox.stub()
        optionDefaults: {}
      stubPathResolve = sandbox.stub(path, 'resolve').returns '/bumper'
      stubProcessCwd = sandbox.stub(process, 'cwd').returns '/project'

      config = sandbox.createStubInstance Config
      config._getConfigFile.returns name: 'project name'
      config._getLibs.returns lib: '/project/libs'
      config._getPackageJson
        .onCall(0).returns bumper: 'json'
        .onCall(1).returns version: '1.2.3'
      config.build.restore()
      build = config.build()

    it 'should call other functions', ->
      expect(global.bumper.setSharedOptionValues).to.be.calledOnce
      expect(stubPathResolve).to.be.calledOnce
      expect(stubProcessCwd).to.be.calledOnce
      expect(config._getConfigFile).to.be.calledOnce
      expect(config._getPackageJson.getCall(0)).to.be.calledWith '/bumper'
      expect(config._getPackageJson.getCall(1)).to.be.calledWith '/project'
      expect(config._getLibs).to.be.calledOnce

    it 'should set required config values', ->
      expect(build.command).to.eq 'command'     # passes through existing value set on global object
      expect(build.bumperPath).to.be.a 'string'
      expect(build.file).to.be.a 'object'       # can be empty if no project config file exists
      expect(build.flair).to.be.a 'string'
      expect(build.nameSafe).to.be.a 'string'
      expect(build.projectPath).to.be.a 'string'
      expect(build.version).to.be.a 'string'

      # libs should list actual project libraries
      expect(build.libs).to.be.a 'object'
      expect(build.libs).to.not.be.empty
      expect(global.bumper.optionDefaults.libs).to.deep.eq Object.keys(build.libs)

  describe '_getConfigFile', ->
    stubReadFile = sandbox.stub fs, 'readFileSync'

    before ->
      config = sandbox.createStubInstance Config
      config._getConfigFile.restore()

    afterEach ->
      stubReadFile.reset()

    context 'with a yaml config file', ->
      it 'should check the right file path', ->
        config._getConfigFile 'projectPath'

        expect(stubReadFile).to.be.calledOnceWith 'projectPath/config.yaml'

      it 'should return a json object', ->
        stubReadFile.returns 'yaml: true'

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.deep.eq yaml: true

    context 'with a json config file', ->
      it 'should check the right file path', ->
        stubReadFile.onCall(0).throws()

        config._getConfigFile 'projectPath'

        expect(stubReadFile.getCall(0)).to.be.calledWith 'projectPath/config.yaml'
        expect(stubReadFile.getCall(1)).to.be.calledWith 'projectPath/config.json'

      it 'should return a json object', ->
        stubReadFile.onCall(0).throws()
        stubReadFile.onCall(1).returns '{"json": true}'

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.deep.eq json: true

    context 'with no config file', ->
      it 'should return an empty object', ->
        stubReadFile.throws()

        configFile = config._getConfigFile 'projectPath'

        expect(configFile).to.be.empty

  describe '_getLibs', ->
    libs = null
    stubReaddirSync = null
    stubGlobSync = null

    before ->
      stubReaddirSync = sandbox.stub(fs, 'readdirSync').returns [
        'libFoo'
        'libBar'
      ]
      stubGlobSync = sandbox.stub(glob, 'sync')
        .onCall(0).returns ['one']
        .onCall(1).returns ['two']

      config = sandbox.createStubInstance Config
      config._getLibs.restore()

      libs = config._getLibs 'projectPath', [
        'formatFoo'
        'formatBar'
      ]

    it 'should check the current working directory for valid libraries', ->
      expect(stubReaddirSync).to.be.calledOnceWith 'projectPath/libs'
      expect(stubGlobSync.getCall(0)).to.be.calledWith 'projectPath/libs/libFoo/libFoo.+(formatFoo|formatBar)'
      expect(stubGlobSync.getCall(1)).to.be.calledWith 'projectPath/libs/libBar/libBar.+(formatFoo|formatBar)'
      expect(libs).to.deep.eq
        libFoo: 'one'
        libBar: 'two'
