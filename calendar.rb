#!/usr/bin/env ruby

# Parses an ICS file and extracts public events with their start and end times

class ICSParser
  Event = Struct.new(:summary, :start, :end)

  def initialize(file_path)
    @file_path = file_path
  end

  def parse_events
    events = []
    current_event = {}
    in_event = false

    File.foreach(@file_path) do |line|
      line = line.strip

      if line == "BEGIN:VEVENT"
        in_event = true
        current_event = {}
      elsif line == "END:VEVENT"
        in_event = false
        if current_event[:summary]&.include?("[public]")
          events << Event.new(
            current_event[:summary],
            # `parse_datetime` returns `Time` and zone, but we want `Date`
            parse_datetime(current_event[:start]).to_date,
            parse_datetime(current_event[:end]).to_date
          )
        end
      elsif in_event
        if line.start_with?("SUMMARY:")
          current_event[:summary] = line.sub("SUMMARY:", "")
        elsif line.start_with?("DTSTART")

          current_event[:start] = extract_datetime_value(line)
        elsif line.start_with?("DTEND")
          current_event[:end] = extract_datetime_value(line)
        end
      end
    end

    events
  end

  private

  def extract_datetime_value(line)
    # Handle both formats:
    # DTSTART:20221026T190000Z
    # DTSTART;VALUE=DATE:20230715
    if line.include?(":")
      line.split(":", 2).last
    else
      line
    end
  end

  def parse_datetime(value)
    return nil unless value

    if value.length == 8
      # All-day event: 20230715
      year = value[0, 4].to_i
      month = value[4, 2].to_i
      day = value[6, 2].to_i
      Time.new(year, month, day)
    elsif value.length >= 15
      # DateTime: 20221026T190000Z or 20221026T190000
      year = value[0, 4].to_i
      month = value[4, 2].to_i
      day = value[6, 2].to_i
      hour = value[9, 2].to_i
      min = value[11, 2].to_i
      sec = value[13, 2].to_i

      if value.end_with?("Z")
        Time.utc(year, month, day, hour, min, sec)
      else
        Time.new(year, month, day, hour, min, sec)
      end
    else
      value
    end
  end
end
