{ expect, sinon, helpers } = require '../test_helpers'

Main = require '../../lib/main'
fs = require 'fs-extra'
glob = require 'glob'
yaml = require 'js-yaml'

describe 'Main', ->
  main = null
  sandbox = sinon.createSandbox()

  beforeEach ->
    main = sandbox.createStubInstance Main

  after ->
    sandbox.restore()

  describe '#_getConfigFile', ->
    readFileStub = sandbox.stub fs, 'readFileSync'

    beforeEach ->
      main._getConfigFile.restore()

    afterEach ->
      readFileStub.reset()

    context 'with a yaml config file', ->
      it 'should check the right file path', ->
        main._getConfigFile 'packagePath'

        expect(readFileStub).to.have.been.calledWith 'packagePath/config.yaml'

      it 'should return a json object', ->
        readFileStub.returns 'yaml: true'

        configFile = main._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal
          yaml: true

    context 'with a json config file', ->
      it 'should check the right file path', ->
        readFileStub.onCall(0).throws()

        main._getConfigFile 'packagePath'

        expect(readFileStub.getCall(1)).to.have.been.calledWith 'packagePath/config.json'

      it 'should return a json object', ->
        readFileStub.onCall(0).throws()
        readFileStub.onCall(1).returns '{"json": true}'

        configFile = main._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal
          json: true

    context 'with no config file', ->
      it 'should return an empty object', ->
        # readFileStub.reset()
        readFileStub.throws()

        configFile = main._getConfigFile 'packagePath'

        expect(configFile).to.deep.equal {}

  describe '#_getlibs', ->
    readdirSyncStub = sandbox.stub fs, 'readdirSync'

    beforeEach ->
      main._getlibs.restore()

    it 'should check the current working directory for valid libraries', ->
      main.configCore =
        packagePath: 'packagePath'
        formats:
          js: [
            'formatFoo'
            'formatBar'
          ]

      readdirSyncStub.returns [
        'libFoo'
        'libBar'
      ]

      globSyncStub = sandbox.stub(glob, 'sync')
        .onCall(0).returns ['one']
        .onCall(1).returns ['two']

      libs = main._getlibs()

      expect(readdirSyncStub).to.be.calledWith 'packagePath/libs'
      expect(globSyncStub.getCall(0)).to.be.calledWith 'packagePath/libs/libFoo/libFoo.+(formatFoo|formatBar)'
      expect(globSyncStub.getCall(1)).to.be.calledWith 'packagePath/libs/libBar/libBar.+(formatFoo|formatBar)'
      expect(libs).to.deep.equal
        libFoo: 'one'
        libBar: 'two'

  describe '#_getOptionValue', ->
    beforeEach ->
      main._getOptionValue.restore()

    it 'should check for values in the right order', ->
      main._getOptionDefault.returns 'default'

      main._getOptionValue()

      expect(main._getOptionDefault).to.have.been.called
      expect(main._getEnvVarValue).to.have.been.calledAfter main._getOptionDefault
      expect(main._getConfigValue).to.have.been.calledAfter main._getEnvVarValue

    it 'should use the default value type to lookup the environment variable', ->
      main._getOptionDefault.returns true

      main._getOptionValue 'command', 'option'

      expect(main._getEnvVarValue).to.be.calledWith 'command', 'option', Boolean

    it 'should return the environment variable immediately if found', ->
      main._getEnvVarValue.returns 'value'
      main._getOptionDefault.returns 'default'

      main._getOptionValue 'command', 'option'

      expect(main._getConfigValue).to.have.not.been.called

  describe '#_getEnvVarValue', ->
    beforeEach ->
      main._getEnvVarValue.restore()
      main.configCore =
        nameSafe: 'bumpertest'

    afterEach ->
      delete process.env.BUMPERTEST_COMMAND_OPTION
      delete process.env.BUMPERTEST_OPTION
      delete process.env.BUMPER_COMMAND_OPTION
      delete process.env.BUMPER_OPTION

    it 'should check for values in the right order', ->
      delete process.env.BUMPERTEST_COMMAND_OPTION
      delete process.env.BUMPERTEST_OPTION
      delete process.env.BUMPER_COMMAND_OPTION
      process.env.BUMPER_OPTION = 'BO'
      expect(main._getEnvVarValue('command', 'option')).to.equal 'BO'

      delete process.env.BUMPERTEST_COMMAND_OPTION
      delete process.env.BUMPERTEST_OPTION
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(main._getEnvVarValue('command', 'option')).to.equal 'BCO'

      delete process.env.BUMPERTEST_COMMAND_OPTION
      process.env.BUMPERTEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(main._getEnvVarValue('command', 'option')).to.equal 'BTO'

      process.env.BUMPERTEST_COMMAND_OPTION = 'BTCO'
      process.env.BUMPERTEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(main._getEnvVarValue('command', 'option')).to.equal 'BTCO'

    it 'should type-cast non-string values', ->
      process.env.BUMPER_COMMAND_OPTION = 'foo,bar'
      expect(main._getEnvVarValue('command', 'option', Array)).to.deep.equal [ 'foo', 'bar' ]

      process.env.BUMPER_COMMAND_OPTION = 'true'
      expect(main._getEnvVarValue('command', 'option', Boolean)).to.equal true

      process.env.BUMPER_COMMAND_OPTION = 'false'
      expect(main._getEnvVarValue('command', 'option', Boolean)).to.equal false

      process.env.BUMPER_COMMAND_OPTION = '138'
      expect(main._getEnvVarValue('command', 'option', Number)).to.equal 138

      main._getGlobalsFromString.restore()
      process.env.BUMPER_COMMAND_OPTION = 'foo:bar,bar:baz'
      expect(main._getEnvVarValue('command', 'option', Object)).to.deep.equal
        foo: 'bar'
        bar: 'baz'

  describe '#_getGlobalsFromString', ->
    beforeEach ->
      main._getGlobalsFromString.restore()

    it 'should convert a properly formatted strings to an object', ->
      globals = main._getGlobalsFromString ['foo:bar', 'bar:baz']

      expect(globals).to.deep.equal
        foo: 'bar'
        bar: 'baz'

  describe '#_buildLibGlobals', ->
    beforeEach ->
      main._buildLibGlobals.restore()

    it 'should move shared globals into library globals', ->
      main.configCore =
        libs:
          fooLib: 'path/to/fooLib'
          barLib: 'path/to/barLib'

      globals = main._buildLibGlobals
        keyOne: 'valOne'
        keyTwo: 'valTwo'

      expect(globals).to.deep.equal
        fooLib:
          keyOne: 'valOne'
          keyTwo: 'valTwo'
        barLib:
          keyOne: 'valOne'
          keyTwo: 'valTwo'

    it 'should not overwrite existing lib globals', ->
      main.configCore =
        libs:
          fooLib: 'path/to/fooLib'

      globals = main._buildLibGlobals
        fooLib:
          key: 'fooVal'
        key: 'val'

      expect(globals).to.deep.equal
        fooLib:
          key: 'fooVal'
