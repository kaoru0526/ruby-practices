#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = scores.map { |s| s == 'X' ? 10 : s.to_i }

def create_frames(shots)
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

def bonus_score(frames, index, bonus_shot)
  frames[index + 1..].flatten.first(bonus_shot).sum
end

def calculate_score(frames)
  frames.each_with_index.sum do |frame, index|
    bonus_shot = if frame[0] == 10
                   2
                 elsif frame.sum == 10
                   1
                 else
                   0
                 end
    frame.sum + (index == 9 ? 0 : bonus_score(frames, index, bonus_shot))
  end
end

frames = create_frames(shots)
total_score = calculate_score(frames)
puts total_score
