#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

TAB_WIDTH = 8
COLUMNS = 3

options = { reverse: false }

OptionParser.new do |opts|
  opts.on('-r', '--reverse') do
    options[:reverse] = true
  end
end.parse!

class FileLister
  def initialize(path: '.', reverse: false)
    @path = path
    @reverse = reverse
  end

  def execute
    files = Dir.entries(@path).reject { |f| f.start_with?('.') }.sort
    files.reverse! if @reverse
    print_list(files)
  end

  private

  def print_list(files)
    display_format(files, COLUMNS)
  end
end

def display_format(files, columns)
  return if files.empty?

  max_length = files.map(&:size).max
  column_width = ((max_length + TAB_WIDTH) / TAB_WIDTH) * TAB_WIDTH

  rows = (files.size + columns - 1) / columns
  padded_files = files + [''] * (rows * columns - files.size)

  padded_files.each_slice(rows).to_a.transpose.each do |row|
    puts row.map { |f| f.ljust(column_width) }.join
  end
end

lister = FileLister.new(path: Dir.pwd, reverse: options[:reverse])
lister.execute
