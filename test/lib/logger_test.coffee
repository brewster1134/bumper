{ expect, sinon } = require '../test_helpers'

Logger = require '../../lib/logger'

describe 'Logger', ->
  logger = null
  sandbox = sinon.createSandbox()

  after ->
    sandbox.restore()

  describe 'new', ->
    stubLog = null

    before ->
      stubLog = sandbox.stub Logger::, '_log'
      global.bumper =
        config:
          verbose: false

    afterEach ->
      stubLog.reset()

    after ->
      stubLog.restore()

    context 'when passed a trace object', ->
      before ->
        global.bumper =
          config:
            verbose: true

      it 'should log as verbose', ->
        new Logger trace: 'message'

        expect(stubLog).to.be.calledWith 'message', false

    context 'when passed an error', ->
      it 'should log error message', ->
        err = new Error 'error message'
        new Logger err

        expect(stubLog).to.be.calledWith 'error message'

    context 'when exit is set', ->
      stubProcess = null

      before ->
        stubProcess = sandbox.stub process, 'exit'

      beforeEach ->
        stubProcess.reset()

      context 'to false', ->
        it 'should not exit', ->
          new Logger 'message', exit: false

          expect(stubProcess).to.not.be.called

      context 'to 0', ->
        it 'should exit with code 0', ->
          new Logger 'message', exit: 0

          expect(stubProcess).to.be.calledOnceWith 0

      context 'to 1', ->
        it 'should exit with code 1', ->
          new Logger 'message', exit: 1

          expect(stubProcess).to.be.calledOnceWith 1

      context 'when not in verbose mode', ->
        before ->
          global.bumper =
            config:
              verbose: false

        it 'should not log traces or verbose option', ->
          new Logger trace: 'message'
          new Logger 'message',
            verbose: true

          expect(stubLog).to.not.be.called

      context 'when in verbose mode', ->
        before ->
          global.bumper =
            config:
              verbose: true

        it 'should log the stack trace on fatal errors', ->
          new Logger 'message', exit: 1

          expect(stubLog.getCall(0)).to.be.calledWith 'message'
          expect(stubLog.getCall(1)).to.be.calledWith sandbox.match 'Error: message'

    context 'when type is set', ->
      it 'should pass the type', ->
        new Logger 'message', type: 'foo'

        expect(stubLog).to.be.calledOnceWith 'message', 'foo'

  describe '_log', ->
    stubConsole = null

    before ->
      logger = sandbox.createStubInstance Logger
      logger._log.restore()

    afterEach ->
      stubConsole.restore()

    context 'when type is set to error/fail', ->
      it 'should output with error', ->
        stubConsole = sandbox.stub console, 'error'
        logger._log 'message', 'fail'

        expect(stubConsole).to.be.calledOnceWith sandbox.match 'message'

    context 'when type is set to alert/info/warning', ->
      it 'should output with warn', ->
        stubConsole = sandbox.stub console, 'warn'
        logger._log 'message', 'info'

        expect(stubConsole).to.be.calledOnceWith sandbox.match 'message'

    context 'when type is set to success/pass', ->
      it 'should output with log', ->
        stubConsole = sandbox.stub console, 'log'
        logger._log 'message', 'pass'

        expect(stubConsole).to.be.calledOnceWith sandbox.match 'message'

    context 'when type is not set', ->
      it 'should output with log', ->
        stubConsole = sandbox.stub console, 'log'
        logger._log 'message'

        expect(stubConsole).to.be.calledOnceWith 'message'
