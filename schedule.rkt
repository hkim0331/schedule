#lang racket
;; [version 1] - 2020-04-24

(require (planet dmac/spin))
(require db)

(define DB (sqlite3-connect #:database "schedule.db"))

;; version 1.
;; 文字列のリストを引数にとり、それを一本の文字列につないで、
;; 戻り値とする。この設計はいいのか悪いのか。。。

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
textarea.detail {width:300px;height:200px;}
</style>
</head>
<body>
<div class='container'>
<h1>Schedule (version 1)</h1>")

(define footer
  "<hr>
hiroshi.kimura.0331@gmail.com
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
</html>")

(define html
  (lambda (ss)
    (string-append header
                   (string-join ss)
                   footer)))

(define format-schedule
  (lambda (r)
    (let ((id (vector-ref r 0))
          (date (vector-ref r 2))
          (brief  (vector-ref r 3)))
    (format "<p class='date'>~a<p>
<p class='event'><a href='/detail?id=~a'>~a</a></p>" date id brief))))
  
(get "/hello"
     (lambda ()
       (html (list
              "<p>Hello Racket</p>"
              "<p>Nice to meet you</p>"))))

(get "/"
     (lambda ()
       (let* ((q "select * from schedule order by datetime")
              (ret (query-rows DB q)))
         (html (for/list ([r ret])
                         (format-schedule r))))))

(get "/detail"
     (lambda (req)
       (let* ((q (format "select id, datetime, brief, detail from schedule where id='~a'"
                         (params req 'id)))
              (r (query-row DB q))
              (id (vector-ref r 0))
              (da (vector-ref r 1))
              (br (vector-ref r 2))
              (de (vector-ref r 3)))
         (html (list
                "<form method='post' action='/update'>"
                (format "<p>日付:<input name='date' value='~a'></p>" da)
                (format "<p>短く:<input name='brief' value='~a'></p>" br)
                (format "<p>詳しく:<br><textarea name='detail' class='detail'>~a</textarea></p>" de)
                "<input type='submit' class='btn btn-primary' value='update'>")))))

(post "/update"
      (lambda (req)
        (html (list
               "<h2>version 1 はアップデートしません。</h2>"
               "<p><a href='/'>back</a>"))))

(run #:port 3000 #:listen-ip #f)
