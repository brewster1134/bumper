{ expect, sinon } = require '../test_helpers'

Cli = require '../../lib/cli'

describe 'Cli', ->
  cli = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#_getOptionValue', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getOptionValue.restore()

    beforeEach ->
      cli._getConfigValue.reset()

    it 'should check for values in the right order', ->
      cli._getOptionDefault.returns 'default'

      cli._getOptionValue()

      expect(cli._getOptionDefault).to.have.been.called
      expect(cli._getEnvVarValue).to.have.been.calledAfter cli._getOptionDefault
      expect(cli._getConfigValue).to.have.been.calledAfter cli._getEnvVarValue

    it 'should use the default value type to lookup the environment variable', ->
      cli._getOptionDefault.returns true

      cli._getOptionValue 'command', 'option'

      expect(cli._getEnvVarValue).to.be.calledWith 'command', 'option', Boolean

    it 'should return the environment variable immediately if found', ->
      cli._getEnvVarValue.returns 'value'
      cli._getOptionDefault.returns 'default'

      cli._getOptionValue 'command', 'option'

      expect(cli._getConfigValue).to.have.not.been.called

  describe '#_getEnvVarValue', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getEnvVarValue.restore()
      global.bumper.config =
        nameSafe: 'clitest'

    afterEach ->
      delete process.env.CLITEST_COMMAND_OPTION
      delete process.env.CLITEST_OPTION
      delete process.env.BUMPER_COMMAND_OPTION
      delete process.env.BUMPER_OPTION

    it 'should check for values in the right order', ->
      delete process.env.CLITEST_COMMAND_OPTION
      delete process.env.CLITEST_OPTION
      delete process.env.BUMPER_COMMAND_OPTION
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.equal 'BO'

      delete process.env.CLITEST_COMMAND_OPTION
      delete process.env.CLITEST_OPTION
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.equal 'BCO'

      delete process.env.CLITEST_COMMAND_OPTION
      process.env.CLITEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.equal 'BTO'

      process.env.CLITEST_COMMAND_OPTION = 'BTCO'
      process.env.CLITEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.equal 'BTCO'

    it 'should type-cast non-string values', ->
      process.env.BUMPER_COMMAND_OPTION = 'foo,bar'
      expect(cli._getEnvVarValue('command', 'option', Array)).to.deep.equal [ 'foo', 'bar' ]

      process.env.BUMPER_COMMAND_OPTION = 'true'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.equal true

      process.env.BUMPER_COMMAND_OPTION = 'false'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.equal false

      process.env.BUMPER_COMMAND_OPTION = '138'
      expect(cli._getEnvVarValue('command', 'option', Number)).to.equal 138

      cli._getGlobalsFromArray.restore()
      process.env.BUMPER_COMMAND_OPTION = 'foo:bar,bar:baz'
      expect(cli._getEnvVarValue('command', 'option', Object)).to.deep.equal
        foo: 'bar'
        bar: 'baz'

  describe '#_getGlobalsFromArray', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getGlobalsFromArray.restore()

    it 'should convert a properly formatted strings to an object', ->
      globals = cli._getGlobalsFromArray ['foo:bar', 'bar:baz']

      expect(globals).to.deep.equal
        foo: 'bar'
        bar: 'baz'

  describe '#_buildLibGlobals', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._buildLibGlobals.restore()

    it 'should move shared globals into library globals', ->
      global.bumper.config =
        libs:
          fooLib: 'path/to/fooLib'
          barLib: 'path/to/barLib'

      globals = cli._buildLibGlobals
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
      global.bumper.config =
        libs:
          fooLib: 'path/to/fooLib'

      globals = cli._buildLibGlobals
        fooLib:
          key: 'fooVal'
        key: 'val'

      expect(globals).to.deep.equal
        fooLib:
          key: 'fooVal'
