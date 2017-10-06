class Logfmt::Logger::Processor
  def initialize io, formatter
    @io        = io
    @formatter = formatter
  end

  def push payload
    raise NotImplementedError
  end

  def start
    # noop
  end

  def stop(*args)
    # noop
  end

  private
  def write(payload)
    begin
      @io.puts @formatter.call(payload)
    rescue => e
      STDERR.puts "Failed to log error=#{e.inspect} payload=#{payload.inspect} from=#{e.backtrace[0]}"
    end
  end
end
