_ = require 'lodash'
chalk = require 'chalk'

module.exports =
  class Logger extends Error
    constructor: (message, options = {}) ->
      super message

      options = _.merge
        exit: false
        type: 'pass'
      , options

      @_log message, options.type

      if Number.isInteger options.exit
        # log stack trace if error
        if global.bumper.verbose && options.exit != 0
          @_log @stack

        process.exit options.exit

    # Log a formatted message
    # @arg {String} message - the message to log
    # @arg {String} type - the type of message to log
    #
    # _log: (message, type, error, verbose) ->
    _log: (message, type) ->
      switch type
        when 'error', 'fail'
          console.error chalk.red "\n=> #{message} <=\n"
        when 'alert', 'info', 'warning'
          console.warn chalk.yellow "\n=> #{message} <=\n"
        when 'success', 'pass'
          console.log chalk.green "\n=> #{message} <=\n"
        else
          console.log message
