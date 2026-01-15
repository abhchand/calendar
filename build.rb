#!/usr/bin/env ruby

require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'date'
require 'erb'
require 'ostruct'
require 'pry'

week_starts_on = 'Wed'

start_date = Date.new(Date.today.year, 1, 1)
end_date = Date.new(Date.today.year, 12, 31)

week_starts_on_idx = Date::ABBR_DAYNAMES.index(week_starts_on)
start_date_idx = start_date.wday


# Adjust start date so that the calendar begins on the desired "start of week"
while(true) do
  break if start_date.wday == week_starts_on_idx
  start_date = start_date - 1
end

#
# Build calendar structure
#

calendar = 12.times.to_a.map { Array.new }

# Initialize calendar with months and days
(start_date..end_date).each do |date|
  # We only care about days that are the start of the week
  next unless date.wday == week_starts_on_idx

  # Build week
  week = []
  (date..(date + 6)).to_a.each { |day| week << day }

  # Add week to the relevant month
  # If a week spans across a new month, we want to include this week in the
  # NEW month, so we look at the last day
  month_idx = (date + 6).month - 1
  calendar[month_idx] << week
end

#
# Render Template
#

template = File.read('index.html.erb')
vars = { calendar: calendar }

output = ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
File.open(__dir__ + '/doc/index.html', 'w') { |file| file.write(output) }
