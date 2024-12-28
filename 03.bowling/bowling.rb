#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = scores.map { |s| s == 'X' ? 10 : s.to_i }

def split_frames(shots)
  frames = []
  i = 0

  while i < shots.size && frames.size < 9
    if shots[i] == 10
      frames << [shots[i]]
      i += 1
    else
      frames << shots[i, 2]
      i += 2
    end
  end
  frames << shots[i..] if i < shots.size
  frames
end

def next_shots(frames, index, count)
  frames[index + 1..].flatten.first(count)
end

def calculate_score(frames)
  frames.each_with_index.sum do |frame, index|
    if index == 9
      frame.sum
    else
      score = if frame[0] == 10
                10 + next_shots(frames, index, 2).sum
              elsif frame.sum == 10
                10 + next_shots(frames, index, 1).sum
              else
                frame.sum
              end

      score
    end
  end
end

frames = split_frames(shots)
puts calculate_score(frames)
