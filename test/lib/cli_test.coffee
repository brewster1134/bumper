{ expect, sinon } = require '../test_helpers'

Cli = require '../../lib/cli'

describe 'Cli', ->
  cli = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#run', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._buildCli.returns
        argv: 'argv'
      cli.run.restore()

    it 'should bulld the cli', ->
      run = cli.run()

      expect(run).to.eq 'argv'
      expect(cli._buildCli).to.be.calledOnce

  describe '#getVerbose', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli.getVerbose.restore()

    it 'should check if verbose was passed', ->
      cli.argv =
        verbose: true
        V: 'alias'

      expect(cli.getVerbose()).to.be.true

    it 'should check if verbose alias was passed', ->
      cli.argv =
        V: true

      expect(cli.getVerbose()).to.be.true

    it 'should return null if nothing was passed', ->
      cli.argv = new Object

      expect(cli.getVerbose()).to.be.null

  describe '#getOptionValue', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli.getOptionValue.restore()

    beforeEach ->
      cli._getConfigValue.reset()

    it 'should check for values in the right order', ->
      cli._getOptionDefault.returns 'default'

      cli.getOptionValue()

      expect(cli._getOptionDefault).to.have.been.called
      expect(cli._getEnvVarValue).to.have.been.calledAfter cli._getOptionDefault
      expect(cli._getConfigValue).to.have.been.calledAfter cli._getEnvVarValue

    it 'should use the default value type to lookup the environment variable', ->
      cli._getOptionDefault.returns true

      cli.getOptionValue 'command', 'option'

      expect(cli._getEnvVarValue).to.be.calledWith 'command', 'option', Boolean

    it 'should return the environment variable', ->
      cli._getEnvVarValue.returns 'env var'

      val = cli.getOptionValue 'command', 'option'

      expect(cli._getConfigValue).to.have.not.been.called
      expect(val).to.eq 'env var'

    it 'should return the value from the config file', ->
      cli._getEnvVarValue.returns null
      cli._getConfigValue.returns 'config file'

      val = cli.getOptionValue 'command', 'option'

      expect(cli._getConfigValue).to.have.been.called
      expect(val).to.eq 'config file'

  describe '#_cleanupCommandConfig', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._cleanupCommandConfig.restore()

    it 'should sanitize the args passed to the command scripts', ->
      global.bumper.optionGlobals =
        global_one: 'G'

      cmdCfg = cli._cleanupCommandConfig
        $0: '$0'
        _: '_'
        global_one: 1
        option_two: 2
        G: 1
        O: 2

      # it should remove the meta data keys
      expect(cmdCfg).to.deep.eq
        option_two: 2

  describe '#_getOptionDefault', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getOptionDefault.restore()

    it 'should check for command specific value first', ->
      global.bumper.optionDefaults =
        option: 'root value'
        command:
          option: 'command value'

      expect(cli._getOptionDefault('command', 'option')).to.eq 'command value'

    it 'should fallback to check for root value', ->
      global.bumper.optionDefaults =
        option: 'root value'

      expect(cli._getOptionDefault('command', 'option')).to.eq 'root value'

  describe '#_buildCommandConfig', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._buildCommandConfig.restore()

    it 'should merge the command options into the global config', ->
      global.bumper.config =
        global: 'val'
      cli._getGlobalOptions.returns
        command:
          global: 'val'
      cli._cleanupCommandConfig.returns
        option: 'val'

      cmdCfg = cli._buildCommandConfig 'command',
        global: 'three'

      expect(cmdCfg).to.deep.eq global.bumper.config
      expect(cmdCfg).to.deep.eq
        global: 'val'
        command:
          option: 'val'

      expect(cli._getGlobalOptions).to.have.been.called
      expect(cli._cleanupCommandConfig).to.have.been.calledAfter cli._getGlobalOptions

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
      expect(cli._getEnvVarValue('command', 'option')).to.eq 'BO'

      delete process.env.CLITEST_COMMAND_OPTION
      delete process.env.CLITEST_OPTION
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.eq 'BCO'

      delete process.env.CLITEST_COMMAND_OPTION
      process.env.CLITEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.eq 'BTO'

      process.env.CLITEST_COMMAND_OPTION = 'BTCO'
      process.env.CLITEST_OPTION = 'BTO'
      process.env.BUMPER_COMMAND_OPTION = 'BCO'
      process.env.BUMPER_OPTION = 'BO'
      expect(cli._getEnvVarValue('command', 'option')).to.eq 'BTCO'

    it 'should type-cast non-string values', ->
      process.env.BUMPER_COMMAND_OPTION = 'foo,bar'
      expect(cli._getEnvVarValue('command', 'option', Array)).to.deep.equal [ 'foo', 'bar' ]

      process.env.BUMPER_COMMAND_OPTION = 'true'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.eq true

      process.env.BUMPER_COMMAND_OPTION = 'false'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.eq false

      process.env.BUMPER_COMMAND_OPTION = '138'
      expect(cli._getEnvVarValue('command', 'option', Number)).to.eq 138

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
