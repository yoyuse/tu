# HISTORY

## tu.el

- 2026-11-03 first commit
- 2026-11-03 tu.el from ja-kana.el

## before tu.el

- 2026-11-02 濁点後置記号: `゛`(`め`) `↑←↓→`(`にまのり`)
- 2026-11-02 半濁点後置記号: `゜`(`め`) `〆ゝ々〃※`(`しくまのこ`)
- 2026-11-02 `-mode` ← `-active-mode`
- 2026-11-02 fix-261102/ で様子を見る…
- 2026-11-02 `S-SPC` to `ja-kana-shift-space`
- 2026-11-02 `ja-kana-ascii-or-transient` ← `ja-kana-off-or-ascii`
- 2026-11-02 timer (遅延実行) を使わない
- 2026-11-01 `<muhenkan>` to `ja-kana-off-or-ascii`
- 2026-11-01 `<henkan>` to `ja-kana-hiragana-or-katakana`
- 2026-11-01 英かな変換を候補選択方式にしたら動作しなくなった. 機能を削除する
- 2026-10-31 やっぱり `SPC` で英かな変換 (← `S-変換`)
- 2026-10-30 半濁点後置記号: `゛゜`(`ねる`)
- 2026-10-30 英かな変換モードでは `S-変換` で英かな変換 (← `SPC`)
- 2026-10-30 `ja-kana-switch-hiragana` accepts optional prefix arg
- 2026-10-30 `ja-kana-kkc-max-length` ← `kkc-max-length`, etc.
- 2026-10-30 `skkdic-okuri-nasi-katakana` (instead of ja-dic-custom)
- 2026-10-30 `kkc-max-length`: `20` ← `10`
- 2026-10-29 ja-dic-custom
- 2026-10-29 `-` ← `-uskana-`
- 2026-10-28 ja-kana.el from quail-hiragana.el
- 2026-10-28 `S-無変換`: 一時入力
- 2026-10-28 `C-無変換` ← `S-無変換` (英かな変換モード)
- 2026-10-28 `C-変換` ← `C-無変換` (かたかなモード)
- 2026-10-28 `S-変換` ← `C-変換` (かたかな置換)
- 2026-10-28 `—…〜℃〒￥`(`たてなとゆむ`) ← `〜—…`(`もねる`)
- 2026-10-27 minor mode の lighter を `nil` に (← `[か]`/`[カ]`/`[英]`)
- 2026-10-27 半濁点後置記号: `←↓↑→`(`くまのり`), `〜—…ゝ`(`もねるめ`)
- 2026-10-27 モード表示: `かな`/`カナ`/`漢字`/`英数` ← `か`/`カ`/`漢`/`英`
- 2026-10-27 `S-<muhenkan>` ← `:` (colon)
- 2026-10-26 `ゝゞヽヾ`
- 2026-10-26 `<henkan>` でひらがなモードに戻る
- 2026-10-26 `insert` の代わりに `unread-command-events` を設定する
- 2026-10-26 `C-<muhenkan>` ← `Q` (かたかなモードトグル)
- 2026-10-25 `C-<henkan>`: 後置型かたかな変換 (isearch 対応)
- 2026-10-25 `Q`: かたかなモードトグル (isearch 対応)
- 2026-10-25 eikana auto off
- 2026-10-24 `:` (colon): 英かな変換モード
- 2026-10-23 from hiragana.el
