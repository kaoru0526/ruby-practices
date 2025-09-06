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

PERMS_MAP = {
  0 => '---', 1 => '--x', 2 => '-w-', 3 => '-wx',
  4 => 'r--', 5 => 'r-x', 6 => 'rw-', 7 => 'rwx'
}.freeze

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

def long_fields(stat, file)
  [
    format_mode(file),
    stat.nlink.to_s.rjust(LINKS_COLUMN_WIDTH),
    Etc.getpwuid(stat.uid).name,
    Etc.getgrgid(stat.gid).name,
    stat.size.to_s.rjust(SIZE_COLUMN_WIDTH),
    stat.mtime.strftime('%-m %e %H:%M'),
    file
  ]
end

def long_line(file)
  stat = File.stat(file)
  long_fields(stat, file).join(' ')
end

def print_long_line(file)
  puts long_line(file)
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

def prepare_columns(entries, columns, rows)
  padded = entries.map(&:to_s) + Array.new([rows * columns - entries.size, 0].max, '')
  cols   = padded.each_slice(rows).to_a
  widths = cols.map { |col| (col.max_by(&:size) || '').size + COLUMN_PADDING }

  [cols.transpose, widths]
end

def format_to_columns(display_strings, columns)
  return if display_strings.empty?

  rows = (display_strings.size + columns - 1) / columns
  row_arrays, ljust_widths = prepare_columns(display_strings, columns, rows)

  row_arrays.each do |row|
    puts row.zip(ljust_widths).map { |val, w| val.ljust(w) }.join.rstrip
  end
end

def print_files(files, columns)
  format_to_columns(files, columns)
end

def format_mode(path)
  stat = File.stat(path)
  mode = stat.mode
  type = File.directory?(path) ? 'd' : '-'
  [
    type,
    PERMS_MAP[(mode >> OWNER_SHIFT) & LSB_3_MASK],
    PERMS_MAP[(mode >> GROUP_SHIFT) & LSB_3_MASK],
    PERMS_MAP[mode & LSB_3_MASK]
  ].join
end

def list_files(directory, show_all_files: false, reverse: false)
  entries = Dir.entries(directory)
  files = show_all_files ? entries : entries.reject { |f| f.start_with?('.') }
  files.sort!
  files.reverse! if reverse
  files
end

main
