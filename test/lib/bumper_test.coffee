{ expect, sinon } = require '../test_helpers'

Bumper = require '../../lib/bumper'
Cli = require '../../lib/cli'
Config = require '../../lib/config'

describe 'Bumper', ->
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '#run', ->
    spyProcess = null
    stubLog = null
    stubConfig = null
    stubCliRun = null
    stubCliVerbose = null

    before ->
      bumper = sandbox.createStubInstance Bumper
      bumper.run.restore()

      spyProcess = sandbox.spy process, 'on'
      stubConfig = sandbox.stub(Config::, 'build').returns
        foo: 'bar'
      stubCliRun = sandbox.stub Cli::, 'run'
      stubCliVerbose = sandbox.stub Cli::, 'getVerbose'

      process.removeAllListeners 'uncaughtException'
      bumper.run()

    it.skip 'should catch exceptions', ->
      throw new Error 'exception'

      expect(spyProcess).to.be.calledOnce
      expect(stubLog).to.be.calledOnce

    it 'should create a global object', ->
      expect(global.bumper).to.deep.equal
        foo: 'bar'

    it 'should initialize cli & config', ->
      expect(stubConfig).to.be.calledOnce
      expect(stubCliRun).to.be.calledOnce
