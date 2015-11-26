module Bundle
  def self.system(cmd, *args)
    verbose = ARGV.verbose?
    logs = []
    success = nil
    IO.popen([cmd, *args], :err => [:child, :out]) do |pipe|
      while buf = pipe.gets
        puts buf if verbose
        logs << buf
      end
      Process.wait(pipe.pid)
      success = $?.success?
      pipe.close
    end
    puts logs.join unless success || verbose
    success
  end

  def self.brewfile
    if ARGV.include?("--global")
      file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
    else
      filename = ARGV.value("file")
      filename = "/dev/stdin" if filename == "-"
      filename ||= "Brewfile"
      file = Pathname.new(filename).expand_path(Dir.pwd)
    end
    file.read
  rescue Errno::ENOENT
    raise "No Brewfile found"
  end
end
