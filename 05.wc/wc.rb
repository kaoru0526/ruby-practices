#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def parse_options_from_argv(argv)
  opts = { l: false, w: false, c: false }

  parser = OptionParser.new do |o|
    o.on('-l', 'lines')  { opts[:l] = true }
    o.on('-w', 'words')  { opts[:w] = true }
    o.on('-c', 'bytes')  { opts[:c] = true }
  end

  remaining_filenames = parser.parse(argv)

  opts = opts.transform_values { true } if opts.values.none?

  [opts, remaining_filenames]
end

def count_contents(content)
  {
    l: content.count("\n"),
    w: content.split.size,
    c: content.bytesize
  }
end

def sum_counts(results)
  totals = { l: 0, w: 0, c: 0 }
  results.each do |result|
    totals[:l] += result[:counts][:l]
    totals[:w] += result[:counts][:w]
    totals[:c] += result[:counts][:c]
  end
  totals
end

MIN_FIELD_WIDTH = 8

def max_widths(enabled_options, rows, sum_counts: nil, min_width: MIN_FIELD_WIDTH)
  all = rows.map { |result| result[:counts] }
  all << sum_counts if sum_counts
  enabled_options.to_h do |flag|
    max_digits = all.map { |h| h[flag].to_s.size }.max || 1
    [flag, [max_digits, min_width].max]
  end
end

def format_line(enabled_options, widths, counts, name = nil)
  fields = enabled_options.map { |flag| counts[flag].to_s.rjust(widths[flag]) }.join(' ')
  name ? "#{fields} #{name}" : fields
end

options, filenames = parse_options_from_argv(ARGV.dup)
enabled_options = %i[l w c].select { |flag| options[flag] }

inputs = if filenames.empty?
           content = $stdin.read
           [{ name: nil, content: content }]
         else
           filenames.map do |name|
             { name: name, content: File.binread(name) }
           end
         end

results = inputs.map do |input|
  {
    name: input[:name],
    counts: count_contents(input[:content])
  }
end

totals = results.size >= 2 ? sum_counts(results) : nil
widths = max_widths(enabled_options, results, sum_counts: totals)

results.each do |result|
  puts format_line(enabled_options, widths, result[:counts], result[:name])
end

puts format_line(enabled_options, widths, totals, 'total') if totals
