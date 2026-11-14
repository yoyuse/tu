;;; tu.el --- Japanese input by US-kana typing       -*- lexical-binding: t; -*-

;; Copyright (C) 2026  YUSE Yosihiro

;; Author: YUSE Yosihiro <yoyuse@gmail.com>
;; Keywords: input method, Japanese, kana typing

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

;; 概要
;;
;; tu.el は,
;; ひらがなIME にインスパイアされた, Emacs 用インプットメソッドです.
;; QWERTY 配列上の USかな入力をサポートしています.
;;
;; 参照
;;
;; - ひらがなIMEの手びき ― ひらがなIME
;; - https://esrille.github.io/ibus-hiragana/index.html
;;
;; - esrille/ibus-hiragana: ひらがなIME for IBus
;; - https://github.com/esrille/ibus-hiragana

;;; Usage:

;; (when (require 'tu nil t) (setq default-input-method "tu"))

;;; Code:

(require 'quail)

;;; ------------------------------------------------------------------
;;; 書き換えルール

;; from roman_rules_uskana.txt
(defvar tu-rules
  '(("3" . "あ") ("e" . "い") ("4" . "う") ("5" . "え") ("6" . "お")
    ("t" . "か") ("g" . "き") ("h" . "く") ("'" . "け") ("b" . "こ")
    ("x" . "さ") ("d" . "し") ("r" . "す") ("p" . "せ") ("c" . "そ")
    ("q" . "た") ("a" . "ち") ("z" . "つ") ("w" . "て") ("s" . "と")
    ("u" . "な") ("i" . "に") ("1" . "ぬ") ("," . "ね") ("k" . "の")
    ("f" . "は") ("v" . "ひ") ("2" . "ふ") ("=" . "へ") ("-" . "ほ")
    ("j" . "ま") ("n" . "み") ("\\" . "む") ("/" . "め") ("m" . "も")
    ("7" . "や") ("8" . "ゆ") ("9" . "よ")
    ("o" . "ら") ("l" . "り") ("." . "る") (";" . "れ") ("`" . "ろ")
    ("0" . "わ") (")" . "を") ("y" . "ん")
    ("#" . "ぁ") ("E" . "ぃ") ("$" . "ぅ") ("%" . "ぇ") ("^" . "ぉ")
    ("Z" . "っ") ("&" . "ゃ") ("*" . "ゅ") ("(" . "ょ")
    ("_" . "ー") ("{" . "「") ("}" . "」")
    ("<" . "、") (">" . "。") ("?" . "・")
    ;; 濁点/半濁点は別枠で処理する
    ;; ("[" . "゛") ("]" . "゜")
    ))

(defvar tu-daku-alist
  '(("か" . "が") ("き" . "ぎ") ("く" . "ぐ") ("け" . "げ") ("こ" . "ご")
    ("さ" . "ざ") ("し" . "じ") ("す" . "ず") ("せ" . "ぜ") ("そ" . "ぞ")
    ("た" . "だ") ("ち" . "ぢ") ("つ" . "づ") ("て" . "で") ("と" . "ど")
    ("は" . "ば") ("ひ" . "び") ("ふ" . "ぶ") ("へ" . "べ") ("ほ" . "ぼ")
    ("う" . "ヴ") ("ゝ" . "ゞ")
    ;; 濁点後置記号
    ("に" . "↑")
    ("ま" . "←") ("の" . "↓") ("り" . "→")
    ("め" . "゛")))

(defvar tu-handaku-alist
  '(("は" . "ぱ") ("ひ" . "ぴ") ("ふ" . "ぷ") ("へ" . "ぺ") ("ほ" . "ぽ")
    ("わ" . "ゎ") ("い" . "ゐ") ("え" . "ゑ") ("か" . "ヵ") ("け" . "ヶ")
    ;; 半濁点後置記号
    ;; ("く" . "←") ("ま" . "↓") ("の" . "↑") ("り" . "→")
    ("ゆ" . "〒") ("む" . "￥")
    ("た" . "—") ("て" . "…") ("な" . "〜")
    ("と" . "℃") ("し" . "〆") ("く" . "ゝ") ("ま" . "々") ("の" . "〃")
    ("こ" . "※") ("め" . "゜")))

;;; ------------------------------------------------------------------
;;; ひらがなモード

;; 濁点/半濁点の処理
(defun tu-daku-or-handaku (alist)
  (let* ((src (and (char-before) (char-to-string (char-before)))) dst)
    (when src
      (cond ((setq dst (cdr-safe (assoc src alist)))
             (delete-char -1)
             (setq unread-command-events
                   (append (string-to-list dst) unread-command-events))
             dst)
            ((setq dst (car-safe (rassoc src alist)))
             (delete-char -1)
             (setq unread-command-events
                   (append (string-to-list dst) unread-command-events))
             dst)
            (t nil)))))

(defun tu-daku ()
  (interactive)
  (tu-daku-or-handaku tu-daku-alist))

(defun tu-handaku ()
  (interactive)
  (tu-daku-or-handaku tu-handaku-alist))

(quail-define-package
 "tu"
 "Japanese"
 "かな"
 nil
 "Japanese hiragana input method by US-Kana transliteration."
 nil nil nil nil nil nil nil nil
 nil
 nil
 nil)

(dolist (elt tu-rules)
  (quail-defrule (car elt) (cdr elt)))

;;; ------------------------------------------------------------------
;;; ひらがなマイナーモード

(defun tu-shift-space (n)
  (interactive "p")
  (self-insert-command n ?\s))

(define-minor-mode tu-mode
  "tu に同期するマイナーモード."
  :init-value nil
  :lighter nil
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "[") 'tu-daku)
            (define-key map (kbd "]") 'tu-handaku)
            (define-key map (kbd "SPC") 'tu-kkc-substring)
            (define-key map (kbd "S-SPC") 'tu-shift-space)
            ;;
            (define-key map (kbd "<henkan>") 'tu-hiragana-or-katakana)
            (define-key map (kbd "<muhenkan>") 'tu-ascii-or-transient)
            (define-key map (kbd "C-<henkan>") 'tu-toggle-katakana)
            (define-key map (kbd "C-<muhenkan>") 'tu-switch-ascii)
            (define-key map (kbd "S-<henkan>") 'tu-katakana-backward)
            (define-key map (kbd "S-<muhenkan>") 'tu-transient)
            map))

(defun tu-mode-off ()
  (tu-mode -1))

(defun tu-mode-sync ()
  "input method の状態に合わせて tu-mode を同期する."
  (if (equal current-input-method "tu")
      (tu-mode 1)
    (tu-mode -1)))

;; 各種イベントに同期関数をフックする
;; * input-method-deactivate-hook の help より:
;; > Normal hook run just after an input method is deactivated.
;; > The variable `current-input-method' still keeps the input method name
;; > just deactivated.
;; IM のオン/オフ時
(add-hook 'input-method-activate-hook   #'tu-mode-sync)
(add-hook 'input-method-deactivate-hook #'tu-mode-off)
;; メジャーモード変更時
(add-hook 'after-change-major-mode-hook #'tu-mode-sync)

;;; ------------------------------------------------------------------
;;; かたかなモード

(defun tu-toggle-katakana ()
  (interactive)
  (if (equal current-input-method "tu")
      (activate-input-method "tu-katakana")
    (activate-input-method "tu")))

(defun tu-isearch-toggle-katakana ()
  (interactive)
  (if (or (equal current-input-method "tu")
          (equal current-input-method "tu-katakana"))
      (tu-toggle-katakana)
    (call-interactively 'isearch-printing-char))
  (isearch-update))

(defvar tu-katakana-rules
  (mapcar (lambda (cons) (cons (car cons) (japanese-katakana (cdr cons))))
          tu-rules))

(defvar tu-katakana-daku-alist
  (mapcar (lambda (cons) (cons (japanese-katakana (car cons))
                               (japanese-katakana (cdr cons))))
          tu-daku-alist))

(defvar tu-katakana-handaku-alist
  (mapcar (lambda (cons) (cons (japanese-katakana (car cons))
                               (japanese-katakana (cdr cons))))
          tu-handaku-alist))

(defun tu-katakana-daku ()
  (interactive)
  (tu-daku-or-handaku tu-katakana-daku-alist))

(defun tu-katakana-handaku ()
  (interactive)
  (tu-daku-or-handaku tu-katakana-handaku-alist))

(quail-define-package
 "tu-katakana"
 "Japanese"
 "カナ"
 nil
 "Temporary katakana input mode used within input method `tu'."
 nil nil nil nil nil nil nil nil
 nil
 nil
 nil)

(dolist (elt tu-katakana-rules)
  (quail-defrule (car elt) (cdr elt)))

;;; ------------------------------------------------------------------
;;; かたかなマイナーモード

(define-minor-mode tu-katakana-mode
  "tu-katakana に同期するマイナーモード."
  :init-value nil
  :lighter nil
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "[") 'tu-katakana-daku)
            (define-key map (kbd "]") 'tu-katakana-handaku)
            ;;
            (define-key map (kbd "<henkan>") 'tu-hiragana-or-katakana)
            (define-key map (kbd "<muhenkan>") 'tu-ascii-or-transient)
            (define-key map (kbd "C-<henkan>") 'tu-toggle-katakana)
            (define-key map (kbd "C-<muhenkan>") 'tu-switch-ascii)
            (define-key map (kbd "S-<muhenkan>") 'tu-transient)
            (define-key map (kbd "S-<muhenkan>") 'tu-transient)
            map))

(defun tu-katakana-mode-off ()
  (tu-katakana-mode -1))

(defun tu-katakana-mode-sync ()
  "input method の状態に合わせて tu-katakana-mode を同期する."
  (if (equal current-input-method "tu-katakana")
      (tu-katakana-mode 1)
    (tu-katakana-mode -1)))

;; 各種イベントに同期関数をフックする
;; * input-method-deactivate-hook の help より:
;; > Normal hook run just after an input method is deactivated.
;; > The variable `current-input-method' still keeps the input method name
;; > just deactivated.
;; IM のオン/オフ時
(add-hook 'input-method-activate-hook   #'tu-katakana-mode-sync)
(add-hook 'input-method-deactivate-hook #'tu-katakana-mode-off)
;; メジャーモード変更時
(add-hook 'after-change-major-mode-hook #'tu-katakana-mode-sync)

;;; ------------------------------------------------------------------
;;; ASCII モード

(defun tu-switch-ascii ()
  (interactive)
  (activate-input-method "tu-ascii"))

(defun tu-switch-hiragana (&optional arg)
  (interactive "P")
  (if arg
      (toggle-input-method arg)
    (activate-input-method "tu")))

(defun tu-toggle-ascii ()
  (interactive)
  (if (equal current-input-method "tu")
      (activate-input-method "tu-ascii")
    (activate-input-method "tu")))

(defun tu-isearch-toggle-ascii ()
  (interactive)
  (if (or (equal current-input-method "tu")
          (equal current-input-method "tu-ascii"))
      (tu-toggle-ascii)
    (call-interactively 'isearch-printing-char))
  (isearch-update))

(quail-define-package
 "tu-ascii"
 "Japanese"
 "英数"
 nil
 "Temporary ascii input mode used within input method `tu'."
 nil t t)

;;; ------------------------------------------------------------------
;;; ASCII マイナーモード

(define-minor-mode tu-ascii-mode
  "tu-ascii に同期するマイナーモード."
  :init-value nil
  :lighter nil
  :keymap (let ((map (make-sparse-keymap)))
            ;; (define-key map (kbd "RET") 'tu-switch-hiragana)
            (define-key map (kbd "<henkan>") 'tu-hiragana-or-katakana)
            (define-key map (kbd "<muhenkan>") 'tu-ascii-or-transient)
            map))

(defun tu-ascii-mode-off ()
  (tu-ascii-mode -1))

(defun tu-ascii-mode-sync ()
  "input method の状態に合わせて tu-ascii-mode を同期する."
  (if (equal current-input-method "tu-ascii")
      (tu-ascii-mode 1)
    (tu-ascii-mode -1)))

;; 各種イベントに同期関数をフックする
;; * input-method-deactivate-hook の help より:
;; > Normal hook run just after an input method is deactivated.
;; > The variable `current-input-method' still keeps the input method name
;; > just deactivated.
;; IM のオン/オフ時
(add-hook 'input-method-activate-hook   #'tu-ascii-mode-sync)
(add-hook 'input-method-deactivate-hook #'tu-ascii-mode-off)
;; メジャーモード変更時
(add-hook 'after-change-major-mode-hook #'tu-ascii-mode-sync)

;;; ------------------------------------------------------------------
;;; 漢字変換

;; kkc-substring

(require 'kkc)

;; Provided that `kkc-current-key' is [A B C D E F G H I], the current
;; conversion target is [A B C D E F], and the sequence of which
;; conversion is found is [A B C D]:
;;
;;                                A B C D E F G H I
;; kkc-overlay-head (black):     |<--------->|
;; kkc-overlay-tail (underline):         |<------->|
;; kkc-length-head:              |<--------->|
;; kkc-length-converted:         |<----->|

(defvar tu-kkc-max-length 20 "読みの最大長さ.") ; XXX
(defvar tu-kkc-left nil "変換対象にならなかった左側の部分文字列.")
(defvar tu-kkc-keymap
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map kkc-keymap)
    map)
  "tu 用の `kkc-keymap'.")

(defun tu-kkc-substring-length ()
  "カーソルの左側の読みの長さを返す."
  (interactive)
  (let* ((re "[ぁ-んヴヵヶー・ゝゞヽヾ]")
         (max-length (save-excursion (let ((n 0))
                                       (while (looking-back re)
                                         (setq n (1+ n))
                                         (backward-char))
                                       n)))
         (length (min tu-kkc-max-length max-length)))
    length))

(defun tu-kkc-substring (&optional n)
  "カーソルの左側の変換可能最長部分文字列を変換する."
  (interactive "P")
  (let* ((kkc-input-method-title "漢字") ; was "漢"
         (kkc-keymap tu-kkc-keymap)
         ;; disable "Search OKURI-NASI entries with prefixes."
         ;; in skkdic-lookup-key
         (skkdic-prefix '(0))
         length)
    (if (setq length n)
        (tu-kkc-region (- (point) length) (point))
      (setq length (tu-kkc-substring-length))
      (if (< 0 length)
          (tu-kkc-region (- (point) length) (point) 'sub)
        ;; XXX: self-insert-command
        (call-interactively 'self-insert-command)))))

(defun tu-vcons (elt vec)
  "ベクタ VEC の先頭に要素 ELT を挿入した新しいベクタを返す."
  (vconcat (cons elt (append vec nil))))

(defun tu-vcdr (vec)
  "ベクタ VEC の先頭の要素を取り除いた新しいベクタを返す."
  (vconcat (cdr-safe (append vec nil))))

(defun tu-kkc-shorter ()
  "左側を 1 文字縮める."
  (interactive)
  (when (< 1 kkc-length-head)
    (kkc-hiragana)
    (setq kkc-length-head (1- kkc-length-head))
    (let* (;; (len kkc-length-head)
           (rev (reverse (string-to-list tu-kkc-left)))
           (new-left (reverse (cons (aref kkc-current-key 0) rev))))
      (setq kkc-length-converted 0)
      (setq kkc-current-key (tu-vcdr kkc-current-key))
      (setq tu-kkc-left (vconcat new-left))
      ;; (kkc-lookup-key kkc-length-head nil (< kkc-length-head len))
      ;; (message "kkc-current-key <%S>" kkc-current-key)
      (kkc-lookup-key kkc-length-head 'postfix)
      ;; (kkc-lookup-key kkc-length-head)
      ;; /
      (let ((pos (1+ (overlay-start kkc-overlay-head)))
            (tail (overlay-end kkc-overlay-tail)))
        (move-overlay kkc-overlay-head pos tail)
        (move-overlay kkc-overlay-tail tail tail)))
    (kkc-update-conversion 'all)))

(defun tu-kkc-longer ()
  "左側を 1 文字伸ばす."
  (interactive)
  (when (< 0 (length tu-kkc-left))
    (setq kkc-length-head (1+ kkc-length-head))
    (let* (;; (len kkc-length-head)
           (rev (reverse (string-to-list tu-kkc-left)))
           (c (car-safe rev))
           (new-left (reverse (cdr-safe rev))))
      (setq kkc-length-converted 0)
      (setq kkc-current-key (tu-vcons c kkc-current-key))
      (setq tu-kkc-left (vconcat new-left))
      (kkc-hiragana)
      ;; (kkc-lookup-key kkc-length-head nil (< kkc-length-head len))
      ;; (message "kkc-current-key <%S>" kkc-current-key)
      (kkc-lookup-key kkc-length-head 'postfix)
      ;; (kkc-lookup-key kkc-length-head)
      ;; /
      (let ((pos (1- (overlay-start kkc-overlay-head)))
            (tail (overlay-end kkc-overlay-tail)))
        (move-overlay kkc-overlay-head pos tail)
        (move-overlay kkc-overlay-tail tail tail)))
    (kkc-update-conversion 'all)))

(defun tu-kkc-katakana-longer ()
  "かたかなに変換する. すでにかたかななら, かたかなのまま左側を 1 文字伸ばす."
  (interactive)
  (if (/= (car kkc-current-conversions) -1) ; XXX
      (kkc-katakana)
    (tu-kkc-longer)
    (kkc-katakana)))

(defun tu-kkc-region (from to &optional sub)
  "FROM と TO の間のリージョン内を変換する.
SUB が nil なら, リージョン全体を変換する.
SUB が non-nil なら, リージョン内右側の変換可能最長部分文字列を変換する."
  (interactive "r\nP")
  (setq kkc-original-kana (buffer-substring-no-properties from to))
  (setq tu-kkc-left "")
  (goto-char from)
  ;;
  ;; Setup overlays.
  (if (overlayp kkc-overlay-head)
      (move-overlay kkc-overlay-head from to)
    (setq kkc-overlay-head (make-overlay from to nil nil t))
    (overlay-put kkc-overlay-head 'face 'highlight))
  (if (overlayp kkc-overlay-tail)
      (move-overlay kkc-overlay-tail to to)
    (setq kkc-overlay-tail (make-overlay to to nil nil t))
    (overlay-put kkc-overlay-tail 'face 'underline))
  ;;
  (setq kkc-current-key (string-to-vector kkc-original-kana))
  (setq kkc-length-head (length kkc-current-key))
  (setq kkc-length-converted 0)
  ;;
  (unwind-protect
      ;; At first convert the region to the first candidate.
      (let ((current-input-method-title kkc-input-method-title)
            (input-method-function nil)
            (modified-p (buffer-modified-p))
            (first t)
            ;; //
            (original-kana kkc-original-kana))
        (while (not (kkc-lookup-key kkc-length-head nil first))
          ;;
          (when sub
            (setq tu-kkc-left (concat tu-kkc-left
                                      (substring original-kana 0 1))
                  original-kana (substring original-kana 1)
                  kkc-current-key (string-to-vector original-kana)))
          ;; /
          (setq kkc-length-head (1- kkc-length-head)
                first nil))
        ;;
        (if sub
            (move-overlay kkc-overlay-head (+ from (length tu-kkc-left)) to)
          (setq kkc-length-head (length kkc-current-key)))
        ;; /
        (goto-char to)
        (kkc-update-conversion 'all)
        (setq kkc-next-count 1 kkc-prev-count 0)
        (if (and (>= kkc-next-count kkc-show-conversion-list-count)
                 (>= (length kkc-current-conversions) 3))
            (kkc-show-conversion-list-or-next-group))
        ;;
        ;; Then, ask users to select a desirable conversion.
        (force-mode-line-update)
        (setq kkc-converting t)
        ;; Hide "... loaded" message.
        (message nil)
        (while kkc-converting
          (set-buffer-modified-p modified-p)
          (let* ((overriding-terminal-local-map kkc-keymap)
                 (help-char nil)
                 (keyseq (read-key-sequence nil))
                 (cmd (lookup-key kkc-keymap keyseq)))
            (if (commandp cmd)
                (condition-case err
                    (progn
                      (cond ((eq cmd 'kkc-next)
                             (setq kkc-next-count (1+ kkc-next-count)
                                   kkc-prev-count 0))
                            ((eq cmd 'kkc-prev)
                             (setq kkc-prev-count (1+ kkc-prev-count)
                                   kkc-next-count 0))
                            ;;
                            ((eq cmd 'kkc-cancel)
                             (setq kkc-next-count 0 kkc-prev-count 0
                                   cmd 'tu-kkc-cancel))
                            ;; /
                            (t
                             (setq kkc-next-count 0 kkc-prev-count 0)))
                      (call-interactively cmd))
                  (kkc-error (message "%s" (cdr err)) (beep)))
              ;; KEYSEQ is not defined in KKC keymap.
              ;; Let's put the event back.
              (setq unread-input-method-events
                    (append (string-to-list (this-single-command-raw-keys))
                            unread-input-method-events))
              (kkc-terminate))))
        ;;
        (force-mode-line-update)
        (goto-char (overlay-end kkc-overlay-tail))
        (- (overlay-start kkc-overlay-head) from))
    (delete-overlay kkc-overlay-head)
    (delete-overlay kkc-overlay-tail)))

(defun tu-kkc-cancel ()
  "Exit from KKC mode by canceling any conversions."
  (interactive)
  (goto-char (overlay-start kkc-overlay-head))
  (delete-region (overlay-start kkc-overlay-head)
                 (overlay-end kkc-overlay-tail))
  ;;
  ;; (insert kkc-original-kana)
  (insert (substring kkc-original-kana (length tu-kkc-left)))
  ;; /
  (setq kkc-converting nil))

(defun tu-kkc-back-to-start ()
  "変換を確定し, 変換開始点までカーソルを戻す."
  (interactive)
  (let ((start (overlay-start kkc-overlay-head)))
    (move-overlay kkc-overlay-tail start start)
    (kkc-terminate)))

;; keybind

(let ((map tu-kkc-keymap))
  (define-key map (kbd "C-b") 'tu-kkc-back-to-start)
  (define-key map (kbd "C-o") 'kkc-longer)
  (define-key map (kbd "C-S-o") 'kkc-shorter)
  ;; (define-key map (kbd "M-i") 'kkc-shorter)
  ;; (define-key map (kbd "M-o") 'kkc-longer)
  ;; (define-key map (kbd "M-I") 'kkc-shorter-conversion)
  ;; (define-key map (kbd "M-O") 'kkc-longer-phrase)
  (define-key map (kbd "C-k") 'tu-kkc-katakana-longer)
  (define-key map (kbd "C-i") 'tu-kkc-shorter)
  (define-key map (kbd "C-S-i") 'tu-kkc-longer)
  (define-key map (kbd "<backtab>") 'tu-kkc-longer)
  (define-key map (kbd "C-g") 'kkc-cancel)
  (define-key map (kbd "l") nil)
  (define-key map (kbd "L") nil)
  (define-key map (kbd "H") nil)
  (define-key map (kbd "I") nil)
  (define-key map (kbd "K") nil)
  (define-key map (kbd "O") nil)
  (define-key map (kbd "C-l") 'kkc-show-conversion-list-or-next-group)
  (define-key map (kbd "C-S-l") 'kkc-show-conversion-list-or-prev-group))

(dolist (n (string-split kkc-show-conversion-list-index-chars "" t))
  (define-key tu-kkc-keymap (kbd n) nil))

;; 0 .. 9 の代わりに C-0 .. C-9 で候補を選択する
(defvar tu-kkc-conversion-list-index-keys
  (apply #'vconcat
         (mapcar (function (lambda (c) (kbd (format "C-%c" c))))
                 (string-to-vector kkc-show-conversion-list-index-chars))))

(dolist (n (string-split kkc-show-conversion-list-index-chars "" t))
  (define-key tu-kkc-keymap
              (make-vector 1 (aref tu-kkc-conversion-list-index-keys
                                   (string-to-number n)))
              'tu-kkc-select-from-list))

(defun tu-kkc-select-from-list ()
  "Select one candidate from the list currently shown in echo area."
  (interactive)
  (let (idx
        ;; //
        (kkc-show-conversion-list-index-chars
         tu-kkc-conversion-list-index-keys))
    (if kkc-current-conversions-width
        (let ((len (length kkc-show-conversion-list-index-chars))
              (maxlen (- (aref (aref kkc-current-conversions-width 0) 1)
                         (aref (aref kkc-current-conversions-width 0) 0)))
              (i 0))
          (if (> len maxlen)
              (setq len maxlen))
          (while (< i len)
            (if (= (aref kkc-show-conversion-list-index-chars i)
                   last-input-event)
                (setq idx i i len)
              (setq i (1+ i))))))
    (if idx
        (progn
          (setcar kkc-current-conversions
                  (+ (aref (aref kkc-current-conversions-width 0) 0) idx))
          (kkc-show-conversion-list-update)
          (kkc-update-conversion))
      (setq unread-input-method-events
            (cons last-input-event unread-input-method-events))
      (kkc-terminate))))

;;; ------------------------------------------------------------------
;;; isearch (ひらがな/かたかな のみ)

(defun tu-isearch-daku-or-handaku (alist)
  (catch 'tag
    (let* ((src isearch-string)
           (len (length src))
           (src (substring src (- len 1)))
           dst)
      (or (setq dst (cdr-safe (assoc src alist)))
          (setq dst (car-safe (rassoc src alist)))
          (throw 'tag nil))
      (isearch-pop-state)
      (isearch-process-search-string dst dst))))

(defun tu-isearch-daku ()
  (interactive)
  (cond ((equal current-input-method "tu")
         (tu-isearch-daku-or-handaku
          tu-daku-alist))
        ((equal current-input-method "tu-katakana")
         (tu-isearch-daku-or-handaku
          tu-katakana-daku-alist))
        (t (call-interactively 'isearch-printing-char))))

(defun tu-isearch-handaku ()
  (interactive)
  (cond ((equal current-input-method "tu")
         (tu-isearch-daku-or-handaku
          tu-handaku-alist))
        ((equal current-input-method "tu-katakana")
         (tu-isearch-daku-or-handaku
          tu-katakana-handaku-alist))
        (t (call-interactively 'isearch-printing-char))))

;; keybind

(let* ((map isearch-mode-map))
  (define-key map (kbd "[") 'tu-isearch-daku)
  (define-key map (kbd "]") 'tu-isearch-handaku)
  ;;
  (define-key map (kbd "<henkan>") 'tu-isearch-hiragana-or-katakana)
  (define-key map (kbd "<muhenkan>") 'tu-isearch-off-or-ascii)
  (define-key map (kbd "C-<henkan>") 'tu-isearch-toggle-katakana)
  (define-key map (kbd "C-<muhenkan>") 'tu-isearch-toggle-ascii)
  (define-key map (kbd "S-<henkan>") 'tu-isearch-katakana-backward)
  (define-key map (kbd "S-<muhenkan>") 'tu-isearch-transient))

;;; ------------------------------------------------------------------
;;; 一時入力

;; transient

(defvar tu-transient-map
  (let* ((map (make-sparse-keymap)))
    (set-keymap-parent map global-map)
    (define-key map (kbd "<henkan>") 'tu-hiragana-or-katakana)
    (define-key map (kbd "<muhenkan>") 'tu-ascii-or-transient)
    map)
  "一時入力用キーマップ.")

(defun tu-transient ()
  "一時入力を行う."
  (interactive)
  (set-transient-map
   tu-transient-map
   nil nil (format "%s-" (key-description (list last-command-event)))))

;; isearch transient

(defvar tu-isearch-transient-map
  (let* ((map (make-sparse-keymap)))
    (define-key map (kbd "[") 'isearch-printing-char)
    (define-key map (kbd "]") 'isearch-printing-char)
    map)
  "isearch 中の一時入力用キーマップ.")

(defun tu-isearch-transient ()
  "isearch 中の一時入力を行う."
  (interactive)
  (let* ((default-transient-input-method "tu-ascii"))
    (activate-transient-input-method)
    (set-transient-map
     tu-isearch-transient-map
     nil nil (format "%s-" (key-description (list last-command-event))))))

;;; ------------------------------------------------------------------
;;; 後置型かたかな置換

;; katakana backward

(defun tu-katakana-backward (&optional n)
  "後置型かたかな置換を行う.
N が nil ならば, ひらがなを 1 文字だけ置換する.
N が non-nil ならば, N 文字までかな文字列を置換する."
  (interactive "P")
  (let* ((src (buffer-substring-no-properties
               (line-beginning-position) (point)))
         (dst (tu-katakana-backward-sub src n))
         (len (length dst)))
    (when (< 0 len)
      (japanese-replace-region (- (point) len) (point) dst))))

(defun tu-katakana-backward-sub (src n)
  (save-match-data
    (let* ((re "[ぁ-んゝゞ][ァ-ンヴヵヶー・ヽヾ]*$")
           (match (string-match re src))
           (len (length (match-string 0 src)))
           (dst ""))
      (when match
        (when (null n) (setq n len))
        (when (<= len n)
          (setq dst (japanese-katakana
                     (substring src (- (length src) n) (length src))))))
      dst)))

;; isearch katakana backward

(defun tu-isearch-katakana-backward (&optional n)
  (interactive "P")
  (let* ((src isearch-string)
         (dst (tu-katakana-backward-sub src n))
         (len (length dst))
         (i 0))
    (when (< 0 len)
      ;; (while (< i len) (isearch-pop-state) (setq i (1+ i)))
      ;; ;; (isearch-pop-state) で取り出されるのは一文字ずつとは限らない
      (while (and (< 1 (length isearch-cmds))
                  (< i len))
        (let ((l (length isearch-string)))
          (isearch-pop-state)
          (setq i (+ i (- l (length isearch-string))))))
      ;; /
      (setq i 0)
      (while (< i len)
        (isearch-process-search-string (substring dst i (1+ i))
                                       (substring dst i (1+ i)))
        (setq i (1+ i))))))

;;; ------------------------------------------------------------------
;;; かたかな語補遺辞書 (skkdic-okuri-nasi-katakana)

;;
;; from ja-dic-cnv.el.gz
;;

(require 'ja-dic-cnv)

(defmacro skkdic-set-okuri-nasi-katakana (&rest entries)
  `(defconst skkdic-okuri-nasi-katakana
     ',(let ((l entries)
             (map '(skdic-okuri-nasi-katakana)) ; skdic- は skkdic- の typo ???
             (progress (make-progress-reporter
                        (byte-compile-info "Extracting OKURI-NASI KATAKANA entries")
                        0 (length entries)))
             (count 0)
             entry)
         (while l
           (progress-reporter-update progress (setq count (1+ count)))
           (setq entry (skkdic-extract-conversion-data (car l)))
           (set-nested-alist (car entry) (cdr entry) map)
           (setq l (cdr l)))
         (progress-reporter-done progress)
         map)))

;;
;; from ja-dic-utl.el.gz
;;

(defvar skkdic-okuri-nasi-katakana nil
  "Nested alist for OKURI-NASI KATAKANA entries of SKK dictionary.")

(defun skkdic-lookup-key-katakana (seq len &optional postfix prefer-noun)
  "Return a list of conversion string for sequence SEQ of length LEN.

SEQ is a vector of Kana characters to be converted by SKK dictionary.
If LEN is shorter than the length of KEYSEQ, the first LEN keys in SEQ
are took into account.

Optional 3rd arg POSTFIX non-nil means SETSUBIJI (postfix) are also
considered to find conversion strings.

Optional 4th arg PREFER-NOUN non-nil means that the conversions
without okurigana are placed at the head of the returned list."
;;   (or skkdic-okuri-nasi
;;       (condition-case err
;;           (load-library "ja-dic/ja-dic")
;;         (error (ding)
;;                (with-output-to-temp-buffer "*Help*"
;;                  (princ (substitute-command-keys "\
;; The library `ja-dic' can't be loaded.
;; 
;; This might indicate a problem with your Emacs installation, as
;; LEIM (Libraries of Emacs Input Method) should normally always be
;; installed together with Emacs.")))
;;                (signal (car err) (cdr err)))))

  ;;
  (or skkdic-okuri-nasi-katakana
      (condition-case err
          (load-library "ja-dic-katakana")
        (error
         (setq skkdic-okuri-nasi-katakana '(skkdic-okuri-nasi-katakana))
         (message "Library `ja-dic-katakana' not found; skipping."))))
  ;; /

  (let ((vec (make-vector len 0))
        (i 0)
        entry)
    ;; At first, generate vector VEC from SEQ for looking up SKK
    ;; alists.  Nth element in VEC corresponds to Nth element in SEQ.
    ;; The values are decided as follows.
    ;;   If SEQ[N] is `ー', VEC[N] is 0,
    ;;   else if SEQ[N] is a Hiragana character, VEC[N] is:
    ;;     ((The 2nd position code of SEQ[N]) - 32),
    ;;   else VEC[N] is 128.
    (while (< i len)
      (let ((ch (aref seq i))
            code)
        (cond ((= ch ?ー)
               (aset vec i 0))
              ((and (>= ch (car skkdic-jisx0208-hiragana-block))
                    (<= ch (cdr skkdic-jisx0208-hiragana-block)))
               (setq code (encode-char ch 'japanese-jisx0208))
               (if code
                   (aset vec i (- (logand code #xFF) 32))
                 (aset vec i 128)))
              (t
               (aset vec i 128))))
      (setq i (1+ i)))

    ;; Search OKURI-NASI KATAKANA entries.
    ;; (setq entry (lookup-nested-alist vec skkdic-okuri-nasi len 0 t))
    (setq entry (lookup-nested-alist vec skkdic-okuri-nasi-katakana len 0 t))
    (if (consp (car entry))
        (setq entry (copy-sequence (car entry)))
      (setq entry nil))

    ;; (if postfix
    ;;     ;; Search OKURI-NASI entries with postfixes.
    ;;     (let ((break (max (- len (car skkdic-postfix)) 1))
    ;;           entry-head entry-postfix entry2)
    ;;       (while (< break len)
    ;;         (if (and (setq entry-head
    ;;                        (lookup-nested-alist vec skkdic-okuri-nasi
    ;;                                             break 0 t))
    ;;                  (consp (car entry-head))
    ;;                  (setq entry-postfix
    ;;                        (lookup-nested-alist vec skkdic-postfix
    ;;                                             len break t))
    ;;                  (consp (car entry-postfix))
    ;;                  (setq entry2 (skkdic-merge-head-and-tail
    ;;                                (car entry-head) (car entry-postfix) t)))
    ;;             (if entry
    ;;                 (nconc entry entry2)
    ;;               (setq entry entry2)))
    ;;         (setq break (1+ break)))))

    ;; Search OKURI-NASI entries with prefixes.
    ;; (let ((break (min (car skkdic-prefix) (- len 2)))
    ;;       entry-prefix entry-tail entry2)
    ;;   (while (> break 0)
    ;;     (if (and (setq entry-prefix
    ;;                    (lookup-nested-alist vec skkdic-prefix break 0 t))
    ;;              (consp (car entry-prefix))
    ;;              (setq entry-tail
    ;;                    (lookup-nested-alist vec skkdic-okuri-nasi len break t))
    ;;              (consp (car entry-tail))
    ;;              (setq entry2 (skkdic-merge-head-and-tail
    ;;                            (car entry-prefix) (car entry-tail) nil)))
    ;;         (progn
    ;;           (if entry
    ;;               (nconc entry entry2)
    ;;             (setq entry entry2))))
    ;;     (setq break (1- break))))

    ;; Search OKURI-ARI entries.
    ;; (let ((okurigana (assq (aref seq (1- len)) skkdic-okurigana-table))
    ;;       orig-element entry2)
    ;;   (if okurigana
    ;;       (progn
    ;;         (setq orig-element (aref vec (1- len)))
    ;;         (aset vec (1- len) (- (cdr okurigana)))
    ;;         (if (and (setq entry2 (lookup-nested-alist vec skkdic-okuri-ari
    ;;                                                    len 0 t))
    ;;                  (consp (car entry2)))
    ;;             (progn
    ;;               (setq entry2 (copy-sequence (car entry2)))
    ;;               (let ((l entry2)
    ;;                     (okuri (char-to-string (aref seq (1- len)))))
    ;;                 (while l
    ;;                   (setcar l (concat (car l) okuri))
    ;;                   (setq l (cdr l)))
    ;;                 (if entry
    ;;                     (if prefer-noun
    ;;                         (nconc entry entry2)
    ;;                       (setq entry2 (nreverse entry2))
    ;;                       (nconc entry2 entry)
    ;;                       (setq entry entry2))
    ;;                   (setq entry (nreverse entry2))))))
    ;;         (aset vec (1- len) orig-element))))

    entry))

(defun skkdic-lookup-key-katakana-ad (orig-fun &rest args)
  "Advice to append katakana words."
  (let* ((cands (apply orig-fun args))
         (katakana (apply 'skkdic-lookup-key-katakana args)))
    (append cands katakana)))

;; avoid error...
(or skkdic-okuri-nasi
    (condition-case err
        (load-library "ja-dic/ja-dic")
      (error (ding)
             (with-output-to-temp-buffer "*Help*"
               (princ (substitute-command-keys "\
The library `ja-dic' can't be loaded.

This might indicate a problem with your Emacs installation, as
LEIM (Libraries of Emacs Input Method) should normally always be
installed together with Emacs.")))
             (signal (car err) (cdr err)))))
;; /avoid error...

(advice-add 'skkdic-lookup-key :around #'skkdic-lookup-key-katakana-ad)
;; (advice-remove 'skkdic-lookup-key #'skkdic-lookup-key-katakana-ad)

;;; ------------------------------------------------------------------
;;; 変換キーダブルプレスでかたかなモード

(defvar tu-double-press-threshold 0.4 "ダブルプレスとみなす時間 (秒).")
;; (defvar tu-double-press-timer nil "遅延実行用のタイマー.")
(defvar tu-double-press-last-henkan nil "最後に変換キーが押された時間.")
(defvar tu-double-press-last-muhenkan nil "最後に無変換キーが押された時間.")
(defvar-local tu-double-press-save nil)

;; double press

(defun tu-hiragana-or-katakana (&optional isearch)
  "シングルプレスでひらがなモード, ダブルプレスでかたかなモードにする."
  (interactive "i")
  (let* ((now (float-time)))
    (if (and tu-double-press-last-henkan
             (< (- now tu-double-press-last-henkan)
                tu-double-press-threshold))
        ;; double press
        (progn (setq tu-double-press-last-henkan nil)
               (activate-input-method "tu-katakana")
               (when isearch (isearch-update)))
      ;; single press
      (setq tu-double-press-last-henkan now)
      (activate-input-method "tu")
      (when isearch (isearch-update)))))

(defun tu-ascii-or-transient (&optional isearch)
  "シングルプレスで ASCII モードにし, ダブルプレスで一時入力を行う."
  (interactive "i")
  (let* ((now (float-time)))
    (if (and tu-double-press-last-muhenkan
             (< (- now tu-double-press-last-muhenkan)
                tu-double-press-threshold))
        ;; double press
        (progn (setq tu-double-press-last-muhenkan nil)
               (activate-input-method tu-double-press-save)
               (if isearch
                   (tu-isearch-transient)
                 (tu-transient)))
      ;; single press
      (setq tu-double-press-last-muhenkan now)
      (setq tu-double-press-save current-input-method)
      (activate-input-method "tu-ascii")
      (when isearch (isearch-update)))))

;; isearch double press

(defun tu-isearch-hiragana-or-katakana ()
  (interactive)
  (tu-hiragana-or-katakana 'isearch))

(defun tu-isearch-off-or-ascii ()
  (interactive)
  (tu-ascii-or-transient 'isearch))

;;; ------------------------------------------------------------------
;;; 親指漢直

;; tu-kanchoku

(defvar tu-use-shift-rules t)
(defvar tu-use-kanchoku-shift t)

(defvar tu-shift-rules
  '(("A" . "1") ("S" . "2") ("D" . "3") ("F" . "4") ("G" . "5")
    ("H" . "6") ("J" . "7") ("K" . "8") ("L" . "9") (":" . "0")
    ;; tu-kanchoku-shift 用
    ("Q" . "/") ("W" . "%") ;; ("R" . "￥") ("T" . "\"") ("Y" . "_")
    ("U" . "?") ("I" . "(") ("O" . ")") ("P" . "!")
    ("X" . ".") ("C" . ",")))

(defun tu-self-insert-command (n)
  (interactive "p")
  (if (not tu-use-shift-rules)
      (call-interactively 'self-insert-command)
    (let* ((ch (char-to-string last-command-event))
           (ch (cdr-safe (assoc ch tu-shift-rules)))
           (last-command-event (if ch (string-to-char ch) last-command-event)))
      (call-interactively 'self-insert-command))))

(defun tu-isearch-printing-char (n)
  (interactive "p")
  (if (or (not tu-use-shift-rules)
          (not (member current-input-method '("tu" "tu-katakana"))))
      (call-interactively 'isearch-printing-char)
    (let* ((ch (char-to-string last-command-event))
           (ch (cdr-safe (assoc ch tu-shift-rules)))
           (last-command-event (if ch (string-to-char ch) last-command-event)))
      (call-interactively 'isearch-printing-char))))

(dolist (elt tu-shift-rules)
  (define-key tu-mode-map (kbd (car elt)) 'tu-self-insert-command)
  (define-key tu-katakana-mode-map (kbd (car elt)) 'tu-self-insert-command)
  (define-key isearch-mode-map (kbd (car elt)) 'tu-isearch-printing-char))

(when (require 'ttt nil t)
  (defun tu-kanchoku-shift ()
    (interactive)
    (if (or (not tu-use-shift-rules) (not tu-use-kanchoku-shift))
        (call-interactively 'self-insert-command)
      (let* ((ch (ttt--trans (read-char)))
             (ch (or (car-safe (rassoc ch tu-shift-rules)) ch))
             (ev (string-to-list ch)))
        (when (not (string-empty-p ch))
          (setq unread-command-events (append ev unread-command-events))))))
  ;;
  ;; (defun tu-isearch-kanchoku-shift (n)
  ;;   (interactive "p")
  ;;   (if (or (not tu-use-shift-rules) (not tu-use-kanchoku-shift)
  ;;           (not (member current-input-method '("tu" "tu-katakana"))))
  ;;       (call-interactively 'isearch-printing-char)
  ;;     (tu-kanchoku-shift)))
  (defun tu-isearch-kanchoku-shift-ad (orig-fun &rest args)
    (if (and (eq last-command-event ?|)
             tu-use-shift-rules tu-use-kanchoku-shift
             (member current-input-method '("tu" "tu-katakana")))
        (tu-kanchoku-shift)
      (apply orig-fun args)))
  ;;
  (defun tu-isearch-ttt-reset (orig-fun &rest args)
    (ttt--reset))
  ;;
  (define-key tu-mode-map (kbd "|") 'tu-kanchoku-shift)
  ;; (define-key isearch-mode-map (kbd "|") 'tu-isearch-kanchoku-shift)
  (add-hook 'post-self-insert-hook 'ttt--reset)
  (advice-add 'isearch-printing-char :after 'tu-isearch-ttt-reset)
  (advice-add 'isearch-printing-char :around 'tu-isearch-kanchoku-shift-ad))

;;; ------------------------------------------------------------------
;;; provide

(provide 'tu)
;;; tu.el ends here
