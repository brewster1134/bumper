_ = require 'lodash'
chalk = require 'chalk'

module.exports =
  class Logger extends Error
    constructor: (message, options = {}) ->
      # extract message from various object types
      if typeof message == 'object'
        # check if verbose shorthand trace: 'message' was passed
        if message.trace?
          message = message.trace
          options.verbose = true
          if !options.type?
            options.type = false

        # check if existing error object was passed
        else if message instanceof Error
          message = message.message

      # create error instance from message
      error = super message

      # only log verbose messages in verbose mode
      return if options.verbose && !global.bumper.config.verbose

      # apply defaults
      options = _.merge
        exit: false
        type: 'pass'
      , options

      # log message
      @_log message, options.type

      # handle custom exit codes
      if Number.isInteger options.exit
        # log stack trace for fatal errors
        if global.bumper.config.verbose && options.exit != 0
          @_log error.stack

        process.exit options.exit

      else
        return @

    # Log a formatted message
    # @arg {string} message - the message to log
    # @arg {string} type - the type of message to log
    #
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
