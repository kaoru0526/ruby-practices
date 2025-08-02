#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMNS = 3
LSB_3_MASK = 0b111 # 下位3ビットだけを取り出すフィルター（owner/group/other パーミッション用）
OWNER_SHIFT = 6
GROUP_SHIFT = 3
OTHER_SHIFT = 0
SIZE_COLUMN_WIDTH = 6

options = { long: false }
OptionParser.new do |opts|
  opts.on('-l', '--long', '長い形式で表示（3列に縦詰め）') { options[:long] = true }
end.parse!(ARGV)

files = Dir.entries('.').reject { |f| f.start_with?('.') }.sort

def format_mode(path)
  stat = File.stat(path)
  type_char = File.directory?(path) ? 'd' : '-'

  perms_map = {
    0 => '---', 1 => '--x', 2 => '-w-', 3 => '-wx',
    4 => 'r--', 5 => 'r-x', 6 => 'rw-', 7 => 'rwx'
  }

  mode = stat.mode
  owner = perms_map[(mode >> OWNER_SHIFT) & LSB_3_MASK]
  group = perms_map[(mode >> GROUP_SHIFT) & LSB_3_MASK]
  other = perms_map[mode & LSB_3_MASK]

  "#{type_char}#{owner}#{group}#{other}"
end

def format_to_columns(display_strings, columns)
  rows = (display_strings.size + columns - 1) / columns
  padded = display_strings + [''] * (rows * columns - display_strings.size)
  columns_arr = padded.each_slice(rows).to_a

  col_widths = columns_arr.map { |col| col.map(&:size).max || 0 }

  (0...rows).each do |r|
    row = columns_arr.map.with_index do |col, i|
      entry = col[r] || ''
      entry.ljust(col_widths[i] + 2)
    end.join.rstrip
    puts row
  end
end

if options[:long]

  long_lines = files.map do |f|
    stat = File.stat(f)
    perms = format_mode(f)
    size = stat.size.to_s.rjust(SIZE_COLUMN_WIDTH)
    date = stat.mtime.strftime('%b %e %H:%M')
    "#{perms} #{size} #{date} #{f}"
  end
  format_to_columns(long_lines, COLUMNS)
else

  format_to_columns(files, COLUMNS)
end
