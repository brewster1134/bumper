{ expect, sinon } = require '../test_helpers'

Bumper = require '../../lib/bumper'
Cli = require '../../lib/cli'
Config = require '../../lib/config'

describe 'Bumper', ->
  bumper = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#run', ->
    spyProcess = null
    stubLog = null
    stubConfig = null
    stubCli = null

    before ->
      bumper = sandbox.createStubInstance Bumper
      bumper.run.restore()

      spyProcess = sandbox.spy process, 'on'
      stubConfig = sandbox.stub(Config::, 'build').returns new Object
      stubCli = sandbox.stub Cli::, 'run'

      process.removeAllListeners 'uncaughtException'
      bumper.run()

    it.skip 'should catch exceptions', ->
      throw new Error 'exception'

      expect(spyProcess).to.be.calledOnce
      expect(stubLog).to.be.calledOnce

    it 'should create a global object', ->
      expect(global.bumper.log).to.be.an.instanceof Function
      expect(global.bumper.verbose).to.be.an.instanceof Function
      expect(global.bumper.config).to.be.an.instanceof Object

    it 'should initialize the cli', ->
      expect(stubCli).to.be.calledOnce

  describe.skip '#_log', ->
    before ->
      bumper = sandbox.createStubInstance Bumper
      bumper._log.restore()

  describe '#_getVerbose', ->
    before ->
      bumper = sandbox.createStubInstance Bumper
      bumper._getVerbose.restore()

    it 'should check the global config first', ->
      global.bumper =
        config:
          verbose: 'global'

      verbose = bumper._getVerbose()

      expect(verbose).to.equal 'global'

    it.skip 'should check if passed via cli', ->
      global.bumper =
        config: undefined
      process.argv.push '--verbose'

      verbose = bumper._getVerbose()

      expect(verbose).to.equal true
