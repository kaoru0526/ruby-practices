#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMNS = 3
LSB_3_MASK = 0b111 # 下位3ビットだけを取り出すフィルター（owner/group/other パーミッション用）
OWNER_SHIFT = 6
GROUP_SHIFT = 3
OTHER_SHIFT = 0
SIZE_COLUMN_WIDTH = 6
COLUMN_PADDING = 6
LINKS_COLUMN_WIDTH = 2

def parse_options(argv)
  options = { all: false, reverse: false, long: false }

  OptionParser.new do |opts|
    opts.on('-a', '--all', 'Show hidden files', '隠しファイルを表示する') { options[:all] = true }
    opts.on('-r', '--reverse', '逆順で表示') { options[:reverse] = true }
    opts.on('-l', '--long', '長い形式で表示（3列に縦詰め）') { options[:long] = true }
  end.parse!(argv)

  options
end

def print_total_blocks(files)
  total = files.sum { |f| File.stat(f).blocks }
  puts "total #{total}"
end

def long_line(file)
  stat = File.stat(file)
  perms = format_mode(file)
  links = stat.nlink.to_s.rjust(LINKS_COLUMN_WIDTH)
  user = Etc.getpwuid(stat.uid).name
  group = Etc.getgrgid(stat.gid).name
  size = stat.size.to_s.rjust(SIZE_COLUMN_WIDTH)
  date = stat.mtime.strftime('%-m %e %H:%M')
  "#{perms} #{links} #{user}  #{group}  #{size} #{date} #{file}"
end

def print_long_line(_file)
  puts long_line(f)
end

def main
  options = parse_options(ARGV)
  files = list_files('.', show_all_files: options[:all], reverse: options[:reverse]) # '.' = カレントディレクトリ

  if options[:long]
    print_total_blocks(files)
    files.each { |f| print_long_line(f) }
  else
    print_files(files, COLUMNS)
  end
end

def format_to_columns(display_strings, columns)
  return if display_strings.empty?
  
  rows = (display_strings.size + columns - 1) / columns
  padded = display_strings + [''] * (rows * columns - display_strings.size)
  columns_arr = padded.each_slice(rows).to_a

  col_widths = columns_arr.map { |col| col.map(&:size).max || 0 }

  (0...rows).each do |r|
    row = columns_arr.map.with_index do |col, i|
      entry = col[r] || ''
      entry.ljust(col_widths[i] + COLUMN_PADDING)
    end.join.rstrip
    puts row
  end
end

def print_files(files, columns)
  format_to_columns(files, columns)
end

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

def list_files(directory, show_all_files: false, reverse: false)
  entries = Dir.entries(directory)
  files = show_all_files ? entries : entries.reject { |f| f.start_with?('.') }
  files.sort!
  files.reverse! if reverse
  files
end

main
