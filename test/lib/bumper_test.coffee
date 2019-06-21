{ expect, sinon } = require '../test_helpers'

Bumper = require '../../lib/bumper'
Cli = require '../../lib/cli'
Config = require '../../lib/config'
Logger = require '../../lib/logger'

describe 'Bumper', ->
  bumper = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'run', ->
    stubConfigBuild = null
    stubCliRun = null

    before ->
      stubConfigBuild = sandbox.stub(Config::, 'build').returns 'config object'
      stubCliRun = sandbox.stub Cli::, 'run'

      bumper = sandbox.createStubInstance Bumper
      bumper._setSharedOptionValues = bind: sandbox.stub().returns '_setSharedOptionValues function'
      bumper.run.restore()
      bumper.run()

    it 'should run in the right order', ->
      expect(bumper._setSharedOptionValues.bind).to.be.calledOnceWith bumper
      expect(stubConfigBuild).to.be.calledAfter bumper._setSharedOptionValues.bind
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
      bumper._setSharedOptionValues.restore()

    it 'should check if option passed via cli before searching', ->
      bumper.args = foo: 1
      bumper.cli = getOptionValue: sandbox.stub().returns 2
      bumper._setSharedOptionValues()

      expect(bumper.cli.getOptionValue).to.be.calledOnceWith 'bumper_command', 'bar'
      expect(global.bumper.config).to.deep.eq
        command: 'bumper_command'
        foo: 1
        bar: 2

    it 'should check if alias passed via cli before searching', ->
      bumper.args = F: 1
      bumper.cli = getOptionValue: sandbox.stub().returns 2
      bumper._setSharedOptionValues()

      expect(bumper.cli.getOptionValue).to.be.calledOnceWith 'bumper_command', 'bar'
      expect(global.bumper.config).to.deep.eq
        command: 'bumper_command'
        foo: 1
        bar: 2
