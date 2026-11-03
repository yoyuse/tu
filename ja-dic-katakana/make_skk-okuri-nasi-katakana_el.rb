#!/usr/bin/env ruby
# usage: cat SKK-JISYO.L | ./make_sek.sh | ./make_skk-okuri-nasi-katakana_el.rb > ja-dic-katakana.el
#
# 2026-11-03 tu ← ja-kana
# 2026-11-01 auto-insert
# 2026-10-30 from make_hira-kata.rb
# 2026-10-29

$hira_kata = Hash.new()

while ln = gets
  ln.chomp!
  en, cands = $_.split(" ")
  cands = cands.split("/").reject { |c| c.empty? }.each do |kata|
    hira = kata.tr("ァ-ン", "ぁ-ん")
    next if hira == kata
    $hira_kata[hira] = kata
  end
end

puts <<EOF
;;; ja-dic-katakana.el --- KATAKANA supplement to ja-dic  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  YUSE Yosihiro

;; Author: YUSE Yosihiro <yoyuse@gmail.com>
;; Keywords: japanese

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; この辞書は, Emacs に付属する ja-dic/ja-dic.el のかたかな語の不足を
;; 補うために, SKK-JISYO.L から生成された補遺辞書です.

;;; Code:

(eval-when-compile (require 'tu))

(skkdic-set-okuri-nasi-katakana
EOF
$hira_kata.sort_by { |ary| ary[0].encode("EUC-JP") }.each do |ary|
  puts "\"#{ary[0]} #{ary[1]}\""
end
puts <<EOF
)

(provide 'ja-dic-katakana)
;;; ja-dic-katakana.el ends here
EOF
