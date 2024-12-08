#!/usr/bin/env ruby

# 引数で渡されたスコアを処理
score = ARGV[0]
scores = score.split(',')
shots = []

# ストライクは "X"、他は数字として扱う
scores.each do |s|
  if s == 'X'
    shots << 10
  else
    shots << s.to_i
  end
end

# 各フレームに分割
frames = []
shots.each_slice(2) do |s|
  frames << s
end


# 10フレーム目の処理では3投目が存在する場合があるため特別に処理
if frames.length > 10
  frames[9] += frames[10] # 10フレーム目に3投がある場合、それを追加
  frames.pop # 余分なフレームを削除
end

# 次のショットを取得する関数
def next_shots(frames, index, count)
  next_frame = frames[index + 1]&.flatten || []
  next_frame[0...count]
end

# スコア計算処理
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

puts point

