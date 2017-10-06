class Logfmt::Metrics
  def initialize logger=Logfmt::Logger.new
    @log = logger
  end

  def event event, payload={}
    @log.emit payload.merge(event: event)
  end

  def time event, payload={}
    return unless block_given?
    start = Time.now
    result = yield
    emit_time(event, payload, start)
    result
  rescue => exception
    emit_time(event, payload, start, exception)
    raise exception
  end

  private
  def emit_time(event, payload, start, exception=nil)
    finish   = Time.now
    duration = (finish - start) * 1000.0
    payload = payload.merge(event: event, duration: duration)
    if exception != nil
      payload = payload.merge(exception: exception.class, exception_msg: exception.message)
    end
    @log.emit( payload )
  end
end
