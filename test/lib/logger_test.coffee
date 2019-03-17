{ expect, sinon } = require '../test_helpers'

Logger = require '../../lib/logger'

describe 'Logger', ->
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe '.constructor', ->
    stubLog = null
    stubLogStack = null

    before ->
      stubLog = sandbox.stub Logger::, '_log'
      stubLogStack = sandbox.stub Logger::, '_logStack'

      new Logger 'message',
        exit: false
        type: 'pass'

    after ->
      stubLog.restore()
      stubLogStack.restore()

    beforeEach ->
      stubLog.reset()

    context 'when exit option is set', ->
      stubProcess = sandbox.stub process, 'exit'

      beforeEach ->
        stubProcess.reset()

      context 'to false', ->
        it 'should not exit', ->
          new Logger 'message',
            exit: false

          expect(stubProcess).to.not.be.called

      context 'to 0', ->
        it 'should exit with code 0', ->
          new Logger 'message',
            exit: 0

          expect(stubProcess).to.be.calledOnceWith 0
          expect(stubLogStack).to.not.be.called

      context 'to 1', ->
        it 'should exit with code 1', ->
          new Logger 'message',
            exit: 1

          expect(stubProcess).to.be.calledOnceWith 1
          expect(stubLogStack).to.be.calledOnce

    context 'when type option is set', ->
      it 'should pass the type', ->
        new Logger 'message',
          type: 'foo'

        expect(stubLog).to.be.calledOnceWith 'message', 'foo'

  describe '#_log', ->
    logger = null

    before ->
      logger = sandbox.createStubInstance Logger
      logger._log.restore()

    context 'when type is set to error/fail', ->
      it 'should output with error', ->
        stubConsole = sandbox.stub console, 'error'
        logger._log 'message', 'fail'

        expect(stubConsole).to.be.calledOnceWith sinon.match 'message'

        stubConsole.restore()

    context 'when type is set to alert/info/warning', ->
      it 'should output with warn', ->
        stubConsole = sandbox.stub console, 'warn'
        logger._log 'message', 'info'

        expect(stubConsole).to.be.calledOnceWith sinon.match 'message'

        stubConsole.restore()

    context 'when type is set to success/pass', ->
      it 'should output with log', ->
        stubConsole = sandbox.stub console, 'log'
        logger._log 'message', 'pass'

        expect(stubConsole).to.be.calledOnceWith sinon.match 'message'

        stubConsole.restore()

    context 'when type is not set', ->
      it 'should output with log', ->
        stubConsole = sandbox.stub console, 'log'
        logger._log 'message'

        expect(stubConsole).to.be.calledOnceWith 'message'

        stubConsole.restore()
