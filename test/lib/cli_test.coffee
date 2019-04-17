{ expect, sinon } = require '../test_helpers'

Cli = require '../../lib/cli'

describe 'Cli', ->
  cli = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    before ->
      global.bumper = setSharedOptionValues: sandbox.stub()

      cli = sandbox.createStubInstance Cli
      cli._buildCli.returns argv: 'argv'
      cli.run.restore()
      cli.run()

    it 'should build the cli', ->
      expect(global.bumper.setSharedOptionValues).to.be.calledOnce
      expect(cli._buildCli).to.be.calledAfter global.bumper.setSharedOptionValues

  describe 'getOptionValue', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli.getOptionValue.restore()

    beforeEach ->
      cli._getOptionDefault.reset()
      cli._getEnvVarValue.reset()
      cli._getConfigFileValue.reset()

    it 'should check for values in the right order & fallback on the default value', ->
      cli._getOptionDefault.returns 'default value'

      optionVal = cli.getOptionValue 'command', 'option'

      expect(cli._getOptionDefault).to.be.calledWith 'command', 'option'
      expect(cli._getEnvVarValue).to.be.calledAfter cli._getOptionDefault
      expect(cli._getConfigFileValue).to.be.calledAfter cli._getEnvVarValue
      expect(optionVal).to.eq 'default value'

    it 'should return the value from the environment variable', ->
      # based on the default value, we pass the object type to typecast the env var value, which is always a string
      cli._getOptionDefault.returns true
      cli._getEnvVarValue.returns false

      optionVal = cli.getOptionValue 'command', 'option'

      # the 3rd arguments Boolean was detected from the default value of true
      expect(cli._getEnvVarValue).to.be.calledWith 'command', 'option', Boolean
      expect(cli._getOptionDefault).to.be.called
      expect(cli._getConfigFileValue).to.not.be.called
      expect(optionVal).to.eq false

    it 'should return the value from the config file', ->
      cli._getOptionDefault.returns 'default value'
      cli._getConfigFileValue.returns 'config file value'

      val = cli.getOptionValue 'command', 'option'

      expect(cli._getOptionDefault).to.be.called
      expect(cli._getEnvVarValue).to.be.called
      expect(cli._getConfigFileValue).to.be.calledWith 'command', 'option'
      expect(val).to.eq 'config file value'

  describe '_getOptionDefault', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getOptionDefault.restore()

    it 'should check for command specific value first', ->
      global.bumper.optionDefaults =
        option: 'shared value'
        command:
          option: 'command value'

      expect(cli._getOptionDefault('command', 'option')).to.eq 'command value'

    it 'should handle null command', ->
      global.bumper.optionDefaults =
        option: 'shared value'
        command:
          option: 'command value'

      expect(cli._getOptionDefault(null, 'option')).to.eq 'shared value'

    it 'should fallback on the shared value', ->
      global.bumper.optionDefaults =
        option: 'shared value'

      expect(cli._getOptionDefault('command', 'option')).to.eq 'shared value'

  describe '_getEnvVarValue', ->
    before ->
      global.bumper.config = nameSafe: 'clitest'

      cli = sandbox.createStubInstance Cli
      cli._getEnvVarValue.restore()

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

    it 'should return null if no environment variable was found', ->
      expect(cli._getEnvVarValue('command', 'option')).to.be.null
      expect(cli._getGlobalsFromArray).to.not.be.called

    it 'should type-cast non-string values', ->
      process.env.BUMPER_COMMAND_OPTION = 'foo,bar'
      expect(cli._getEnvVarValue('command', 'option', Array)).to.deep.eq [ 'foo', 'bar' ]

      process.env.BUMPER_COMMAND_OPTION = 'true'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.eq true

      process.env.BUMPER_COMMAND_OPTION = 'false'
      expect(cli._getEnvVarValue('command', 'option', Boolean)).to.eq false

      process.env.BUMPER_COMMAND_OPTION = '138'
      expect(cli._getEnvVarValue('command', 'option', Number)).to.eq 138

      process.env.BUMPER_COMMAND_OPTION = 'foo:bar,bar:baz'
      cli._getEnvVarValue('command', 'option', Object)
      expect(cli._getGlobalsFromArray).to.be.calledWith ['foo:bar', 'bar:baz']

  describe '_getConfigFileValue', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getConfigFileValue.restore()

    it 'should check for command specific value first', ->
      global.bumper =
        config:
          file:
            option: 'shared value'
            commandFoo:
              option: 'command value'

      expect(cli._getConfigFileValue('commandFoo', 'option')).to.eq 'command value'

    it 'should fallback on the shared value', ->
      global.bumper =
        config:
          file:
            option: 'shared value'
            commandBar:
              option: 'command value'

      expect(cli._getConfigFileValue('commandFoo', 'option')).to.eq 'shared value'

    it 'should handle a missing command', ->
      global.bumper =
        config:
          file:
            option: 'shared value'

      expect(cli._getConfigFileValue(null, 'option')).to.eq 'shared value'

  describe '_setCommandOptions', ->
    before ->
      global.bumper =
        config:
          foo: true

      cli = sandbox.createStubInstance Cli
      cli._cleanCommandOptions.returns commandOption: 'command value'
      cli._setCommandOptions.restore()
      cli._setCommandOptions 'command', 'args object'

    it 'should merge the shared options from the command', ->
      expect(cli._cleanCommandOptions).to.be.calledWith 'args object'
      expect(global.bumper.config).to.deep.eq
        foo: true
        command:
          commandOption: 'command value'

  describe '_cleanCommandOptions', ->
    commandOptions = null

    before ->
      global.bumper.optionShared =
        sharedOption: 'S'

      cli = sandbox.createStubInstance Cli
      cli._cleanCommandOptions.restore()
      commandOptions = cli._cleanCommandOptions
        $0: '$0'        # meta data is removed
        _: '_'          # meta data is removed
        sharedOption: 1 # shared options are moved from the command object, to the root of the config
        S: 1            # shared aliases are removed
        O: 2            # any single character key is assumed to be an alias and removed
        option_two: 2

    it 'should sanitize the args', ->
      expect(commandOptions).to.deep.eq option_two: 2

  describe '_buildGlobals', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._buildGlobals.restore()

    it 'should create a child object for every lib', ->
      global.bumper =
        config:
          libs:
            foo: '/foo'
            bar: '/bar'

      globals = cli._buildGlobals()

      expect(globals).to.deep.eq
        foo: {}
        bar: {}

    it 'should merge globals in the right order', ->
      global.bumper =
        config:
          libs:
            libName: '/libName'
      envVarVal =
        libName:
          foo: 'env'
          bar: 'env'
          baz: 'env'
      configVal =
        libName:
          foo: 'config'
          bar: 'config'
      cliGlobals =
        libName:
          foo: 'cli'

      cli._getEnvVarValue.returns envVarVal
      cli._getConfigFileValue.returns configVal
      cli._getGlobalsFromArray.returns cliGlobals
      cli._buildLibGlobals
        .onCall(0).returns envVarVal
        .onCall(1).returns configVal
        .onCall(2).returns cliGlobals

      globals = cli._buildGlobals()

      expect(cli._buildLibGlobals.getCall(0)).to.be.calledWith envVarVal
      expect(cli._buildLibGlobals.getCall(1)).to.be.calledWith configVal
      expect(cli._buildLibGlobals.getCall(2)).to.be.calledWith cliGlobals
      expect(globals).to.deep.eq
        libName:
          foo: 'cli'
          bar: 'config'
          baz: 'env'

  describe '_getGlobalsFromArray', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._getGlobalsFromArray.restore()

    it 'should return null if no globals are found', ->
      expect(cli._getGlobalsFromArray()).to.be.null

    it 'should convert properly formatted strings to an object', ->
      globals = cli._getGlobalsFromArray ['foo:bar', 'bar:baz']

      expect(globals).to.deep.eq
        foo: 'bar'
        bar: 'baz'

    it 'should handle keys only', ->
      globals = cli._getGlobalsFromArray ['foo', 'bar']

      expect(globals).to.deep.eq
        foo: null
        bar: null

    it 'should skip values only', ->
      globals = cli._getGlobalsFromArray [':foo', ':bar']

      expect(globals).to.be.empty

  describe '_buildLibGlobals', ->
    before ->
      cli = sandbox.createStubInstance Cli
      cli._buildLibGlobals.restore()

    it 'should duplicate shared globals into each lib globals', ->
      global.bumper.config =
        libs:
          fooLib: 'path/to/fooLib'
          barLib: 'path/to/barLib'

      globals = cli._buildLibGlobals
        keyOne: 'valOne'
        keyTwo: 'valTwo'

      expect(globals).to.deep.eq
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

      expect(globals).to.deep.eq
        fooLib:
          key: 'fooVal'
