#!/usr/bin/env ruby
require 'optparse' #OptionPaser オブジェクト opt を生成する
require 'date'

option = {}#オプションを取り扱うブロックをoptに登録する

# オプション解析設定
opt = OptionParser.new#クラスが作成されてopt変数にインスタンス代入する

opt.on('-m MONTH') do |m|
  m = m.to_i
  if m.between?(1, 12)#オプションmを作り、0-12までの数字を入れられる仕組みで真偽判定できる
    option[:m] = m
  else
    puts "エラー: 月は1から12の間で指定してください"
    exit
  end
end

opt.on('-y YEAR') do |y|
  y = y.to_i
  if y.between?(1970, 2100)
    option[:y] = y
  else
    puts "エラー: 年は1970から2100の間で指定してください"
    exit
  end
end

opt.parse!(ARGV)

# 月と年の指定がなければ現在の月と年を使う
month = option[:m] || Date.today.month
year = option[:y] || Date.today.year

# カレンダーの表示
first_day = Date.new(year, month, 1)
last_day = Date.new(year, month, -1)

puts "     #{month}月 #{year}"
puts "日 月 火 水 木 金 土"

# 最初の週の空白を設定
print "   " * first_day.wday

# 各日付を表示
(first_day..last_day).each do |date|
  print date.day.to_s.rjust(2) + " "
  print "\n" if date.saturday?
end

# 最後に空行を追加
print "\n\n"
