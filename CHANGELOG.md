# Schedule

## Unreleased

- 不正な入力（日付とか）を排除する。
- restart script

## [1.3.0] - 2020-04-27
### Changed
-- SQL の結果を取得し、HTML のテーブルに表示する。

## [1.2.1] - 2020-04-27
### Added
-- SQL を実行できるように。
-- s18.melt に BASIC 認証。


### Change
-- Makefile: seed は init に依存する。
-- Makefile: run は -p <port> オプション付きで起動する。


## [1.1.2] - 2020-04-25
### Added
- link to github

### Security
- gitignore schedule.db


## [1.1.0] - 2020-04-25
### Added
- post '/update'
- post '/delete'
- post '/create'
- get '/new'
- コマンドライン引数をとる。-p 4000 で 4000/tcp でリッスン。


## [1.0.1] - 2020-04-24
### Added
- new ボタン. 機能はまだ。
- delete ボタン。機能はまだ。confirm だけ。
- update ボタン。機能はまだ。

### Changed
- マルチユーザだとクエリーが長くなる。ひとまず、シングルユーザとする。


## [1.0.0] -2020-04-24
- 開発開始。２時間で完成させる。

---
hiroshi.kimura.0331@gmail.com
