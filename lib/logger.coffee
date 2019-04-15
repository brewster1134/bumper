_ = require 'lodash'
chalk = require 'chalk'

module.exports =
  class Logger extends Error
    constructor: (error, options = {}) ->
      super error

      # if verbose flag is set, only log it if in verbose mode
      return if options.verbose && !global.bumper.config.verbose

      # create error instance if only string is passed
      if typeof error == 'string'
        error = new Error error

      # set defaults
      options = _.merge
        exit: false
        type: 'pass'
        verbose: false
      , options

      # log message
      @_log error.message, options.type

      if Number.isInteger options.exit
        # log stack trace for fatal errors
        if global.bumper.config.verbose && options.exit != 0
          @_log error.stack

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
