chalk = require 'chalk'

module.exports =
  class Helpers
    constructor: (@verbose) ->

    # Log a formatted message
    # @arg {String} message - the message to log
    # @arg {String} type - the type of message to log
    # @arg {Error|true} exception, or true to use message as exception
    #
    logMessage: (message, type, exception) ->
      # log based on message type
      switch type
        when 'error', 'fail'
          console.error chalk.red "\n=> #{message} <=\n"
        when 'alert', 'info', 'warning'
          console.warn chalk.yellow "\n=> #{message} <=\n"
        when 'success', 'pass'
          console.log chalk.green "\n=> #{message} <=\n"
        else
          console.log message

      # log full stack trace if a developer
      if exception && @verbose
        if exception == true
          throw new Error message
        else
          throw exception

      # exit node if exception
      process.exit 1 if exception
