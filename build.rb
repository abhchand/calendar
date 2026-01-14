#!/usr/bin/env ruby

require 'bundler/inline'
require 'date'

gemfile do
  source 'https://rubygems.org'
  gem 'activesupport', '~> 7.1'
end

week_starts_on = 'Wed'

start_date = Date.new(Date.today.year, 1, 1)
end_date = Date.new(Date.today.year, 12, 31)

week_starts_on_idx = Date::ABBR_DAYNAMES.index('Wed')
start_date_idx = start_date.wday

#
# Build calendar structure
#

calendar = []
(start_date..end_date).each do |date|
  week = { days: [], desc: [] }

  if date.send("#{week_starts_on}?")
    (date..(date + 6)).to_a.each do |day|
      week[:days] << day
    end
  end

  calendar << week
end

#
# Calculate Padded Days
#

# Calculate the number of padded / fake days up front
# e.g. If week starts on a tuesday, but year starts on a friday, we need 3 days
# of padding
num_padded_days =
  case
  when start_date_idx > week_starts_on_idx
    start_date_idx - week_starts_on_idx
  when start_date_idx < week_starts_on_idx
    7 - week_starts_on_idx + start_date_idx
  else
    0
  end

num_padded_days.times do |n|
  calendar[0][:days].unshift(start_date - n.days)
end


require 'pry';
binding.pry
