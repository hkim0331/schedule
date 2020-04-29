#lang racket

(require (planet dmac/spin))
(require db)

(define VERSION "1.4.0")

(define DB (sqlite3-connect #:database "schedule.db"))

(define under-construction
  "<p style='font-size:24pt; color:red;'>UNDER CONSTRUCTION🔥</p>")

(define header
  "<!DOCTYPE html>
<html>
<head>
<meta name='viewport' content='width=device-width,initial-scale=1'>
<link rel='stylesheet'
 href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css'
 integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T'
 crossorigin='anonymous'>
<style>
  p.date {font-style: italic;}
  p.event {margin-left: 2em;}
  input.date  {width: 200px;}
  input.brief {width: 200px;}
  textarea.detail {width:300px;}
  div.sql {margin-bottom:1ex;}
  input.sql {width:400px;}
  div.m2 {margin-left: 2em;}
</style>
</head>
<body>
<div class='container'>
<h1>Schedule</h1>")

(define footer
  (format "<hr>
hiroshi.kimura.0331@gmail.com,
<a href='https://github.com/hkim0331/schedule.git'>~a</a>.
</div>
</body>
<script src='https://code.jquery.com/jquery-3.3.1.slim.min.js' integrity='sha384-q8i/X+965DzO0rT7\
abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo' crossorigin='anonymous'></script>
<script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js' integrity\
='sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1' crossorigin='anonymous\
'></script>
<script src='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js' integrity='s\
ha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM' crossorigin='anonymous'><\
/script>
</html>" VERSION))

;; version 1.
;; 文字列のリストを引数にとり、それを一本の文字列につないで、
;; 戻り値とする。この設計はいいのか悪いのか。。。
(define html
  (lambda (ss)
    (string-append header (string-join ss) footer)))

(define format-schedule
  (lambda (r)
    (let ((id (vector-ref r 0))
          (date (vector-ref r 2))
          (brief  (vector-ref r 3)))
      (format
        "<hr><p class='date'>~a<p>
<p class='event'><a href='/detail?id=~a'>~a</a></p>"
        date id brief))))

(define new-button
  (lambda ()
    (format "<p><a href='/new' class='btn btn-primary'>new</a>")))

(define delete-button
  (lambda (n)
    (format "<form method='post' action='/delete'
      onsubmit=\"return confirm('want to delete?')\">
      <input type='hidden' name='id' value='~a'>
      <input type='submit' value='delete' class='btn btn-danger'>"
            n)))

(define my-number->string
  (lambda (lst)
    (map (lambda (x) (if (number? x) (number->string x) x))
         lst)))

(define tr
  (lambda (vs)
    (let ((len (vector-length (first vs))))
      (string-join
        (my-number->string
          (flatten
            (for/list ([row vs])
              (list
                "<tr>"
                (for/list ([i (range len)])
                  (list
                    "<td>"
                    (vector-ref row i)
                    "</td>"))
                "</tr>"))))))))

(define div-sql
  (lambda ()
    "<hr>

<h3> HMTL </h3>
<ul>
<li><a href='/mura'>mura</a></li>
<li><a href='/kuma'>kuma</a></li>
<li><a href='/kimu'>kimu</a></li>
</ul>

<p><a href='/reset' class='btn btn-danger'>Reset DB</a>
エラーになっても気にすんな。ブラウザのバックで戻って再読み込み💪</p>

<h3>SQL</h3>
<form method='post' action='/sql'>
$ <input name='sql' class='sql' value='select * from schedule;'><br>
<input type='submit' value='query' class='btn btn-warning'>
</form>

<hr>

<h3>Racket(dmac/spin)</h3>

<form method='post' action='/eval'>
  (query-rows DB &nbsp;\"
    <input name='sql' class='sql' value='select * from schedule;'>\"&nbsp;)<br>
    <input type='submit' value='eval' class='btn btn-success'>
</form>

<hr>"))

(get "/mura"
  (lambda (req)
    (html
      (list
        "<p>Hello, Murakami♗</p>"
        "<p><a href='/'>back</a>"))))

(get "/kuma"
  (lambda (req)
    (html
      (list
        "<p>Hello, Kumashiro🐻</p>"
        "<p><a href='/'>back</a>"))))

(get "/kimu"
  (lambda (req)
    (html
      (list
        "<p>🍺</p>"
        "<p><a href='/'>back</a>"))))

(post "/eval"
  (lambda (req)
    (let ((ret (query-rows DB (params req 'sql))))
      (if (null? ret)
        (html
          (list
            "<h2>EMPTY</h2>"
            "<p>🐸<a href='/'>かえる</a>"))
        (html
         (list
          "<h2>RESULT</h2>"
          "<table>"
          (tr ret)
          "</table>"
          "<p>🐸<a href='/'>かえる</a>"))))))

(post "/sql"
  (lambda (req)
    (let ((ret (query-rows DB (params req 'sql))))
      (if (null? ret)
        (html
          (list
            "<h2>EMPTY</h2>"
            "<p>🐸<a href='/'>かえる</a>"))
        (html
         (list
          "<h2>RESULT</h2>"
          "<table>"
          (tr ret)
          "</table>"
          "<p>🐸<a href='/'>かえる</a>"))))))

;; must use post
(get "/reset"
  (lambda ()
    (let ((pwd (getenv "PWD")))
      (println pwd)
      (and
        (system
          (format"/usr/bin/sqlite3 ~a/schedule.db < ~a/create.sql"
            pwd pwd))
        (system
          (format "/usr/bin/sqlite3 ~a/schedule.db < ~a/seed.sql"
            pwd pwd))
      "OK"))))

(get "/hello"
     (lambda ()
       (html (list
              "<p>Hello Racket</p>"
              "<p>Nice to meet you</p>"))))

;; (cons (cons ...) はぶざま
(get "/"
     (lambda ()
       (let* ((q "select * from schedule order by datetime")
              (ret (query-rows DB q)))
         (html
          (cons (div-sql)
            (cons (new-button)
              (for/list ([r ret])
                          (format-schedule r))))))))

(get "/detail"
     (lambda (req)
       (let* ((q
               (format
                "select id, datetime, brief, detail from schedule where id='~a'"
                (params req 'id)))
              (r (query-row DB q))
              (id (vector-ref r 0))
              (da (vector-ref r 1))
              (br (vector-ref r 2))
              (de (vector-ref r 3)))
         (html (list
                "<form method='post' action='/update'>"
                (format "<input type='hidden' name='id' value='~a'>" id)
                (format "<p>ID: ~a" id)
                (format "<p>日付:<input name='datetime' value='~a'></p>" da)
                (format "<p>短く:<input name='brief' value='~a'></p>" br)
                (format "<p>詳しく:<br><textarea name='detail' class='detail'>~a</textarea></p>" de)
                "<input type='submit' class='btn btn-primary' value='update'></form>"
                (delete-button id))))))

;; 新規作成のフォームを出し、
;; ボタンを押されたらフォームに入力されたデータを持って post /create へ。
(get "/new"
      (lambda ()
        (html (list
          "<form method='post' action='/create'>"
          "<input type='hidden' name='user_id' value='1'>"
          "<p>日付:<input name='datetime' class='datetime' placeholder='yyyy-mm-dd HH:MM:SS'></p>"
          "<p>短く:<input name='brief' class='brief'></p>"
          "<p>詳細:<textarea class='detail' name='detail'></textarea></p>"
          "<input type='submit' value='create' class='btn btn-primary'>"
          "</form>"))))

(post "/create"
      (lambda (req)
        (query-exec
          DB
          (format "insert into schedule (user_id, datetime, brief, detail) values ('~a', '~a','~a', '~a')"
            (params req 'user_id)
            (params req 'datetime)
            (params req 'brief)
            (params req 'detail)))
        "<p>OK. <a href='/'>戻る</a></p>"))


(post "/delete"
      (lambda (req)
        (query-exec
          DB
          (format "delete from schedule where id='~a'" (params req 'id)))
        (html (list
              "<h3>deleted.</h3>"
              "<p><a href='/'>戻る</a>。(再読み込み必要かも)</p>"))))


(post "/update"
      (lambda (req)
        (let ((q
               (format
                "update schedule set datetime ='~a', brief='~a', detail='~a' where id='~a'"
                (params req 'datetime)
                (params req 'brief)
                (params req 'detail)
                (params req 'id))))
          ;;(println q)
          (query-exec DB q)
          (html (list
                 "<h3>アップデートできたかな？</h3>"
                 "<p><a href='/'>back</a>")))))


(define start
  (lambda (port)
    (println (format "schedule will start at port ~a" port))
    (run #:port port #:listen-ip #f)))

;; hkimura   3003
;; murakami  3004
;; kumashiro 3005
(define main
  (lambda ()
    (let ((args (current-command-line-arguments))
          (port 3000))
      (for ([i (range 0 (vector-length args) 2)])
        (when (string=? (vector-ref args i) "-p")
          (set! port (string->number (vector-ref args (+ i 1))))))
      (start port))))

(main)
