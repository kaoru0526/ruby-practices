#!/usr/bin/env ruby
require 'optparse'
require 'date'

option = {}

opt = OptionParser.new

opt.on('-m MONTH') do |m|
  m = m.to_i
  if m.between?(1, 12)
    option[:m] = m
  else
    puts "エラー: 月は1から12の間で指定してください"
    exit
  end
end

opt.on('-y YEAR') do |y|
  y = y.to_i
  if y.between?(1970, 2100)
    option[:y] = y
  else
    puts "エラー: 年は1970から2100の間で指定してください"
    exit
  end
end

opt.parse!(ARGV)

month = option[:m] || Date.today.month
year = option[:y] || Date.today.year

first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

puts "     #{month}月 #{year}"
puts "日 月 火 水 木 金 土"

print "   " * first_day.wday

(first_day..last_day).each do |date|
  print date.day.to_s.rjust(2) + " "
  print "\n" if date.saturday?
end

print "\n\n"
