run:
	racket schedule.rkt

init:
	sqlite3 schedule.db < create.sql

seed:
	sqlite3 schedule.db < seed.sql