#!/usr/bin/env ruby

# 引数で渡されたスコアを処理
score = ARGV[0]
scores = score.split(',')
shots = []

# ストライクは "X"、他は数字として扱う
scores.each do |s|
  shots << (s == 'X' ? 10 : s.to_i)
end

# 各フレームに分割（10フレーム目の特別処理を除く）
frames = []
i = 0
while i < shots.size
  if frames.size < 9 # 10フレーム目以外
    if shots[i] == 10 # ストライクの場合は1投だけのフレーム
      frames << [shots[i]]
      i += 1
    else
      frames << shots[i, 2] # 通常のフレームは2投で構成
      i += 2
    end
  else # 10フレーム目の処理
    frames << shots[i..-1] # 残りの投球をすべて10フレーム目として扱う
    break
  end
end

# 次のショットを取得する関数を共通化（フレームの枠内から必要な投数を取得）
def next_shots(frames, index, count)
  following_frames = frames[index + 1..-1].flatten || []
  following_frames[0, count]
end

# スコア計算処理
def calculate_score(frames)
  point = 0

  frames.each_with_index do |frame, index|
    if index == 9 # 10フレーム目の特別な処理
      point += frame.sum # 10フレーム目は最大3投分を加算
    elsif frame[0] == 10 # ストライクの場合
      # 次の2投分の点を加算
      point += 10 + next_shots(frames, index, 2).sum
    elsif frame.sum == 10 # スペアの場合
      # 次の1投分の点を加算
      point += 10 + next_shots(frames, index, 1).sum
    else
      # 通常のフレームの得点をそのまま加算
      point += frame.sum
    end
  end

  point
end

# 計算したスコアを表示
puts calculate_score(frames)
