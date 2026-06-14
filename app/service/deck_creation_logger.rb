# frozen_string_literal: true

class DeckCreationLogger
  LOG_PATH = Rails.root.join('log/deck_creation.log')

  class << self
    def info(message, **)
      log(:info, message, **)
    end

    def warn(message, **)
      log(:warn, message, **)
    end

    def error(message, **)
      log(:error, message, **)
    end

    def exception(message, error, **)
      log(:error, "#{message}: #{error.class}: #{error.message}", **)
      error.backtrace&.first(25)&.each do |line|
        log(:error, "  #{line}")
      end
    end

    def reset!
      @logger = nil
    end

    private

    def log(level, message, **)
      logger.public_send(level, format_message(message, **))
    end

    def format_message(message, **context)
      return message if context.empty?

      "#{message} | #{context.map { |key, value| "#{key}=#{value}" }.join(' ')}"
    end

    def logger
      @logger ||= build_logger
    end

    def build_logger
      FileUtils.mkdir_p(LOG_PATH.dirname)
      ActiveSupport::Logger.new(LOG_PATH).tap do |log|
        log.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.utc.iso8601(3)}] #{severity} -- #{msg}\n"
        end
        log.level = Logger::DEBUG
      end
    end
  end
end
