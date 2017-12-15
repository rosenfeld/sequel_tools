# frozen-string-literal: true

require 'logger'

module SequelTools
  class SequelToolsLogger < Logger
    def initialize(logdev, level)
      super logdev
      self.level = level
      self.formatter = proc do |severity, datetime, progname, msg|
        "[#{severity}] #{msg}\n"
      end
    end

    def add(severity, message = nil, progname = nil, &block)
      message = block_given? ? yield : progname if message.nil?
      return if severity == ERROR &&
        message =~ /relation "schema_(migrations|info)" does not exist/
      super
    end
  end
end
