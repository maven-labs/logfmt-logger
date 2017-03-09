class Logfmt::Logger
  autoload :Processor, 'logfmt/logger/processor'

  EMPTY_HASH = Hash.new.freeze

  attr_accessor :level

  def initialize io, formatter: Logfmt::Formatter.new, level: Logger::INFO
    @io = io
    @formatter = formatter
    @level = level
    @mutex = Mutex.new
    @processor = Logfmt::Logger::Processor.new(@io, @formatter)
    @processor.start
  end

  def formatter
    @formatter
  end

  def formatter= val
  end


  def emit data
    data[:tags] = Array(current_tags) + Array(data[:tags])
    data[:time] = Time.now
    @processor.push data
    nil
  rescue => e
    puts "Fuck: #{e.inspect}"
  end


  def method_missing(symbol, &block)
    puts "Missing Method: #{symbol}"
    super
  end

  def extend *args
    # ignore
  end

  def silence *args
    prev = Thread.current[:logfmt_silenced]
    Thread.current[:logfmt_silenced] = true
    begin
      yield
    ensure
      Thread.current[:logfmt_silenced] = prev
    end
  end

  def silenced?
    !!Thread.current[:logfmt_silenced]
  end

  def tagged *tags
    prev = current_tags
    Thread.current[:logfmt_tags] = Array(prev) + Array(tags)
    begin
      yield
    ensure
      Thread.current[:logfmt_tags] = prev
    end
  end

  def current_tags
    Thread.current[:logfmt_tags]
  end



  # LOGGING ----------------

  def error message=nil, context=EMPTY_HASH
    return if silenced?
    message = yield if message.nil? && block_given?
    return unless error? && !message.nil?
    emit(context.merge(level: Logger::WARN, message: message))
  end

  def error?
    @level <= Logger::ERROR
  end


  def warn message=nil, context=EMPTY_HASH
    return if silenced?
    message = yield if message.nil? && block_given?
    return unless warn? && !message.nil?
    emit(context.merge(level: Logger::WARN, message: message))
  end

  def warn?
    @level <= Logger::WARN
  end


  def info message=nil, context=EMPTY_HASH
    return if silenced?
    message = yield if message.nil? && block_given?
    return unless info? && !message.nil?
    emit(context.merge(level: Logger::INFO, message: message))
  end

  def info?
    @level <= Logger::INFO
  end


  def debug message=nil, context=EMPTY_HASH
    return if silenced?
    message = yield if message.nil? && block_given?
    return unless debug? && !message.nil?
    emit(context.merge(level: Logger::DEBUG, message: message))
  end

  def debug?
    @level <= Logger::DEBUG
  end
end
