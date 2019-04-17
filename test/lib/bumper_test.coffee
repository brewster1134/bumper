{ expect, sinon } = require '../test_helpers'

Bumper = require '../../lib/bumper'
Cli = require '../../lib/cli'
Config = require '../../lib/config'

describe 'Bumper', ->
  bumper = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    stubProcessOn = null
    stubConfigBuild = null
    stubCliRun = null

    before ->
      stubProcessOn = sandbox.stub process, 'on'
      stubConfigBuild = sandbox.stub(Config::, 'build').returns 'config object'
      stubCliRun = sandbox.stub Cli::, 'run'

      bumper = sandbox.createStubInstance Bumper
      bumper._setSharedOptionValues = bind: sandbox.stub().returns '_setSharedOptionValues function'
      bumper.run.restore()
      bumper.run()

    it 'should run in the right order', ->
      # setSharedOptionValues must be bound to the bumper instance to ensure its properly scoped when called from the global config
      expect(bumper._setSharedOptionValues.bind).to.be.calledOnceWith bumper

      expect(stubProcessOn).to.be.calledOnceWith 'uncaughtException'
      expect(stubConfigBuild).to.be.calledAfter stubProcessOn
      expect(stubCliRun).to.be.calledAfter stubConfigBuild

    it 'should create a global bumper object', ->
      expect(global.bumper.setSharedOptionValues).to.eq '_setSharedOptionValues function'
      expect(global.bumper.config).to.eq 'config object'

      # shared options should have defaults defined
      expect(Object.keys(global.bumper.optionDefaults)).to.include Object.keys(global.bumper.optionShared)...

  describe '_setSharedOptionValues', ->
    before ->
      global.bumper =
        config:
          command: 'bumper_command'
        optionShared:
          foo: 'F'  # from cli
          bar: 'B'  # from searching

      bumper = sandbox.createStubInstance Bumper

      # mock passing --foo 1 via cli
      bumper.args = foo: 1

      # for any options not passed via cli, stub the search to return 2
      bumper.cli = getOptionValue: sandbox.stub().returns 2

      bumper._setSharedOptionValues.restore()
      bumper._setSharedOptionValues()

    it 'should check if passed via cli before searching', ->
      expect(bumper.cli.getOptionValue).to.be.calledOnceWith 'bumper_command', 'bar'
      expect(global.bumper.config).to.deep.eq
        command: 'bumper_command'
        foo: 1
        bar: 2
