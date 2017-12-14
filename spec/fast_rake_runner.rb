require 'bundler/setup'
require 'benchmark'
require 'rake'

class FastRakeRunner

  def self.cmd(command)
    if command =~ /Rakefile/
      command = command.sub(/Rakefile/, "#{__dir__}/sample_project/Rakefile")
    else
      command = "-f #{__dir__}/sample_project/Rakefile #{command}"
    end
    command.split(/\s/)
  end

  def self.run_rake(args)
    out_reader, out_writer = IO.pipe
    err_reader, err_writer = IO.pipe
    pid = Process.fork do
      [out_reader, err_reader].each &:close
      STDOUT.reopen out_writer
      STDERR.reopen err_writer
      Rake.application.run cmd(args)
    end
    [out_writer, err_writer].each &:close
    pid, status = Process.wait2 pid
    [ out_reader.read, err_reader.read, status ]
  end
end
