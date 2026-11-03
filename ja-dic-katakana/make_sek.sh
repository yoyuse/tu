#!/bin/sh
# usage: cat SKK-JISYO.L | ./make_sek.sh > sek_utf8.txt
# 2026-09-26
cat - | nkf -Ew | ruby -ne '
    en, cands = $_.split(" ")
    next unless cands
    cands = cands.split("/").collect { |c| c.sub(/;.*/, "") }.filter { |c|
        /^[ァ-ンヴヵヶー・]+$/ =~ c
    }
    cands = cands.join("/")
    puts "#{en} /#{cands}/" if /^[a-z]+$/ =~ en && 0 < cands.length
'
