drop table schedule;
create table schedule (
  id integer primary key autoincrement,
  user_id int,
  datetime datetime,
  brief text,
  detail text,
  update_at timestamp DEFAULT CURRENT_TIMESTAMP
);
