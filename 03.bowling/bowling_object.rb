#!/usr/bin/env ruby

# 引数で渡されたスコアを処理
score = ARGV[0]
scores = score.split(',')
shots = scores.map { |s| s == 'X' ? 10 : s.to_i }

# フレームを分割するメソッド
def split_frames(shots)
  frames = []
  i = 0

  while i < shots.size
    if frames.size < 9
      if shots[i] == 10
        frames << [shots[i]]
        i += 1
      else
        frames << shots[i, 2]
        i += 2
      end
    else
      frames << shots[i..]
      break
    end
  end

  frames
end

# 次の投球を取得するメソッド
def next_shots(frames, index, count)
  frames[index + 1..].flatten.first(count)
end

# スコアを計算するメソッド
def calculate_score(frames)
  total_score = 0

  frames.each_with_index do |frame, index|
    if index == 9
      total_score += frame.sum
    elsif frame[0] == 10
      total_score += 10 + next_shots(frames, index, 2).sum
    elsif frame.sum == 10
      total_score += 10 + next_shots(frames, index, 1).sum
    else
      total_score += frame.sum
    end
  end

  total_score
end

frames = split_frames(shots)
puts calculate_score(frames)
