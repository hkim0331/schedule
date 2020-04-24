2020-04-24
# <span style='color:red;'>UNDER CONSTRUCTION</span>

## Schedule

* Racket/RDB で Web アプリを作ってみせる。
* 「開発」はどのように進むか？
* 「開発」に必要になるツールの紹介
* デモファーストで。

---
### 計画

どんなのを作るか？

* ユーザは3人。
* 1日に何個か、スケジュール（イベント）を入れられる。
* スケジュールは一個ずつアップデートできる。
* スケジュールは一個ずつ削除できる。
* 今日のスケジュールをハイライトできる。

---
### 使うもの

* ターミナル
* Racket, dmac/spin
* Sqlite3
* ブラウザ

---
### データベース

表計算ソフトをとりあえず、イメージする。

|    | ユーザ1 | ユーザ2 | ユーザ3 |
|:--:|:-------|:-------|:-------|
|日付|         | L99    |        |
|日付| ゼミ発表  |        |        |
|日付| 面接     |        | 魚やん |

* あらかじめ、どんなデータを入れるかを考えるのが普通。
* どんな形の表（テーブル）になるかを計画する（データベースの定義）
* どんなデータをどうやって取り出すか（クエリー; query）

___
### SQL

* データベースの定義、クエリーの両方で使う。
* データベースには複数の種類があり、それぞれに特徴がある。
* SQL はそれらのデータベースシステムに共通の言語。

---
### データベースを定義する

C や Java の変数宣言と似ている。このプログラムが SQL。
コメントは -- から行末まで。

```sql
CREATE TABLE schedule (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INT,
  date DATE,
  brief TEXT,
  detail TEXT,
  update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

予約語は大文字、そうでないのは小文字で書くのが慣習だが、
全部大文字、あるいは小文字でも構わない。

こいつを create.sql の名前でセーブするのが hkimura 流。

---
### データベースを定義する(2)

ターミナルを開いて、create.sql をセーブしたフォルダに移動後、

```sh
$ sqlite3 schedule.db < create.sql
```

成功すると、フォルダに schedule.db のファイルができる。
これが sqlite3 のデータベースの実体。

---
### ダミーデータを入れとく

テーブルがカラだと面白くないので、インチキデータを入れておく。
このプログラムも SQL。

```sql
INSERT INTO schedule (user_id, date, brief, detail)
  values
  (1, "2020-04-24", "デート",  ""),
  (2, "2020-04-24", "L99", ""),
  (3, "2020-04-24", "昼寝", ""),
  (1, "2020-04-24", "ゼミ発表", ""),
  (2, "2020-04-24", "L99", ""),
  (3, "2020-04-24", "昼寝", ""),
  (1, "2020-04-24", "面接", ""),
  (2, "2020-04-24", "", ""),
  (3, "2020-04-24", "魚やん", "");
```

のデータを seed.sql の名前にセーブするのが hkimura 流。
セーブしたら、ターミナルで、

```sh
$ sqlite3 schedule.db < seed.sql
```
---
###(オプショナル)

開発中は、何度も sqlite3 ... をタイプすることになる。
タイプがめんどくさいので次の内容でファイル Makefile を作る。
ヘンテコルールで、二つある sqlite3 の左はスペースじゃなくてタブ。

```text
init:
  sqlite3 schedule.db < create.sql

seed:
  sqlite3 schedule.db < seed.sql
```

ついでに、create.sql の先頭に、テーブルを消す命令を入れておく。
```sql
DROP TABLE schedle;
```

こうしておくと、次のコマンドでデータベースを何度でも初期化できる。

```sh
$ make init seed
```

---
### Racket

(ここまでにすでに１時間経過）
探したものの中で [Spin](https://github.com/dmac/spin) が一番シンブルで応用が効きそう。

インストールは、

```sh
$ raco pkg install https://github.com/dmac/spin.git
```

```racket
#lang racket

(require (planet dmac/spin))
(require db)

(define DB (sqlite3-connect #:database "schedule.db"))

(get "/"
  (lambda () "<p>Hello Racket</p>"))

(run #:port 3000 #:listen-ip #f)
```

ブラウザで http://localhost:3000/ を開いてみる。
止める時は Racket の右上の🟥。

---
### 設計変更

3人分のスケジュール出すのは一人分出すよりめんどうなので、
バージョン1は一人用のスケジュール管理アプリとする。
→ seed.rkt を変更

1. user-id を全部 1 にする。
1. make init seed でデータ変更。

date じゃどっちのイベントの前後がわからない。
1. date を datetime に変更。
1. seed.sql に日付を入れる。

timestamp はデータを入れた時間。混同しないように。


