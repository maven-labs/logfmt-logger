class Logfmt::Logger::InlineProcessor < Logfmt::Logger::Processor
  def push payload
    write(payload)
  end
end
