#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

TAB_WIDTH = 8
COLUMNS = 3

options = {}
opt = OptionParser.new

opt.on('-a', '--all', 'Show hidden files') do
  options[:all] = true
end

opt.parse!(ARGV)

def list_files(directory, columns, show_hidden_files: false)
  files = Dir.entries(directory)
  files.reject! { |f| f.start_with?('.') } unless show_hidden_files

  files.sort!
  print_files(files, columns)
end

def print_files(files, columns)
  return if files.empty?

  max_length = files.map(&:size).max
  column_width = ((max_length + TAB_WIDTH) / TAB_WIDTH) * TAB_WIDTH

  rows = (files.size + columns - 1) / columns
  padded_files = files + [''] * (rows * columns - files.size)

  padded_files.each_slice(rows).to_a.transpose.each do |row|
    puts row.map { |f| f.ljust(column_width) }.join
  end
end

list_files(Dir.pwd, COLUMNS, show_hidden_files: options[:all])
