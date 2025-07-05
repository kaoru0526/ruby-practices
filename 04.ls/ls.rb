#!/usr/bin/env ruby
# frozen_string_literal: true

def list_files(directory, columns)
  files = Dir.entries(directory).sort - ['.', '..']
  print_files(files, columns)
end

def print_files(files, columns)
  rows = (files.size + columns - 1) / columns
  padded = files + [''] * (rows * columns - files.size)
  padded.each_slice(rows).to_a.transpose.each do |row|
    puts row.map { |f| f.ljust(20) }.join
  end
end

list_files(Dir.pwd, 3)
