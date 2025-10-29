#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def parse_options!(argv)
  opts = { l: false, w: false, c: false }

  OptionParser.new do |o|
    o.on('-l', 'lines')  { opts[:l] = true }
    o.on('-w', 'words')  { opts[:w] = true }
    o.on('-c', 'bytes')  { opts[:c] = true }
  end.parse!(argv)

  opts = opts.transform_values { true } if opts.values.none?
  opts
end

def count_lwb(content)
  {
    l: content.count("\n"),
    w: content.split.size,
    c: content.bytesize
  }
end

def sum_counts(results)
  totals = { l: 0, w: 0, c: 0 }
  results.each do |r|
    totals[:l] += r[:counts][:l]
    totals[:w] += r[:counts][:w]
    totals[:c] += r[:counts][:c]
  end
  totals
end

MIN_FIELD_WIDTH = 8

def max_widths(keys, rows, sum_counts: nil, min_width: MIN_FIELD_WIDTH)
  all = rows.map { |r| r[:counts] }
  all << sum_counts if sum_counts
  keys.to_h do |k|
    max_digits = all.map { |h| h[k].to_s.size }.max || 1
    [k, [max_digits, min_width].max]
  end
end

def format_line(keys, widths, counts, name = nil)
  fields = keys.map { |k| counts[k].to_s.rjust(widths[k]) }.join(' ')
  name ? "#{fields} #{name}" : fields
end

opts = parse_options!(ARGV)
keys = %i[l w c].select { |k| opts[k] }

if ARGV.empty?
  data = $stdin.read
  stdin_counts = count_lwb(data)

  widths = max_widths(keys, [{ counts: stdin_counts }])
  puts format_line(keys, widths, stdin_counts)

else
  results = ARGV.map do |name|
    content = File.binread(name)
    { name: name, counts: count_lwb(content) }
  end

  totals = results.size >= 2 ? sum_counts(results) : nil
  widths = max_widths(keys, results, sum_counts: totals)

  results.each do |r|
    puts format_line(keys, widths, r[:counts], r[:name])
  end
  puts format_line(keys, widths, totals, 'total') if totals
end
