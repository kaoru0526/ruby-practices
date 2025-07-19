#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

options = {}
opt = OptionParser.new

opt.on('-a', '--all', 'Show hidden files') do
  options[:all] = true
end

opt.parse!(ARGV)

puts "オプション: #{options}"
