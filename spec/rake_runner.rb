# frozen-string-literal: true

require 'singleton'
require_relative 'fast_rake_runner'

class RakeRunner
  include Singleton

  attr_reader :project_root

  def initialize
    require 'open3'
    @project_root = File.expand_path 'sample_project', __dir__
    run_cmd('bundle').success or raise "Couldn't run bundle on sample project"
  end

  def run_cmd(command)
    TaskResult.new "command: #{command}", *Open3.capture3(cmd(command))
  end

  def cmd(command)
    %Q{cd "#{@project_root}" && #{command}}
  end

  def run_task(task)
    TaskResult.new task, *(
      ENV['FORK_RAKE'] && RUBY_PLATFORM != 'java' ?
        FastRakeRunner.run_rake(task) :
        Open3.capture3(cmd("bundle exec rake #{task}"))
    )
  end

  class TaskResult
    attr_reader :name, :stdout, :stderr, :success, :status
    def initialize(name, stdout, stderr, status)
      @name, @stdout, @stderr, @status = name, stdout, stderr, status
      @success = status == 0
    end
  end
end
