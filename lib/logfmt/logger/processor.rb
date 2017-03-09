require 'thread'

class Logfmt::Logger::Processor
  def initialize io, formatter
    @io        = io
    @formatter = formatter
    @queue     = ::Queue.new
  end

  def push payload
    @queue.push payload
  end

  def start
    @thread ||= Thread.new do
      loop do
        payload = @queue.pop
        break if payload == :exit
        begin
          @io.puts @formatter.call(payload)
        rescue => e
          STDOUT.puts "Failed to log: #{e.inspect}"
        end
      end

      begin
        while @queue.size != 0
          payload = @queue.pop(true)
          @io.puts @formatter.call(payload)
        end
      rescue ThreadError
        # Nothing left in the queue
      end
    end
  end

  def stop wait=true
    push(:exit)
    @thread.join if wait
  end
end