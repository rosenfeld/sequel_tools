# frozen-string-literal: true

require_relative 'rake_runner'
require 'singleton'
require 'pty'
require 'time'

class RakeExecRunner
  include Singleton

  def initialize
    @rake_runner = RakeRunner.instance # ensure bundle install is called once
  end

  class IncompleteResponse < StandardError; end
  class TimedOut < StandardError; end

  DEFAULT_TIMEOUT = RUBY_PLATFORM == 'java' ? 10 : 2
  def wait_output(task, input, regex, timeout: DEFAULT_TIMEOUT, max_length: 100000)
    PTY.spawn("cd #{@rake_runner.project_root} && bundle exec rake #{task}") do |r, w, pid|
      w.puts input
      output = ''
      wait_until = Time.now + timeout
      begin
        output += r.read_nonblock max_length
        raise IncompleteResponse unless output =~ regex
      rescue IO::WaitReadable, IncompleteResponse
        IO.select([r], [], [], timeout)
        raise TimedOut, "Output didn't match regex after #{timeout}s." if Time.now > wait_until
        retry
      end
      output
    end
  end
end
