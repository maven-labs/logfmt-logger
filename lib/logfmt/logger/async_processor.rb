require 'thread'

class Logfmt::Logger::AsyncProcessor < Logfmt::Logger::Processor
  def initialize io, formatter
    super(io, formatter)
    @queue = ::Queue.new
  end

  def push payload
    @queue.push payload
  end

  def start
    @thread ||= Thread.new do
      loop do
        payload = @queue.pop
        break if payload == :exit
        write(payload)
      end

      begin
        while @queue.size != 0
          payload = @queue.pop(true)
          write(payload)
        end
      rescue ThreadError
        # Nothing left in the queue
      end
    end
  end

  def stop wait=true
    push(:exit)
    @thread.join if wait
    @thread = nil
  end
end
