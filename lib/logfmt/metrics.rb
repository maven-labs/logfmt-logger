class Logfmt::Metrics
  def initialize logger=Logfmt::Logger.new
    @log = logger
  end

  def event event, payload={}
    @log.emit payload.merge(event: event)
  end

  def time event, payload={}
    start = Time.now

    yield

  ensure
    finish   = Time.now
    duration = (finish - start) * 1000.0
    @log.emit( payload.merge(event: event, duration: duration) )
  end
end