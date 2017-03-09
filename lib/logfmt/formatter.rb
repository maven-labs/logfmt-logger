class Logfmt::Formatter
  def initialize justify: false, level_key: :l, message_key: :msg, escape_strings: true, level_labels: Logger::SEV_LABEL, timestamp: true
    @justify        = justify
    @level_key      = level_key
    @level_labels   = level_labels
    @message_key    = message_key
    @escape_strings = escape_strings
    @timestamp      = timestamp

    if @timestamp
      require 'time'
    end
  end

  def call payload
    line = Array.new

    if time = payload.delete(:time)
       if @timestamp
         line << format(:time, time.getutc.iso8601)
       end
    end

    if val = payload.delete(:level)
      line << format_level(val)
    end

    if val = payload.delete(:message)
      line << format_message(val)
    end

    if val = payload.delete(:event)
      line << format(:event, val)
    end

    tags = payload.delete(:tags)

    payload.each do |key, val|
      line << format(key, val)
    end

    if tags && tags.is_a?(Array)
      line << nil
      line.concat tags
    end

    line.join(" ")
  end


  def format_level val
    if @justify
      @_level_justify_length ||= @level_labels.map{ |l| l.size }.max + 1
      format(@level_key, @level_labels[val], @_level_justify_length)
    else
      format(@level_key, @level_labels[val])
    end
  end

  def format_message val
    if @justify
      format(@message_key, val, 100)
    else
      format(@message_key, val)
    end
  end


  def format key, val, justify=nil
    "#{key}=#{format_val(val, justify)}"
  end

  def format_val val, justify=nil
    if @escape_strings && val.is_a?(String) && val.match(/\s/)
      val = val.to_json
    elsif val.is_a?(Float)
      val = Kernel.format('%.2f', val)
    else
      val = val.to_s
    end

    val = val.gsub(/\s/, ' ')

    if justify
      color_pad = [val.size - val.gsub(/\e\[([;\d]+)?m/, '').size, 0].max
      val.ljust(justify + color_pad)
    else
      val
    end
  end
end
