class Logfmt::Logger
  autoload :Processor, 'logfmt/logger/processor'
  autoload :InlineProcessor, 'logfmt/logger/inline_processor'
  autoload :AsyncProcessor, 'logfmt/logger/async_processor'

  EMPTY_HASH = Hash.new.freeze

  attr_accessor :level

  def initialize io, formatter: Logfmt::Formatter.new, level: Logger::INFO, async: false
    @io = io
    @level = level
    @processor = (async ? AsyncProcessor : InlineProcessor).new(@io, formatter)
    @processor.start

    @_silenced_key = "logfmt_silenced_#{object_id}".freeze
    @_context_key  = "logfmt_context_#{object_id}".freeze
    @_tags_key     = "logfmt_tags_#{object_id}".freeze
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

  def silence *args
    prev = Thread.current[@_silenced_key]
    Thread.current[@_silenced_key] = true
    begin
      yield
    ensure
      Thread.current[@_silenced_key] = prev
    end
  end

  def silenced?
    !!Thread.current[@_silenced_key]
  end

  def tagged *tags
    prev = current_tags
    Thread.current[@_tags_key] = Array(prev) + Array(tags)
    begin
      yield
    ensure
      Thread.current[@_tags_key] = prev
    end
  end

  def current_tags
    Thread.current[@_tags_key]
  end

  def stop
    @processor.stop
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
